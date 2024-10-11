open Ast ;;
open Hashtbl ;;
open Printf ;;
open String ;;
 
exception  Error of string ;;
exception  RuntimeError of string * Lexing.position ;;

let gvar = (Hashtbl.create 10);;

let rec eval_expr expr = match expr with
  | Const(const,ppos) -> begin
                          match const with 
                            | Int(str,ppos1) -> (int_of_string str)
                            | _ -> failwith "not implemented in eval_expr"
                            (*
                            | Str(str,ppos1) -> str
                            | Bool(b,ppos1) -> b
                            | Non(ppos) -> ()
                              *)
                         end

  | Val(left_value,ppos) -> (
    match left_value with 
      | Var(var_name,ppos) -> Hashtbl.find gvar var_name
      | Tab(left_value1,expr1,ppos) -> failwith "Tab not implemented"
  )

  | Moins(expr1,ppos) -> 0-(eval_expr expr1)

  | Not(expr1, ppos) -> failwith "booleans not implemented"
  (*
     begin
       match (eval_expr expr1) with 
       | true -> false 
       | false -> true
       | _ -> failwith "something wrong in eval_expr : Not "
     end 
  *)
  | Op(binop,expr1,expr2,ppos)-> (
    match binop with | Add -> (eval_expr expr1) + (eval_expr expr2)
                     | Sub -> (eval_expr expr1) - (eval_expr expr2)
                     | Mul -> (eval_expr expr1) * (eval_expr expr2)
                     | Div -> (eval_expr expr1) / (eval_expr expr2)
                     | Mod -> (eval_expr expr1) mod (eval_expr expr2)
                     | _ -> failwith "not implemented OP"
                      (*
                     | Leq -> (eval_expr expr1) <= (eval_expr expr2)
                     | Le -> (eval_expr expr1) < (eval_expr expr2)
                     | Geq -> (eval_expr expr1) >= (eval_expr expr2)
                     | Ge -> (eval_expr expr1) > (eval_expr expr2)
                     | Neq -> (eval_expr expr1) <> (eval_expr expr2)
                     | Eq -> (eval_expr expr1) == (eval_expr expr2)
                     | And -> (eval_expr expr1) && (eval_expr expr2)
                     | Or -> (eval_expr expr1) || (eval_expr expr2)
  *)
  )
  | List(expr_list, ppos) -> failwith "evalexpr : List not implemented"
  | Ecall(fun_name,expr_list,ppos)->   ( if String.equal fun_name "print"
                                       then begin (Printf.printf "%d\n" (match expr_list with | expr1::l -> (eval_expr expr1)
                                                                                              | _ -> failwith "someting went wrong in Ecall") 
                                                  ; 0)
                                            end 
                                       else failwith "evalexpr : Ecall not implemented")
;;

let rec eval_stmt stmt = match stmt with
  | Sfor(counter,expr,stmt,ppos) -> failwith "evalexpr : Sfor not implemented"
  | Sblock(stmt_list, ppos) -> List.iter eval_stmt stmt_list
  | Sreturn(expr,ppos) -> failwith "evalexpr : Sreturn not implemented"
  | Sassign(left_value,expr,ppos) ->
     let var_name = match left_value with
       | Tab(l,e,p) -> failwith "Tab not implemented"
       | Var(var_name,pos) -> var_name
     in
     if Hashtbl.mem gvar var_name then Hashtbl.replace gvar var_name (eval_expr expr)
     else Hashtbl.add gvar var_name (eval_expr expr)
  | Sval(expr,ppos) -> (let _ = eval_expr expr in () )
;;

let eval_global_stmt gstmt = match gstmt with
  |Gstmt(stmt,ppos) -> (eval_stmt stmt)
  |GFunDef(fun_name,var_list,stmt,ppos) -> failwith "functions not implemented"
;;

let eval program_ast  = List.iter eval_global_stmt program_ast;;
