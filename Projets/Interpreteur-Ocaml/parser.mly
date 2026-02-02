%{
  open Ast
  open Ast.Syntax
%}

%token <int> Lint
%token <string> Lident
%token <string> Lstring
%token Ltrue Lfalse

%token Lfun Llet Lif Lelse Lwhile Lreturn
%token Tint Tbool Tstring Tunit

%token Llp Lrp Llcb Lrcb Lcolon Lsemi Lcomma
%token Lassign
%token Lplus Lminus Lstar Lslash Lmod
%token Leqeq Lneq Llt Lle Lgt Lge
%token Land Lor
%token Lnot
%token Lend

%start prog
%type <Ast.Syntax.prog> prog

/* ✅ PRÉCÉDENCES : DOIVENT ÊTRE AVANT %% */
%left Lor
%left Land
%nonassoc Leqeq Lneq Llt Lle Lgt Lge
%left Lplus Lminus
%left Lstar Lslash Lmod
%right UMINUS

%%

prog:
| fundefs Lend { $1 }
;

fundefs:
| /* empty */     { [] }
| fundef fundefs  { $1 :: $2 }
;

fundef:
| Lfun Lident Llp params_opt Lrp Lcolon typ Llcb block Lrcb {
    { name=$2; params=$4; ret=$7; body=$9; pos=Parsing.rhs_start_pos 1 }
  }
;

params_opt:
| /* empty */ { [] }
| params      { $1 }
;

params:
| param               { [ $1 ] }
| param Lcomma params { $1 :: $3 }
;

param:
| Lident Lcolon typ {
    { name=$1; ty=$3; pos=Parsing.rhs_start_pos 1 }
  }
;

typ:
| Tint    { TInt (Parsing.rhs_start_pos 1) }
| Tbool   { TBool (Parsing.rhs_start_pos 1) }
| Tstring { TString (Parsing.rhs_start_pos 1) }
| Tunit   { TUnit (Parsing.rhs_start_pos 1) }
;

block:
| instrs_opt { $1 }
;

instrs_opt:
| /* empty */         { [] }
| instr instrs_opt    { $1 :: $2 }
;

instr:
| Llet Lident Lcolon typ Lassign expr Lsemi {
    Let ($2, $4, $6, Parsing.rhs_start_pos 1)
  }
| Lident Lassign expr Lsemi {
    Assign ($1, $3, Parsing.rhs_start_pos 1)
  }
| Lreturn expr Lsemi {
    Return ($2, Parsing.rhs_start_pos 1)
  }
| Lif Llp expr Lrp Llcb block Lrcb Lelse Llcb block Lrcb {
    If ($3, $6, $10, Parsing.rhs_start_pos 1)
  }
| Lwhile Llp expr Lrp Llcb block Lrcb {
    While ($3, $6, Parsing.rhs_start_pos 1)
  }
| expr Lsemi {
    Expr ($1, Parsing.rhs_start_pos 1)
  }
;

expr:
| Lint        { Int ($1, Parsing.rhs_start_pos 1) }
| Ltrue       { Bool (true,  Parsing.rhs_start_pos 1) }
| Lfalse      { Bool (false, Parsing.rhs_start_pos 1) }
| Lstring     { String ($1, Parsing.rhs_start_pos 1) }
| Lident      { Var ($1, Parsing.rhs_start_pos 1) }
| Lident Llp args_opt Lrp { Call ($1, $3, Parsing.rhs_start_pos 1) }
| Llp expr Lrp { $2 }

| Lminus expr %prec UMINUS { Unop (Neg, $2, Parsing.rhs_start_pos 1) }
| Lnot expr                { Unop (Not, $2, Parsing.rhs_start_pos 1) }

| expr Lstar  expr { Binop (Mul, $1, $3, Parsing.rhs_start_pos 2) }
| expr Lslash expr { Binop (Div, $1, $3, Parsing.rhs_start_pos 2) }
| expr Lmod   expr { Binop (Mod, $1, $3, Parsing.rhs_start_pos 2) }
| expr Lplus  expr { Binop (Add, $1, $3, Parsing.rhs_start_pos 2) }
| expr Lminus expr { Binop (Sub, $1, $3, Parsing.rhs_start_pos 2) }

| expr Llt   expr  { Binop (Lt, $1, $3, Parsing.rhs_start_pos 2) }
| expr Lle   expr  { Binop (Le, $1, $3, Parsing.rhs_start_pos 2) }
| expr Lgt   expr  { Binop (Gt, $1, $3, Parsing.rhs_start_pos 2) }
| expr Lge   expr  { Binop (Ge, $1, $3, Parsing.rhs_start_pos 2) }
| expr Leqeq expr  { Binop (Eq, $1, $3, Parsing.rhs_start_pos 2) }
| expr Lneq  expr  { Binop (Ne, $1, $3, Parsing.rhs_start_pos 2) }

| expr Land  expr  { Binop (And, $1, $3, Parsing.rhs_start_pos 2) }
| expr Lor   expr  { Binop (Or,  $1, $3, Parsing.rhs_start_pos 2) }
;

args_opt:
| /* empty */ { [] }
| args        { $1 }
;

args:
| expr              { [ $1 ] }
| expr Lcomma args  { $1 :: $3 }
;
