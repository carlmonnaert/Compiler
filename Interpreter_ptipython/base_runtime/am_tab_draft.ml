
and eval_stmt stmt local_e = match stmt with

| Sassign(left_value,expr,ppos) ->
  begin
  match left_value with
    | Var(var_name,ppos1) -> Hashtbl.replace local_e var_name (eval_expr expr local_e)
    | Tab(expr_tab,expr_idx,p) -> 
      let valeur = eval_expr expr in
      match eval_expr expr_tab local_e, eval_expr expr_idx local_e with
      |Combined(l), Elementary(Vint(i)) -> 
      let new_value = (replace_in_lst l i valeur) in
      eval_stmt Val(expr_tab, new_value)
      end
  end

                  (*left_value*)                                          (*expr*) (*ppos*)
eval_stmt Sassign(Tab(Tab(Val(Var("t")), Const(Int(0)))), Const(Int(1))), ["b"], ppos) =
let t_0 = eval_expr Tab(Val(Var("t")), Const(Int(0))) in 
let new_t_0 = replace t_0 1 ["b"] in
eval_stmt Sassign(Tab(Val(Var("t")), Const(Int(0)))), new_t0, ppos
(*l'arg est un tableau  *)

= let t_ = eval_expr Val(Var("t")) in
let new_t = replace t_ 0 new_t0 in
eval_smtt Sassign(Val(Var("t")), new_t, ppos)
(* l'arg est une valeur*)

| Sassign(left_value,expr,ppos) ->
  begin
  match left_value with
    | Var(var_name,ppos1) -> Hashtbl.replace local_e var_name (eval_expr expr local_e)
    | Tab(expr_tab,expr_idx,p) -> 
      let t = eval_expr expr_tab local_e in
      let idx = eval_expr expr_idx local_e in
      let valeur = eval_expr expr  local_e in
      match t, idx with
      |Combined(l), Val(Int(i)) -> (
        let new_lst = replace_in_lst l i valeur in
        match expr_tab with
        |Val(lv) -> Sassign(lv, Combined(new_lst),ppos)
        |_ -> "erreur de type : Sassign travaille sur des left_value")
      |_ -> "erreur de type : il faut un tableau"
      
      






let replace_in_lst lst j x = 
  List.mapi (fun i elt -> if i=j then x else elt) lst ;;

let eval_expr expr local_e = match expr with
| Val(left_value,ppos) ->
  begin
  match left_value with
    | Var(var_name,ppos1) when Hashtbl.mem local_e var_name -> Hashtbl.find local_e var_name
    |Tab(left_value1,expr1,ppos1) -> 
      begin
        match eval_expr (Val(left_value1,ppos1)) local_e, eval_expr expr1 local_e with
          | Combined(l) , Elementary(Vint(x)) -> (List.nth l x)
          | _ , _ -> failwith "invalid access in a Tab"
      end



