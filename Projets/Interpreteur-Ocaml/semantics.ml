open Ast
open Baselib

module Syn = Ast.Syntax
module IR  = Ast.IR

exception Error of string * Lexing.position
let err pos msg = raise (Error (msg, pos))

module SEnv = Map.Make(String)

type vinfo = { ty: IR.typ }
type finfo = { params: IR.typ list; ret: IR.typ }

let typ_of_syntax (t: Syn.typ) : IR.typ =
  match t with
  | Syn.TInt _    -> IR.TInt
  | Syn.TBool _   -> IR.TBool
  | Syn.TString _ -> IR.TString
  | Syn.TUnit _   -> IR.TUnit

let binop_of_syntax (op: Syn.binop) : IR.binop =
  match op with
  | Syn.Add -> IR.Add | Syn.Sub -> IR.Sub | Syn.Mul -> IR.Mul | Syn.Div -> IR.Div | Syn.Mod -> IR.Mod
  | Syn.Eq  -> IR.Eq  | Syn.Ne  -> IR.Ne
  | Syn.Lt  -> IR.Lt  | Syn.Le  -> IR.Le  | Syn.Gt -> IR.Gt | Syn.Ge -> IR.Ge
  | Syn.And -> IR.And | Syn.Or  -> IR.Or

let unop_of_syntax (op: Syn.unop) : IR.unop =
  match op with
  | Syn.Neg -> IR.Neg
  | Syn.Not -> IR.Not

let rec analyze_expr (e: Syn.expr) (venv: vinfo SEnv.t) (fenv: finfo SEnv.t)
  : IR.expr * IR.typ =
  match e with
  | Syn.Int (n, _) -> (IR.Int n, IR.TInt)
  | Syn.Bool (b, _) -> (IR.Bool b, IR.TBool)
  | Syn.String (s, _) -> (IR.String s, IR.TString)

  | Syn.Var (name, pos) ->
      begin match SEnv.find_opt name venv with
      | None -> err pos ("variable inconnue: " ^ name)
      | Some i -> (IR.Var name, i.ty)
      end

  | Syn.Unop (op, e1, pos) ->
      let (ie, t) = analyze_expr e1 venv fenv in
      begin match op, t with
      | Syn.Neg, IR.TInt  -> (IR.Unop (IR.Neg, ie), IR.TInt)
      | Syn.Not, IR.TBool -> (IR.Unop (IR.Not, ie), IR.TBool)
      | Syn.Neg, _ -> err pos "(- unaire) attend un int"
      | Syn.Not, _ -> err pos "(!) attend un bool"
      end

  | Syn.Binop (op, a, b, pos) ->
      let (ia, ta) = analyze_expr a venv fenv in
      let (ib, tb) = analyze_expr b venv fenv in
      let iop : IR.binop = binop_of_syntax op in
      begin match op with
      | Syn.Add | Syn.Sub | Syn.Mul | Syn.Div | Syn.Mod ->
          if ta <> IR.TInt || tb <> IR.TInt then err pos "op arithmétique attend (int,int)";
          (IR.Binop (iop, ia, ib), IR.TInt)
      | Syn.Lt | Syn.Le | Syn.Gt | Syn.Ge ->
          if ta <> IR.TInt || tb <> IR.TInt then err pos "comparaison attend (int,int)";
          (IR.Binop (iop, ia, ib), IR.TBool)
      | Syn.Eq | Syn.Ne ->
          if ta <> tb then err pos "==/!= attend deux expressions de même type";
          (IR.Binop (iop, ia, ib), IR.TBool)
      | Syn.And | Syn.Or ->
          if ta <> IR.TBool || tb <> IR.TBool then err pos "&&/|| attend (bool,bool)";
          (IR.Binop (iop, ia, ib), IR.TBool)
      end

  | Syn.Call (fname, args, pos) ->
      begin match SEnv.find_opt fname fenv with
      | None -> err pos ("fonction inconnue: " ^ fname)
      | Some sig_ ->
          let args_ir, args_ty =
            List.split (List.map (fun a -> analyze_expr a venv fenv) args)
          in
          if List.length args_ty <> List.length sig_.params then err pos "mauvaise arité";
          List.iter2 (fun got exp ->
            if got <> exp then err pos "type d'argument invalide"
          ) args_ty sig_.params;
          (IR.Call (fname, args_ir), sig_.ret)
      end

let rec analyze_instr (i: Syn.instr) (venv: vinfo SEnv.t) (fenv: finfo SEnv.t) (ret_ty: IR.typ)
  : IR.instr * vinfo SEnv.t * bool =
  match i with
  | Syn.Let (name, sty, value, pos) ->
      let declared : IR.typ = typ_of_syntax sty in
      let (ie, tv) = analyze_expr value venv fenv in
      if declared <> tv then err pos "type incompatible dans let";
      (IR.Let (name, declared, ie), SEnv.add name {ty=declared} venv, false)

  | Syn.Assign (name, value, pos) ->
      begin match SEnv.find_opt name venv with
      | None -> err pos ("assign sur variable inconnue: " ^ name)
      | Some info ->
          let (ie, tv) = analyze_expr value venv fenv in
          if info.ty <> tv then err pos "type incompatible dans assign";
          (IR.Assign (name, ie), venv, false)
      end

  | Syn.Return (e, pos) ->
      let (ie, t) = analyze_expr e venv fenv in
      if t <> ret_ty then err pos "type de return incompatible";
      (IR.Return ie, venv, true)

  | Syn.Expr (e, _) ->
      let (ie, _) = analyze_expr e venv fenv in
      (IR.Expr ie, venv, false)

  | Syn.If (cond, th, el, pos) ->
    let (ic, t) = analyze_expr cond venv fenv in
    if t <> IR.TBool then err pos "if attend un bool";
    let th_ir, th_ret = analyze_block th venv fenv ret_ty in
    let el_ir, el_ret = analyze_block el venv fenv ret_ty in
    (IR.If (ic, th_ir, el_ir), venv, th_ret && el_ret)


  | Syn.While (cond, body, pos) ->
      let (ic, t) = analyze_expr cond venv fenv in
      if t <> IR.TBool then err pos "while attend un bool";
      let body_ir, _ = analyze_block body venv fenv ret_ty in
      (IR.While (ic, body_ir), venv, false)

and analyze_block (b: Syn.block) (venv: vinfo SEnv.t) (fenv: finfo SEnv.t) (ret_ty: IR.typ)
  : IR.block * bool =
  let rec loop acc env = function
    | [] -> (List.rev acc, false)
    | hd::tl ->
        let (ii, env', did_ret) = analyze_instr hd env fenv ret_ty in
        if did_ret then (List.rev (ii::acc), true)
        else loop (ii::acc) env' tl
  in
  loop [] venv b

let build_fenv (p: Syn.prog) : finfo SEnv.t =
  let fenv0 =
  Baselib.Env.fold
    (fun name (sig_:Baselib.funsig) acc ->
      SEnv.add name { params = sig_.params; ret = sig_.ret } acc
    )
    Baselib.builtins_types
    SEnv.empty
in

  List.fold_left (fun acc (fd: Syn.fundef) ->
    if SEnv.mem fd.name acc then err fd.pos ("fonction dupliquée: " ^ fd.name);
    let params = List.map (fun (pa: Syn.param) -> typ_of_syntax pa.ty) fd.params in
    let ret = typ_of_syntax fd.ret in
    SEnv.add fd.name {params; ret} acc
  ) fenv0 p

let analyze_fundef (fd: Syn.fundef) (fenv: finfo SEnv.t) : IR.fundef =
  let params_ir = List.map (fun (p: Syn.param) -> (p.name, typ_of_syntax p.ty)) fd.params in
  let venv =
    List.fold_left (fun acc (n,t) -> SEnv.add n {ty=t} acc) SEnv.empty params_ir
  in
  let ret_ty = typ_of_syntax fd.ret in
  let body_ir, did_return = analyze_block fd.body venv fenv ret_ty in
  if (not did_return) && ret_ty <> IR.TUnit then err fd.pos "fonction non-void sans return garanti";
  { IR.name=fd.name; params=params_ir; ret=ret_ty; body=body_ir }

let analyze (p: Syn.prog) : IR.prog =
  let fenv = build_fenv p in
  if not (SEnv.mem "main" fenv) then err Lexing.dummy_pos "fonction main manquante";
  List.map (fun fd -> analyze_fundef fd fenv) p
