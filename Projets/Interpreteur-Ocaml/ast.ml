module Syntax = struct
  type pos = Lexing.position

  type typ =
    | TInt of pos
    | TBool of pos
    | TString of pos
    | TUnit of pos

  type binop =
    | Add | Sub | Mul | Div | Mod
    | Eq | Ne | Lt | Le | Gt | Ge
    | And | Or

  type unop = Neg | Not

  type expr =
    | Int    of int * pos
    | Bool   of bool * pos
    | String of string * pos
    | Var    of string * pos
    | Call   of string * expr list * pos
    | Binop  of binop * expr * expr * pos
    | Unop   of unop * expr * pos

  type instr =
    | Let    of string * typ * expr * pos
    | Assign of string * expr * pos
    | Return of expr * pos
    | If     of expr * block * block * pos
    | While  of expr * block * pos
    | Expr   of expr * pos

  and block = instr list

  type param = { name: string; ty: typ; pos: pos }

  type fundef = {
    name: string;
    params: param list;
    ret: typ;
    body: block;
    pos: pos;
  }

  type prog = fundef list
end

module IR = struct
  type typ = TInt | TBool | TString | TUnit

  type binop =
    | Add | Sub | Mul | Div | Mod
    | Eq | Ne | Lt | Le | Gt | Ge
    | And | Or

  type unop = Neg | Not

  type expr =
    | Int    of int
    | Bool   of bool
    | String of string
    | Var    of string
    | Call   of string * expr list
    | Binop  of binop * expr * expr
    | Unop   of unop * expr

  type instr =
    | Let    of string * typ * expr
    | Assign of string * expr
    | Return of expr
    | If     of expr * block * block
    | While  of expr * block
    | Expr   of expr

  and block = instr list

  type param = string * typ

  type fundef = {
    name: string;
    params: param list;
    ret: typ;
    body: block;
  }

  type prog = fundef list
end
