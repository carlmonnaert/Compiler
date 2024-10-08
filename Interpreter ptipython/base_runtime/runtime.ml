open Ast ;;
 
exception  Error of string ;;
exception  RuntimeError of string * Lexing.position ;;

 
           
let eval program_ast  =
  let _ = program_ast in () 
