
(* Analyseur lexical *)

{
  open Lexing
  open Parser
   
  exception Lexing_error of char
    
  let id_or_kwd s = match s with
  | "print_int" -> PRINT_INT
  | "read" -> READ
  | "int" -> INT
  | "return" -> RETURN
  | "if" -> IF
  | "else" -> ELSE
  | s -> IDENT s
  

}

let comment = '/''/' [^'\n']*
let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let underscore = '_'
let ident = letter (letter | digit | underscore)*
let integer = ['0'-'9']+
let space = [' ' '\t']
let allchar = ['\000' - '\255']

rule token = parse
  | '\n'    { new_line lexbuf; token lexbuf }
  | space+  { token lexbuf }
  | ident as id { id_or_kwd id }
  (* | '//'  { COMMENT} *)
  | '+'     { PLUS }
  | '-'     { MINUS }
  | '*'     { TIMES }
  | '/'     { DIV }
  | '%'     { MOD }
  | '='     { EQ }
  | '=''='  { EQEQ }
  | '<'     { LT }
  | '>'     { GT }
  | '<''='  { LTEQ }
  | '>''='  { GTEQ }
  | '!'     { NOT }
  | '!''='  { NOTEQ }
  | '&''&'     { AND }
  | '|''|'     { OR }
  | '('     { LP }
  | ')'     { RP }
  | '{'     { LB }
  | '}'     { RB }
  | ';'     { SEMICOLON }
  | ','     { COMMA }
  | comment       { token lexbuf }
  | integer as s { CST (int_of_string s) }
  | eof     { EOF }
  | _ as c  { raise (Lexing_error c) }
 

