(* Syntaxe abstraite pour notre langage *)

type ppos = Lexing.position * Lexing.position

type program = gdef list 

and gdef =
  | Function of string*declaration list*stmt list*ppos   
  | Gvar of string*ppos
  | GvarInit of string*expr*ppos

and declaration = 
  | DECLARATION of type_var*string

and type_var =
  | TYPE_INT

    
and stmt = 
  | While of expr*stmt list*ppos
  | IfElse of expr*stmt list*stmt list*ppos
  | IfNoElse of expr*stmt list*ppos
  | Read of string*ppos
  | Print_int of expr*ppos
  | Lvar of string*ppos
  | LvarInit of string*expr*ppos
  | Return of expr*ppos
  | Set of string*expr*ppos
  | Expression of expr*ppos
  | Break of ppos
  | Continue of ppos

and expr = 
  | Cst of int*ppos
  | Var of string*ppos
  | Binop of binop * expr * expr*ppos
  | Call of string * expr list*ppos



and binop = Add | Sub | Mul | Div | Mod | Eqeq | Noteq | Lt | Gt | Lteq | Gteq | And | Or | Not

val toJSON : program -> Yojson.t
