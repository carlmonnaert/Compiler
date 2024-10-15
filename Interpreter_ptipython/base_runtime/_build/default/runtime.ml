open Ast ;;
open Hashtbl ;;
open Printf ;;
open String ;;
 
exception  Error of string ;;
exception  RuntimeError of string * Lexing.position ;;

type value = 
  | Vint of int
  | Vstring of string
  | Vbool of bool
  | Vnone

type gen_value = 
  | Elementary of value
  | Combined of gen_value list

let gvar : (string, gen_value) Hashtbl.t = Hashtbl.create 10


(*Section d'affichage*)
let rec print_combined gv = match gv with
  | Elementary(Vint(x)) -> Printf.printf "%d" x
  | Elementary(Vstring(x)) -> print_string"'" ; Printf.printf "%s" x ; print_string "'"
  | Elementary(Vbool(x)) -> Printf.printf "%s" (match x with | true -> "True" |false -> "False")
  | Combined(l) -> 
    begin
    Printf.printf "[";
    pretty_print_list l;
    end
  | _ -> failwith "unknown type to print"
and
pretty_print_list l = match l with
  | [] -> print_string "]"
  | [x] -> (print_combined x;print_string "]")
  | x::l1 -> (print_combined x; print_string ","; pretty_print_list l1)

let print_gen_value gv = match gv with
  | Elementary(Vint(x)) -> Printf.printf "%d\n" x
  | Elementary(Vstring(x)) -> Printf.printf "%s\n" x
  | Elementary(Vbool(x)) -> Printf.printf "%s\n" (match x with | true -> "True" |false -> "False")
  | Combined(l) -> print_combined gv; print_string "\n"
  | _ -> failwith "unknwown type to print"

(*Section de comparaison/conversion de types*)
let rec cmp_gen_leq x y = match x,y with
    |Elementary(Vint(x1)),Elementary(Vint(y1)) -> x1 <= y1
    |Elementary(Vstring(x1)),Elementary(Vstring(y1)) -> (String.compare (x1) (y1) ) <= 0 (*Str.compare envoie 0 si égalité 1 si le premier est plus grand -1 si le deuxieme est plus grand*)
    |Elementary(Vbool(x1)),Elementary(Vbool(y1))-> failwith "arithmetics not implemented  on bools"
    |Combined(l1),Combined(l2) -> 
      begin 
        match l1,l2 with
          | [] , [] -> true
          | [] , l2 -> true
          | l1 , [] -> false
          | x2::l11 , y2::l22 -> if (cmp_gen_leq x2 y2) = true && (cmp_gen_leq y2 x2) = true then cmp_gen_leq (Combined(l11)) (Combined(l22))
                                 else cmp_gen_leq x2 y2
      end
    | _ , _ -> failwith "Unable to compare diffenrently typed elements"

let rec eval_expr expr = match expr with
  | Const(const,ppos) -> begin
                          match const with 
                            | Int(str,ppos1) -> Elementary(Vint(int_of_string str))
                            | Str(str,ppos1) ->  Elementary(Vstring(str))
                            | Bool(b,ppos1) -> Elementary(Vbool(b))
                            | Non(ppos) -> Elementary(Vnone)                            
                         end

  | Val(left_value,ppos) -> (
    match left_value with 
      | Var(var_name,ppos) -> Hashtbl.find gvar var_name
      | Tab(left_value1,expr1,ppos) -> failwith "Tab not implemented"
  )

  | Moins(expr1,ppos) -> (match eval_expr expr1 with | Elementary(Vint(x)) -> Elementary(Vint(-x)) | _ -> failwith "something went wrong in eval_expr : Moins")


  | Not(expr1, ppos) -> (match eval_expr expr1 with | Elementary(Vbool(x)) -> if x = true then Elementary(Vbool(false)) else Elementary(Vbool(true)) | _ -> failwith "something went wrong in eval_expr : Not")
  | Op(binop,expr1,expr2,ppos)->
    begin
      match binop , eval_expr expr1, eval_expr expr2 with
        | Add , Elementary(Vint(x)) , Elementary(Vint(y)) -> Elementary(Vint(x+y))
        | Add , Elementary(Vstring(x)) , Elementary(Vstring(y))-> Elementary(Vstring (x^y))
        | Add , Combined(lx), Combined(ly) -> Combined(lx @ ly)
        | Sub , Elementary(Vint(x)) , Elementary(Vint(y)) -> Elementary(Vint(x-y))
        | Mul , Elementary(Vint(x)) , Elementary(Vint(y)) -> Elementary(Vint(x*y))
        | Div , Elementary(Vint(x)) , Elementary(Vint(y)) -> Elementary(Vint(x/y))
        | Mod , Elementary(Vint(x)) , Elementary(Vint(y)) -> Elementary(Vint(x mod y))
        | Leq , x , y -> Elementary(Vbool(cmp_gen_leq x y ))
        | Le , x , y -> Elementary(Vbool( (cmp_gen_leq x y) && not (cmp_gen_leq y x && cmp_gen_leq x y) ))
        | Geq , x , y -> Elementary(Vbool(cmp_gen_leq y x))
        | Ge , x , y -> Elementary(Vbool( (cmp_gen_leq y x) && not (cmp_gen_leq y x && cmp_gen_leq x y) ))
        | Eq , x , y -> Elementary(Vbool(cmp_gen_leq x y && cmp_gen_leq y x ))
        | Neq , x , y -> Elementary(Vbool(not (cmp_gen_leq x y && cmp_gen_leq y x )))
        | And , Elementary(Vbool(x)) , Elementary(Vbool(y)) -> Elementary(Vbool(x && y))
        | Or , Elementary(Vbool(x)) , Elementary(Vbool(y)) -> Elementary(Vbool(x || y))
        | _ , _ , _ -> failwith "eval_expr : not implemented binop"
    end
    
    | List(expr_list, ppos) -> Combined(List.map eval_expr expr_list)
   
    | Ecall(fun_name,expr_list,ppos)->   ( if String.equal fun_name "print"
                                       then match expr_list with
                                              | [expr1] -> (print_gen_value (eval_expr expr1); Elementary(Vnone) )
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
