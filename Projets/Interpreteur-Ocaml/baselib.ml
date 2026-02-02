open Ast
open Mips

module Env = Map.Make(String)

type funsig = { params: Ast.IR.typ list; ret: Ast.IR.typ }

let builtins_types : funsig Env.t =
  Env.empty
  |> Env.add "print_int"    { params=[IR.TInt];    ret=IR.TUnit }
  |> Env.add "print_bool"   { params=[IR.TBool];   ret=IR.TUnit }
  |> Env.add "print_string" { params=[IR.TString]; ret=IR.TUnit }
  |> Env.add "read_int"     { params=[];           ret=IR.TInt }
  |> Env.add "read_bool"    { params=[];           ret=IR.TBool }
  |> Env.add "read_string"  { params=[];           ret=IR.TString }

(* data needed by builtins *)
let builtins_data : Mips.decl list =
  [ ("__true",  Asciiz "true")
  ; ("__false", Asciiz "false")
  ; ("__buf",   Space 256)
  ]

let builtins_asm : Mips.instr list =
  [
    (* print_int(a0) *)
    Label "print_int";
    Li (V0, 1); Syscall;
    Li (V0, 0); Jr RA;

    (* print_string(a0) *)
    Label "print_string";
    Li (V0, 4); Syscall;
    Li (V0, 0); Jr RA;

    (* print_bool(a0) *)
    Label "print_bool";
    (* if a0 != 0 -> print "__true" else "__false" *)
    Bnez (A0, "__pb_true");
    La (A0, "__false"); Li (V0, 4); Syscall;
    Li (V0, 0); Jr RA;
    Label "__pb_true";
    La (A0, "__true"); Li (V0, 4); Syscall;
    Li (V0, 0); Jr RA;

    (* read_int() -> v0 *)
    Label "read_int";
    Li (V0, 5); Syscall;
    Jr RA;

    (* read_bool() -> v0 (0/1) *)
    Label "read_bool";
    Li (V0, 5); Syscall;          (* read int into v0 *)
    Beqz (V0, "__rb_zero");
    Li (V0, 1); Jr RA;
    Label "__rb_zero";
    Li (V0, 0); Jr RA;

    (* read_string() -> v0 (addr) *)
    Label "read_string";
    La (A0, "__buf");
    Li (A1, 256);
    Li (V0, 8);
    Syscall;
    La (V0, "__buf");
    Jr RA;
  ]
