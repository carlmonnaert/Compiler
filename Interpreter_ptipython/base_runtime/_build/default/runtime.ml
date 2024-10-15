open Ast ;;
open Hashtbl ;;
open Printf ;;
open String ;;
 
exception  Error of string ;;
exception  RuntimeError of string * Lexing.position ;;

type value = {typ : string ; value : string};;

let gvar : (string, value) Hashtbl.t = Hashtbl.create 10

let toPyBool = function
  | "true" -> "True"
  | "false" -> "False"
  | _ -> failwith "not a boolean"



let rec eval_expr expr = match expr with
  | Const(const,ppos) -> begin
                          match const with 
                            | Int(str,ppos1) -> {typ = "int"; value = str}
                            | Str(str,ppos1) ->  {typ = "string"; value = str}
                            | Bool(b,ppos1) -> {typ = "bool"; value = toPyBool (string_of_bool b)}
                            | Non(ppos) -> {typ = "none"; value ="None"}                            
                         end

  | Val(left_value,ppos) -> (
    match left_value with 
      | Var(var_name,ppos) -> Hashtbl.find gvar var_name
      | Tab(left_value1,expr1,ppos) -> failwith "Tab not implemented"
  )

  | Moins(expr1,ppos) -> { typ = "int" ; value = "-"^(eval_expr expr1).value }


  | Not(expr1, ppos) -> {typ = "bool" ; value = (if String.equal (eval_expr expr1).value "True" = true then "False" else "True")}
 
  | Op(binop,expr1,expr2,ppos)->
    begin
    match (eval_expr expr1), (eval_expr expr2) with 
                     |a,b -> if String.equal a.typ b.typ = false then failwith "type mismatch"
                             else if String.equal a.typ "int" = true then
                              begin
                                match binop with
                                  | Add -> {typ = "int" ; value = string_of_int ((int_of_string a.value) + (int_of_string b.value))}
                                  | Sub -> {typ = "int" ; value = string_of_int ((int_of_string a.value) - (int_of_string b.value))}
                                  | Mul -> {typ = "int" ; value = string_of_int ((int_of_string a.value) * (int_of_string b.value))}
                                  | Div -> {typ = "int" ; value = string_of_int ((int_of_string a.value) / (int_of_string b.value))}
                                  | Mod -> {typ = "int" ; value = string_of_int ((int_of_string a.value) mod (int_of_string b.value))}
                                  | Leq -> {typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (eval_expr expr1).value <= int_of_string (eval_expr expr2).value)) }
                                  | Le -> {typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (eval_expr expr1).value < int_of_string (eval_expr expr2).value)) }
                                  | Geq -> {typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (eval_expr expr1).value >= int_of_string (eval_expr expr2).value)) }
                                  | Ge -> {typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (eval_expr expr1).value > int_of_string (eval_expr expr2).value)) }
                                  | Neq -> {typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (eval_expr expr1).value <> int_of_string (eval_expr expr2).value)) }
                                  | Eq -> {typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (eval_expr expr1).value == int_of_string (eval_expr expr2).value)) }
                                  | _ -> failwith "not implemented OP"
                              end 
                              else if String.equal a.typ "string" = true then
                                begin
                                  match binop with
                                    | Add -> {typ = "string" ; value = a.value^b.value}
                                    | _ -> failwith "not implemented OP"
                                end
                              else if String.equal a.typ "bool" = true then
                                begin
                                  match binop with
                                    | And -> {typ = "bool" ; value = (if String.equal a.value "True" = true && String.equal b.value "True" = true then "True" else "False")}
                                    | Or -> {typ = "bool" ; value = (if String.equal a.value "True" = true || String.equal b.value "True" = true then "True" else "False")}
                                    | Eq -> {typ = "bool" ; value = (if String.equal a.value b.value = true then "True" else "False")}
                                    | Neq -> {typ = "bool" ; value = (if String.equal a.value b.value = false then "True" else "False")}
                                    | _ -> failwith "not implemented OP"
                                end
                              else failwith "not implemented OP"
    end
    | List(expr_list, ppos) -> failwith "Lists not implemented"
   
    | Ecall(fun_name,expr_list,ppos)->   ( if String.equal fun_name "print"
                                       then (*begin (Printf.printf "%d\n" (match expr_list with | expr1::l -> (eval_expr expr1)
                                                                                              | _ -> failwith "someting went wrong in Ecall") 
                                                  ; 0)
                                            end *)
                                          match expr_list with
                                            | expr1::l -> (match (eval_expr expr1) with
                                                          | {typ = "int" ; value = v} -> Printf.printf "%d\n" (int_of_string v) ; {typ = "int" ; value = "0"}
                                                          | {typ = "string" ; value = v} -> Printf.printf "%s\n" v ; {typ = "int" ; value = "0"}
                                                          | {typ = "bool" ; value = v} -> Printf.printf "%s\n" v ; {typ = "int" ; value = "0"}
                                                          | {typ = "none" ; value = v} -> Printf.printf "%s\n" v ; {typ = "int" ; value = "0"}
                                                          | _ -> failwith "not implemented")
                                            | _ -> failwith "someting went wrong in Ecall"
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
