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
  | Vpoint of string

type gen_value = 
  | Elementary of value
  | Combined of gen_value list

let ret = ref []
let bret = ref false

type func = {fun_name : string ; args : string list ; body : stmt ; mutable local_env : (string, gen_value) Hashtbl.t}

let gvar : (string, gen_value) Hashtbl.t = Hashtbl.create 10

let gfun : (string, func) Hashtbl.t = Hashtbl.create 10



(*Section d'affichage*)
let rec print_combined gv = match gv with
  | Elementary(Vpoint(x)) -> print_combined ( Hashtbl.find gvar x )
  | Elementary(Vint(x)) -> Printf.printf "%d" x
  | Elementary(Vstring(x)) -> print_string"'" ; Printf.printf "%s" x ; print_string "'"
  | Elementary(Vbool(x)) -> Printf.printf "%s" (match x with | true -> "True" |false -> "False")
  | Elementary(Vnone) -> print_string "None"
  | Combined(l) -> 
    begin
    Printf.printf "[";
    pretty_print_list l;
    end
and
pretty_print_list l = match l with
  | [] -> print_string "]"
  | [x] -> (print_combined x;print_string "]")
  | x::l1 -> (print_combined x; print_string ", "; pretty_print_list l1)

let rec print_gen_value gv = match gv with
  | Elementary(Vpoint(x)) -> print_gen_value (Hashtbl.find gvar x)
  | Elementary(Vint(x)) -> Printf.printf "%d\n" x
  | Elementary(Vstring(x)) -> Printf.printf "%s\n" x
  | Elementary(Vbool(x)) -> Printf.printf "%s\n" (match x with | true -> "True" |false -> "False")
  | Elementary(Vnone) -> print_string "None\n"
  | Combined(l) -> print_combined gv; print_string "\n"

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

let rec get_repres var_name local_e = (*suppose que x est de la forme Var(varname,ppos) *)
  match Hashtbl.find_opt local_e var_name with
    | Some(Elementary(Vpoint(pointed_var))) -> get_repres pointed_var local_e
    | _ -> var_name

let rec eval_expr expr local_e = match expr with
  | Const(const,ppos) -> begin
                          match const with 
                            | Int(str,ppos1) -> Elementary(Vint(int_of_string str))
                            | Str(str,ppos1) ->  Elementary(Vstring(str))
                            | Bool(b,ppos1) -> Elementary(Vbool(b))
                            | Non(ppos) -> Elementary(Vnone)                            
                         end

  | Val(left_value,ppos) ->
    begin
    match left_value with
      | Var(var_name,ppos1) when Hashtbl.mem local_e var_name -> 
        begin
          match (Hashtbl.find local_e var_name) with 
            | Elementary(Vpoint(var_name1)) -> eval_expr (Val(Var(var_name1,ppos1),ppos1)) local_e
            | x -> x
        end
      
      
      | Var(var_name,ppos1) when Hashtbl.mem gvar var_name -> Hashtbl.find gvar var_name
      | Var(var_name,ppos1) -> failwith "unfound value"
      (*| Tab(left_value1,expr1,ppos1) -> 
        begin
          match eval_expr (Val(left_value1,ppos1)) local_e, eval_expr expr1 local_e with
            | Combined(l) , Elementary(Vint(x)) -> (List.nth l x)
            | _ , _ -> failwith "invalid access in a Tab"
        end*)
      | Tab(expr1,expr2,ppos) -> 
        begin
          match eval_expr expr1 local_e, eval_expr expr2 local_e with
            | Combined(l) , Elementary(Vint(x)) -> (List.nth l x)
            | Elementary(Vnone) , _ -> Elementary(Vnone)
            | _ , Elementary(Vnone) -> Elementary(Vnone)
            | _ , _ -> failwith "invalid access in a Tab"
        end  



    end 

  | Moins(expr1,ppos) -> (match eval_expr expr1 local_e with | Elementary(Vint(x)) -> Elementary(Vint(-x)) | _ -> failwith "something went wrong in eval_expr : Moins")


  | Not(expr1, ppos) -> (match eval_expr expr1 local_e with | Elementary(Vbool(x)) -> if x = true then Elementary(Vbool(false)) else Elementary(Vbool(true)) | _ -> failwith "something went wrong in eval_expr : Not")
  | Op(binop,expr1,expr2,ppos)->
    begin
      match binop , eval_expr expr1 local_e , eval_expr expr2 local_e with
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
    
  | List(expr_list, ppos) -> Combined(List.map (fun x -> eval_expr x local_e ) expr_list)

  | Ecall(fun_name,expr_list,ppos) when String.equal fun_name "type" -> 
    begin
      match (match expr_list with | [e] -> eval_expr e local_e| _ -> failwith "wrong use of type function") with
      | Elementary(Vpoint(x)) -> Hashtbl.find local_e x
      | Elementary(Vint(x)) -> Elementary(Vstring("<class 'int'>"))
      | Elementary(Vstring(x)) -> Elementary(Vstring("<class 'str'>"))
      | Elementary(Vbool(x)) -> Elementary(Vstring("<class 'bool'>"))
      | Elementary(Vnone) -> Elementary(Vstring("<class 'NoneType'>"))
      | Combined(l) -> Elementary(Vstring("<class 'list'>"))
    end

  | Ecall(fun_name,expr_list,ppos) when String.equal fun_name "len" ->
    begin 
    match (match expr_list with | [e] -> eval_expr e (Hashtbl.copy local_e)| _ -> failwith "wrong use of len function") with
      | Combined(l) -> Elementary(Vint(List.length l))
      | _ -> failwith "misuse of len function"
    end


  | Ecall(fun_name,expr_list,ppos) when String.equal fun_name "print" ->
    begin
      match expr_list with
        | [expr1] -> (print_gen_value (eval_expr expr1 local_e); Elementary(Vnone) )
        | _ -> failwith "someting went wrong in print"
    end

  | Ecall(fun_name,expr_list,ppos) ->
    begin
    let f = Hashtbl.find gfun fun_name in
    List.iteri (fun i x -> Hashtbl.replace f.local_env x (eval_expr (List.nth expr_list i) (local_e) )) f.args;
    eval_stmt f.body (Hashtbl.copy f.local_env);
    if !bret = true then
      begin
      bret := false;
      match !ret with
        | x::ret1 -> ret := ret1; x
        | _ ->  failwith "erreur de retour"
      end
    else Elementary(Vnone)      

    end

and eval_stmt stmt local_e = match stmt with
  | Sfor(counter,expr,stmt,ppos) ->
    begin
      match eval_expr expr local_e with 
        | Combined(l) -> exec_list l counter stmt local_e
        | Elementary(e) -> failwith "unable to use for in something else than a list"
    end
  
  | Sblock(stmt_list, ppos) -> List.iter (fun x -> if !bret = false then eval_stmt x local_e else () ) stmt_list

  | Sreturn(expr,ppos) ->
    if !bret = false then 
    begin
    (
      ret := (eval_expr expr local_e) :: (!ret);
      bret := true;
    )
    end
    else ()
  | Sassign(left_value,expr,ppos) ->
    begin
    match left_value , expr , eval_expr expr local_e with
      | Var(var_name,ppos1) , Val(Var(var_name2,ppos2),ppos) , Combined(l) -> Hashtbl.replace local_e var_name2 (eval_expr expr local_e) ; Hashtbl.replace local_e var_name (Elementary(Vpoint(var_name2)))
      | Var(var_name,ppos1) , _ , _ when (match Hashtbl.find_opt local_e var_name with | Some(Elementary(Vpoint(x))) -> true | _ -> false ) = true -> Hashtbl.replace local_e (get_repres var_name local_e) (eval_expr expr local_e) 
      | Var(var_name,ppos1) , _ , _ -> Hashtbl.replace local_e var_name (eval_expr expr local_e)

      (*| Tab(expr_tab,expr_idx,p) -> 
        begin
        let valeur = eval_expr expr local_e in
        match eval_expr expr_tab local_e, eval_expr expr_idx local_e with
        |Combined(l), Elementary(Vint(i)) -> 
        let new_tab = (replace_in_lst l i valeur) in (*list of gen value*)
        (*eval_stmt (Sassign(Tab(expr_tab , expr_idx,ppos) , Val(new_value,ppos),ppos)) local_e*)
        eval_stmt (Sassign())
        |_ -> failwith "le tableau est au mauvais format"
        end *)
      | Tab(expr_tab,expr_idx,p), _ ,_-> 
        begin
        let t = eval_expr expr_tab local_e in
        let idx = eval_expr expr_idx local_e in
        let valeur = eval_expr expr  local_e in
        match t, idx with
        |Combined(l), Elementary(Vint(i)) -> (
          let new_lst = (uneval_general (Combined(replace_in_lst l i valeur)) ppos local_e ) in
          match expr_tab with
          |Val(lv, ppos2) -> eval_stmt (Sassign(lv, new_lst ,ppos2)) local_e
          |_ -> failwith "erreur de type : Sassign travaille sur des left_value" )
        |_ -> failwith "erreur de type : il faut un tableau"
        end          
    end
  | Sval(expr,ppos) -> (let _ = eval_expr expr local_e in () )

  | Sif(cond_expr,then_stmt,elif_expr_stmt_list,else_stmt_option,ppos) ->
    (*begin
      match eval_expr cond_expr local_e , else_stmt_option with
        | Elementary(Vbool(true)) , _ -> eval_stmt (Sblock(then_stmt,ppos)) local_e
        | Elementary(Vbool(false)) , None | Elementary(None) , None when List.length elif_expr_stmt_list == 0 -> ()
        | Elementary(Vbool(false)) , Some(else_stmt) when List.length elif_expr_stmt_list == 0 -> eval_stmt (Sblock(else_stmt,ppos)) local_e
        | Elementary(Vbool(false)) , _ when List.length elif_expr_stmt_list > 0 ->
          begin
            let cond1,stmt1 = (match elif_expr_stmt_list with | x::l1 -> x | _ -> failwith "Something went wrong in eval_stmt Sif") in
            let l1 = (match elif_expr_stmt_list with | x :: l1 -> l1  | _ -> failwith "Something went wrong in eval_stmt Sif") in
            eval_stmt (Sif(cond1,stmt1,l1,else_stmt_option,ppos)) local_e
          end
        | _ -> failwith "misuse of if"
        end*)

      begin
      match eval_expr cond_expr local_e with
        | Elementary(Vbool(true)) -> eval_stmt (Sblock(then_stmt,ppos)) local_e
        | Elementary(Vint(i)) when i <> 0 -> eval_stmt (Sblock(then_stmt,ppos)) local_e
        | Elementary(Vstring(s)) when String.equal s "" = false -> eval_stmt (Sblock(then_stmt,ppos)) local_e
        | Combined(lst) when (lst = []) = false -> eval_stmt (Sblock(then_stmt,ppos)) local_e
        | _ -> 
          begin 
            match  else_stmt_option with
            |None when List.length elif_expr_stmt_list == 0 -> ()
            |Some(else_stmt) when List.length elif_expr_stmt_list == 0 -> eval_stmt (Sblock(else_stmt,ppos)) local_e
            | _ when List.length elif_expr_stmt_list > 0 ->
              begin
                let cond1,stmt1 = (match elif_expr_stmt_list with | x::l1 -> x | _ -> failwith "Something went wrong in eval_stmt Sif") in
                let l1 = (match elif_expr_stmt_list with | x :: l1 -> l1  | _ -> failwith "Something went wrong in eval_stmt Sif") in
                eval_stmt (Sif(cond1,stmt1,l1,else_stmt_option,ppos)) local_e
              end
            | _ -> failwith "unmatched case in if"
            end
      end

  | Swhile(cond_expr,body_stmt,ppos) ->
    begin
      match eval_expr cond_expr local_e with
        | Elementary(Vbool(true)) -> eval_stmt (Sblock(body_stmt,ppos)) local_e; eval_stmt (Swhile(cond_expr,body_stmt,ppos)) local_e
        | Elementary(Vbool(false)) -> ()
        | _ -> failwith "misuse of while"
    end


and exec_list l counter stmt local_e = match l with
    | [] -> ()
    | y::l1 -> 
      begin 
      Hashtbl.replace gvar counter y;
      eval_stmt stmt local_e;
      exec_list l1 counter stmt local_e
      end

  
  and replace_in_lst lst j x = 
    List.mapi (fun i elt -> if i=j then x else elt) lst

  and uneval value ppos local_e = match value with
  |Vpoint(x) -> uneval_general (Hashtbl.find local_e x) ppos local_e
  |Vint(x) -> Const(Int(string_of_int x, ppos),ppos)
  |Vbool(x) -> Const(Bool(x, ppos), ppos)
  |Vstring(x) -> Const(Str(x, ppos), ppos)
  |Vnone -> Const(Non(ppos), ppos)
  
  and uneval_general gv ppos local_e = match gv with
  |Elementary(v) -> uneval v ppos local_e
  |Combined(lst) ->
    List((List.map (fun v -> uneval_general v ppos local_e) lst), ppos)

    (* begin
      match lst with
      |[] -> failwith "liste vide"
      |[x] -> uneval_general x ppos
      |x::q -> =
    end *)

    (* uneval_g_lst lst ppos
  |_ -> failwith "erreur"

  and uneval_g_lst lst ppos = match lst with
  |[] -> []
  |x::q -> (uneval_general x ppos)::(uneval_g_lst Combined(q) ppos) *)

    (*
    begin
      match lst with
      |[] -> []
      |v::q -> (uneval_general v ppos)::(uneval_general q ppos)
    end*)

let eval_global_stmt gstmt = match gstmt with
  |Gstmt(stmt,ppos) -> (eval_stmt stmt gvar)
  |GFunDef(fun_name,var_list,stmt,ppos) -> 
    begin
    Hashtbl.replace gfun fun_name { fun_name = fun_name ; args = var_list ; body = stmt ; local_env = Hashtbl.copy gvar };
    end
;;

let eval program_ast  = List.iter eval_global_stmt program_ast;;
