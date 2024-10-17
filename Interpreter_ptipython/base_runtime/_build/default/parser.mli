
(* The type of tokens. *)

type token = 
  | TRUE
  | TIMES
  | STR of (string)
  | RP
  | RETURN
  | RB
  | PLUS
  | OR
  | NOT
  | NONE
  | NEWLINE
  | NEQ
  | MOD
  | MINUS
  | LP
  | LEQ
  | LE
  | LB
  | IN
  | IF
  | IDENT of (string)
  | GEQ
  | GE
  | FOR
  | FALSE
  | EQQ
  | EQ
  | EOF
  | END
  | ELSE
  | ELIF
  | DIV
  | DEF
  | CST of (string)
  | COMMA
  | COLON
  | BEGIN
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val file: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.program)
