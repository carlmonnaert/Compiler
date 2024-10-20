(*type lst_or_elt =
|Elt of int 
|Lst of lst_or_elt list

let rec print a = match a with
|Elt(x) -> print_int x
|Lst(lst) -> 
  begin
  match lst with
  |[] -> ()
  |x::q -> (print x ; print (Lst(q)))
  end ;;
*)
type ppos = Lexing.position * Lexing.position


type const = 
  | Int of string * ppos
  | Str of string * ppos
  | Bool of bool * ppos
  | Non of ppos

  and left_value = 
    | Tab of  expr*expr * ppos
    | Var of string * ppos

  and expr =
    | Const of const * ppos
    | Val of left_value *  ppos
    | Moins of expr * ppos
    | Not of expr * ppos
    | Op of binop * expr*expr * ppos
    | List of expr list * ppos
    | Ecall of string*expr list * ppos
  and binop = Add | Sub | Mul | Div | Mod | Leq | Le | Geq | Ge | Neq | Eq | And | Or

and value = 
  | Vint of int
  | Vstring of string
  | Vbool of bool
  | Vnone

type gen_value = 
  | Elementary of value
  | Combined of gen_value list


let rec uneval value ppos = match value with
|Vint(x) -> Const(Int(string_of_int x, ppos),ppos)
|Vbool(x) -> Const(Bool(x, ppos), ppos)
|Vstring(x) -> Const(Str(x, ppos), ppos)
|Vnone -> Const(Non(ppos), ppos)

and uneval_general gv ppos = match gv with
|Elementary(v) -> uneval v ppos
|Combined(lst) -> 
match lst with
|[] -> failwith "liste vide"
|[x] -> uneval_general x ppos
|x::q -> List((uneval_general x ppos)::List((uneval_general (Combined(q)) ppos), ppos))

