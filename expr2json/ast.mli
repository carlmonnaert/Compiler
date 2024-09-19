(* Syntaxe abstraite pour notre langage *)

type ppos = Lexing.position * Lexing.position

type program = gdef list 

and gdef =
  | Function of string*string*stmt list*ppos   
  | Gvar of string*ppos

    
and stmt = 
  | Read of string*ppos
  | Print of expr*ppos
  | Lvar of string*ppos
  | Return of expr*ppos
  | Set of string*expr*ppos

and expr = 
  | Cst of int*ppos
  | Var of string*ppos
  | Binop of binop * expr * expr*ppos
  | Call of string * expr*ppos

and binop = Add | Sub | Mul | Div

val toJSON : program -> Yojson.t
