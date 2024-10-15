open Ast ;;
open Hashtbl ;;
open Printf ;;
open String ;;
 
exception  Error of string ;;
exception  RuntimeError of string * Lexing.position ;;

type value = {typ : string ; value : string};;

type gen_value = 
  | Elementary of value
  | Combined of gen_value list

let gvar : (string, gen_value) Hashtbl.t = Hashtbl.create 10

let print_gen_value gv = match gv with
| Elementary({typ = "int" ; value = v}) -> Printf.printf "%d\n" (int_of_string v)
| Elementary({typ = "string" ; value = v}) -> Printf.printf "%s\n" v
| Elementary({typ = "bool" ; value = v}) -> Printf.printf "%s\n" v
| Elementary({typ = "none" ; value = v}) -> Printf.printf "%s\n" v
| Combined(l) ->
    let rec print_combined gval = match gval with
    | Elementary({typ = "int" ; value = v}) -> Printf.printf "%d," (int_of_string v)
    | Elementary({typ = "string" ; value = v}) -> Printf.printf "%s," v
    | Elementary({typ = "bool" ; value = v}) -> Printf.printf "%s," v
    | Elementary({typ = "none" ; value = v}) -> Printf.printf "%s," v
    | Combined(l) -> 
      begin
        Printf.printf "[";
        List.iter print_combined l ;
        Printf.printf "]";
      end
    in (print_combined ; Printf.printf "\n")
| _ -> failwith "unknown type to print"

let toPyBool = function
  | "true" -> "True"
  | "false" -> "False"
  | _ -> failwith "not a boolean"



let rec eval_expr expr = match expr with
  | Const(const,ppos) -> begin
                          match const with 
                            | Int(str,ppos1) -> Elementary({typ = "int"; value = str})
                            | Str(str,ppos1) ->  Elementary({typ = "string"; value = str})
                            | Bool(b,ppos1) -> Elementary({typ = "bool"; value = toPyBool (string_of_bool b)})
                            | Non(ppos) -> Elementary({typ = "none"; value ="None"})                            
                         end

  | Val(left_value,ppos) -> (
    match left_value with 
      | Var(var_name,ppos) -> Hashtbl.find gvar var_name
      | Tab(left_value1,expr1,ppos) -> failwith "Tab not implemented"
  )

  | Moins(expr1,ppos) -> Elementary({ typ = "int" ; value = "-"^(match eval_expr expr1 with | Elementary(x) -> x | _ -> failwith "unintended combined element").value })


  | Not(expr1, ppos) -> Elementary({typ = "bool" ; value = (if String.equal (match eval_expr expr1 with | Elementary(x) -> x | _ -> failwith "unintended combined element").value "True" = true then "False" else "True")})
 
  | Op(binop,expr1,expr2,ppos)->
    begin
    match (eval_expr expr1), (eval_expr expr2) with 
                     |Elementary(a),Combined(l) -> failwith "type mismatch"
                     |Combined(l),Elementary(a) -> failwith "type mismatch"
                     |Combined(l),Combined(s) -> failwith "not implemented OP on Combined * Combined"
                     |Elementary(a),Elementary(b) -> if String.equal a.typ b.typ = false then failwith "type mismatch"
                             else if String.equal a.typ "int" = true then
                              begin
                                match binop with
                                  | Add -> Elementary({typ = "int" ; value = string_of_int ((int_of_string a.value) + (int_of_string b.value))})
                                  | Sub -> Elementary({typ = "int" ; value = string_of_int ((int_of_string a.value) - (int_of_string b.value))})
                                  | Mul -> Elementary({typ = "int" ; value = string_of_int ((int_of_string a.value) * (int_of_string b.value))})
                                  | Div -> Elementary({typ = "int" ; value = string_of_int ((int_of_string a.value) / (int_of_string b.value))})
                                  | Mod -> Elementary({typ = "int" ; value = string_of_int ((int_of_string a.value) mod (int_of_string b.value))})
                                  | Leq -> Elementary({typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (match eval_expr expr1 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value <= int_of_string (match eval_expr expr2 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value)) })
                                  | Le -> Elementary({typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (match eval_expr expr1 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value < int_of_string (match eval_expr expr2 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value)) })
                                  | Geq -> Elementary({typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (match eval_expr expr1 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value >= int_of_string (match eval_expr expr2 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value)) })
                                  | Ge -> Elementary({typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (match eval_expr expr1 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value > int_of_string (match eval_expr expr2 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value)) })
                                  | Neq -> Elementary({typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (match eval_expr expr1 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value <> int_of_string (match eval_expr expr2 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value)) })
                                  | Eq -> Elementary({typ = "bool" ; value = toPyBool (string_of_bool ( int_of_string (match eval_expr expr1 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value == int_of_string (match eval_expr expr2 with |Elementary(x) -> x | _ -> failwith "unintended combined element").value)) })
                                  | _ -> failwith "not implemented OP"
                              end 
                              else if String.equal a.typ "string" = true then
                                begin
                                  match binop with
                                    | Add -> Elementary({typ = "string" ; value = a.value^b.value})
                                    | _ -> failwith "not implemented OP"
                                end
                              else if String.equal a.typ "bool" = true then
                                begin
                                  match binop with
                                    | And -> Elementary({typ = "bool" ; value = (if String.equal a.value "True" = true && String.equal b.value "True" = true then "True" else "False")})
                                    | Or -> Elementary({typ = "bool" ; value = (if String.equal a.value "True" = true || String.equal b.value "True" = true then "True" else "False")})
                                    | Eq -> Elementary({typ = "bool" ; value = (if String.equal a.value b.value = true then "True" else "False")})
                                    | Neq -> Elementary({typ = "bool" ; value = (if String.equal a.value b.value = false then "True" else "False")})
                                    | _ -> failwith "not implemented OP"
                                end
                              else failwith "not implemented OP"
    end
    | List(expr_list, ppos) -> Combined(List.map eval_expr expr_list)
   
    | Ecall(fun_name,expr_list,ppos)->   ( if String.equal fun_name "print"
                                       then match expr_list with
                                              | [expr1] -> (print_gen_value (eval_expr expr1); Elementary({typ = "none" ; value = "None"}) )
                                              | _ -> failwith "someting went wrong in print"
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
