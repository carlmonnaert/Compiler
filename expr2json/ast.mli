(* Syntaxe abstraite pour notre langage *)

type ppos = Lexing.position * Lexing.position

type program = gdef list 

and gdef =
  | Function of type_var*string*declaration list*stmt list*ppos   
  | Gvar of type_var*string*ppos
  | GvarInit of type_var*string*expr*ppos
  | GTab of type_var*string*expr*ppos

and declaration = 
  | DECLARATION of type_var*string

and type_var =
  | TYPE_INT
  | TYPE_VOID
  | PTR of type_var

    
and stmt = 
  | While of expr*stmt list*ppos
  | IfElse of expr*stmt list*stmt list*ppos
  | IfNoElse of expr*stmt list*ppos
  | Read of string*ppos
  | Print_int of expr*ppos
  | Lvar of type_var*string*ppos
  | LvarInit of type_var*string*expr*ppos
  (* | LtabInit of string*expr*ppos *)
  | Return of expr*ppos
  | SetTab of string*expr*expr*ppos
  | Set of string*expr*ppos
  | SetPtr of string*expr*ppos
  | Expression of expr*ppos
  | Break of ppos
  | Continue of ppos

and expr = 
  | Cst of int*ppos
  | Var of string*ppos
  | Binop of binop * expr * expr*ppos
  | Unop of unop * expr * ppos
  | Call of string * expr list*ppos
  | Acces of string * expr * ppos



and binop = Add | Sub | Mul | Div | Mod | Eqeq | Noteq | Lt | Gt | Lteq | Gteq | And | Or | Not 
and unop = Deref | Adr 

val toJSON : program -> Yojson.t
