open Lexing

let err msg pos =
  Printf.eprintf "Error line %d col %d: %s\n"
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol) msg;
  exit 1

let () =
  if Array.length Sys.argv <> 2 then begin
    Printf.eprintf "Usage: %s <file>\n" Sys.argv.(0);
    exit 1
  end;

  let ic = open_in Sys.argv.(1) in
  let buf = Lexing.from_channel ic in
  try
    let parsed = Parser.prog Lexer.token buf in
    close_in ic;
    let ir = Semantics.analyze parsed in
    let asm = Compiler.compile ir in
    Mips.emit stdout asm
  with
  | Lexer.Error c ->
      err (Printf.sprintf "unrecognized char '%c'" c) (Lexing.lexeme_start_p buf)
  | Parsing.Parse_error ->
      err "syntax error" (Lexing.lexeme_start_p buf)
  | Semantics.Error (msg, pos) ->
      err msg pos
