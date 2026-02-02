{
  open Parser
  open Lexing
  exception Error of char

  let kw = function
    | "fun"    -> Lfun
    | "let"    -> Llet
    | "if"     -> Lif
    | "else"   -> Lelse
    | "while"  -> Lwhile
    | "return" -> Lreturn
    | "true"   -> Ltrue
    | "false"  -> Lfalse
    | "int"    -> Tint
    | "bool"   -> Tbool
    | "string" -> Tstring
    | "unit"   -> Tunit
    | s        -> Lident s
}

let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z' '_']
let alnum = ['a'-'z' 'A'-'Z' '0'-'9' '_']

rule token = parse
| eof                 { Lend }
| [ ' ' '\t' ]        { token lexbuf }
| '\n'                { Lexing.new_line lexbuf; token lexbuf }

| "/*"                { comment lexbuf; token lexbuf }
| "//" [^ '\n']*      { token lexbuf }

| digit+ as n         { Lint (int_of_string n) }
| '"'                 { Lstring (string_lit (Buffer.create 16) lexbuf) }

| alpha alnum* as id  { kw id }

| "=="                { Leqeq }
| "!="                { Lneq }
| "<="                { Lle }
| ">="                { Lge }
| "&&"                { Land }
| "||"                { Lor }

| '+'                 { Lplus }
| '-'                 { Lminus }
| '*'                 { Lstar }
| '/'                 { Lslash }
| '%'                 { Lmod }

| '<'                 { Llt }
| '>'                 { Lgt }
| '='                 { Lassign }
| '!'                 { Lnot }

| '('                 { Llp }
| ')'                 { Lrp }
| '{'                 { Llcb }
| '}'                 { Lrcb }
| ':'                 { Lcolon }
| ';'                 { Lsemi }
| ','                 { Lcomma }

| _ as c              { raise (Error c) }

and comment = parse
| "*/"                { () }
| eof                 { () }
| '\n'                { Lexing.new_line lexbuf; comment lexbuf }
| _                   { comment lexbuf }

and string_lit buf = parse
| '"'                 { Buffer.contents buf }
| "\\n"               { Buffer.add_char buf '\n'; string_lit buf lexbuf }
| "\\t"               { Buffer.add_char buf '\t'; string_lit buf lexbuf }
| "\\\""              { Buffer.add_char buf '"';  string_lit buf lexbuf }
| "\\\\"              { Buffer.add_char buf '\\'; string_lit buf lexbuf }
| '\n'                { Lexing.new_line lexbuf; Buffer.add_char buf '\n'; string_lit buf lexbuf }
| eof                 { Buffer.contents buf }
| _ as c              { Buffer.add_char buf c; string_lit buf lexbuf }
