module IR = Ast.IR
module M  = Mips
module Env = Map.Make(String)

open Baselib

type vloc = { off: int }
type cfun = { venv: vloc Env.t; stack_size: int; param_names: string list }

let word = 4

let fresh =
  let c = ref 0 in
  fun p -> incr c; Printf.sprintf "%s_%04d" p !c

(* --- string literals pool --- *)
module SMap = Map.Make(String)
type pool = { mutable data: M.decl list; mutable map: string SMap.t }
let pool_create () = { data = []; map = SMap.empty }

let pool_intern (p:pool) (s:string) : string =
  match SMap.find_opt s p.map with
  | Some lbl -> lbl
  | None ->
      let lbl = fresh "__str" in
      p.map <- SMap.add s lbl p.map;
      p.data <- (lbl, M.Asciiz s) :: p.data;
      lbl

(* --- locals collection --- *)
let rec collect_locals_block (b: IR.block) (acc:string list) : string list =
  List.fold_left (fun a i ->
    match i with
    | IR.Let (name, _, _) -> name :: a
    | IR.If (_, th, el) -> collect_locals_block el (collect_locals_block th a)
    | IR.While (_, body) -> collect_locals_block body a
    | _ -> a
  ) acc b

let build_env_for_fun (fd: IR.fundef) : cfun =
  let params = List.map fst fd.params in
  let locals = collect_locals_block fd.body [] in
  let all = (params @ locals) |> List.sort_uniq String.compare in
  let (venv, sz) =
    List.fold_left (fun (env, k) name ->
      (Env.add name {off = -word * (k+1)} env, k+1)
    ) (Env.empty, 0) all
  in
  { venv; stack_size = sz * word; param_names = params }

let lw_var venv name =
  match Env.find_opt name venv with
  | None -> failwith ("unknown var: " ^ name)
  | Some l -> [ M.Lw (M.V0, l.off, M.FP) ]

let sw_var venv name =
  match Env.find_opt name venv with
  | None -> failwith ("unknown var: " ^ name)
  | Some l -> [ M.Sw (M.V0, l.off, M.FP) ]

let push r = [ M.Addi (M.SP, M.SP, -word); M.Sw (r, 0, M.SP) ]
let pop r  = [ M.Lw (r, 0, M.SP); M.Addi (M.SP, M.SP, word) ]

let mk_bool_from_branch (branch_to_true: M.label) : M.instr list =
  let l_true = branch_to_true in
  let l_end  = fresh "bool_end" in
  [ M.Li (M.V0, 0); M.B l_end; M.Label l_true; M.Li (M.V0, 1); M.Label l_end ]

let rec compile_expr (pool:pool) (venv:vloc Env.t) (e: IR.expr) : M.instr list =
  match e with
  | IR.Int n -> [ M.Li (M.V0, n) ]
  | IR.Bool b -> [ M.Li (M.V0, if b then 1 else 0) ]
  | IR.String s ->
      let lbl = pool_intern pool s in
      [ M.La (M.V0, lbl) ]
  | IR.Var x -> lw_var venv x

  | IR.Unop (IR.Neg, e1) ->
      compile_expr pool venv e1 @ [ M.Sub (M.V0, M.ZERO, M.V0) ]

  | IR.Unop (IR.Not, e1) ->
      let l_true = fresh "not_true" in
      let l_end  = fresh "not_end" in
      compile_expr pool venv e1 @
      [ M.Beqz (M.V0, l_true)
      ; M.Li (M.V0, 0); M.B l_end
      ; M.Label l_true; M.Li (M.V0, 1)
      ; M.Label l_end ]

  | IR.Binop (op, a, b) ->
      let ca = compile_expr pool venv a in
      let cb = compile_expr pool venv b in
      ca @ push M.V0 @ cb @ pop M.T0 @
      begin match op with
      | IR.Add -> [ M.Add (M.V0, M.T0, M.V0) ]
      | IR.Sub -> [ M.Sub (M.V0, M.T0, M.V0) ]
      | IR.Mul -> [ M.Mul (M.V0, M.T0, M.V0) ]
      | IR.Div -> [ M.Div (M.T0, M.V0); M.Mflo M.V0 ]
      | IR.Mod -> [ M.Div (M.T0, M.V0); M.Mfhi M.V0 ]

      | IR.Eq ->
          let l_true = fresh "eq_true" in
          [ M.Sub (M.T1, M.T0, M.V0); M.Beqz (M.T1, l_true) ] @ mk_bool_from_branch l_true

      | IR.Ne ->
          let l_true = fresh "ne_true" in
          [ M.Sub (M.T1, M.T0, M.V0); M.Bnez (M.T1, l_true) ] @ mk_bool_from_branch l_true

      | IR.Lt -> [ M.Slt (M.V0, M.T0, M.V0) ]
      | IR.Gt -> [ M.Slt (M.V0, M.V0, M.T0) ]
      | IR.Le ->
          [ M.Slt (M.T1, M.V0, M.T0); M.Li (M.V0, 1); M.Sub (M.V0, M.V0, M.T1) ]
      | IR.Ge ->
          [ M.Slt (M.T1, M.T0, M.V0); M.Li (M.V0, 1); M.Sub (M.V0, M.V0, M.T1) ]

      | IR.And ->
          let l_false = fresh "and_false" in
          let l_end   = fresh "and_end" in
          [ M.Beqz (M.T0, l_false); M.Beqz (M.V0, l_false)
          ; M.Li (M.V0, 1); M.B l_end
          ; M.Label l_false; M.Li (M.V0, 0)
          ; M.Label l_end ]

      | IR.Or ->
          let l_true = fresh "or_true" in
          let l_end  = fresh "or_end" in
          [ M.Bnez (M.T0, l_true); M.Bnez (M.V0, l_true)
          ; M.Li (M.V0, 0); M.B l_end
          ; M.Label l_true; M.Li (M.V0, 1)
          ; M.Label l_end ]
      end

  | IR.Call (fname, args) ->
      let load_args =
        args
        |> List.mapi (fun i a ->
          let ar = match i with
            | 0 -> M.A0 | 1 -> M.A1 | 2 -> M.A2 | 3 -> M.A3
            | _ -> failwith "trop d'arguments (max 4)"
          in
          compile_expr pool venv a @ [ M.Move (ar, M.V0) ]
        )
        |> List.concat
      in
      load_args @ [ M.Jal fname ]

let rec compile_block (pool:pool) (cf:cfun) (epilogue:M.label) (b: IR.block) : M.instr list =
  List.concat (List.map (compile_instr pool cf epilogue) b)

and compile_instr (pool:pool) (cf:cfun) (epilogue:M.label) (i: IR.instr) : M.instr list =
  match i with
  | IR.Let (name, _ty, e) ->
      compile_expr pool cf.venv e @ sw_var cf.venv name
  | IR.Assign (name, e) ->
      compile_expr pool cf.venv e @ sw_var cf.venv name
  | IR.Expr e ->
      compile_expr pool cf.venv e
  | IR.Return e ->
      compile_expr pool cf.venv e @ [ M.J epilogue ]
  | IR.If (cond, th, el) ->
      let l_else = fresh "else" in
      let l_end  = fresh "ifend" in
      compile_expr pool cf.venv cond @
      [ M.Beqz (M.V0, l_else) ] @
      compile_block pool cf epilogue th @
      [ M.B l_end; M.Label l_else ] @
      compile_block pool cf epilogue el @
      [ M.Label l_end ]
  | IR.While (cond, body) ->
      let l_loop = fresh "loop" in
      let l_end  = fresh "endloop" in
      [ M.Label l_loop ] @
      compile_expr pool cf.venv cond @
      [ M.Beqz (M.V0, l_end) ] @
      compile_block pool cf epilogue body @
      [ M.B l_loop; M.Label l_end ]

let compile_fundef (pool:pool) (fd: IR.fundef) : M.instr list =
  let cf = build_env_for_fun fd in
  let epilogue = fd.name ^ "_epilogue" in

  let pro =
    [ M.Label fd.name
    ; M.Addi (M.SP, M.SP, -8)
    ; M.Sw (M.RA, 4, M.SP)
    ; M.Sw (M.FP, 0, M.SP)
    ; M.Move (M.FP, M.SP)
    ; M.Addi (M.SP, M.SP, -cf.stack_size)
    ]
  in

  let save_params =
    cf.param_names
    |> List.mapi (fun i name ->
      let r = match i with
        | 0 -> M.A0 | 1 -> M.A1 | 2 -> M.A2 | 3 -> M.A3
        | _ -> failwith "trop de paramètres (max 4)"
      in
      match Env.find_opt name cf.venv with
      | None -> []
      | Some loc -> [ M.Sw (r, loc.off, M.FP) ]
    )
    |> List.concat
  in

  let body = compile_block pool cf epilogue fd.body in

  let epi =
    if fd.name = "main" then
      [ M.Label epilogue
      ; M.Addi (M.SP, M.SP, cf.stack_size)
      ; M.Lw (M.FP, 0, M.SP)
      ; M.Lw (M.RA, 4, M.SP)
      ; M.Addi (M.SP, M.SP, 8)
      ; M.Li (M.V0, 10)
      ; M.Syscall
      ]
    else
      [ M.Label epilogue
      ; M.Addi (M.SP, M.SP, cf.stack_size)
      ; M.Lw (M.FP, 0, M.SP)
      ; M.Lw (M.RA, 4, M.SP)
      ; M.Addi (M.SP, M.SP, 8)
      ; M.Jr M.RA
      ]
  in
  pro @ save_params @ body @ epi

let compile (p: IR.prog) : M.asm =
  let pool = pool_create () in
  let user_text = List.concat (List.map (compile_fundef pool) p) in
  let text = Baselib.builtins_asm @ user_text in
  let data = Baselib.builtins_data @ List.rev pool.data in
  { M.text; data }
