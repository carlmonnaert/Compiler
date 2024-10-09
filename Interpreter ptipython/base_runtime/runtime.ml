open Ast ;;
 
exception  Error of string ;;
exception  RuntimeError of string * Lexing.position ;;


eval_expr expr = match expr with
  |Int(value,ppos) -> ()
  |Str(value,ppos) -> ()
  |Bool(value,ppos) -> ()
  |Non(ppos) -> ()

let eval_stmt stmt = match stmt with
  | Sfor(counter,expr,stmt,ppos) -> () 
  | Sblock(stmt_list, ppos) -> ()
  | Sreturn(expr,ppos) -> ()
  | Sassign(left_value,expr,ppos) -> ()
  | Sval(expr,ppos) -> ()

let eval_global_stmt gstmt = match gstmt with
  |Gstmt(stmt,ppos) -> eval_stmt stmt ppos
  |GFunDef(fun_name,var_list,stmt,ppos) -> ()

let eval program_ast  = List.map eval_global_stmt
