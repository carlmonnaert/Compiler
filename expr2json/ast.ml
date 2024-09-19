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

let binopname = function
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Div -> "/"

let pos ((s,e):ppos) =
  [ "start_line",`Int s.pos_lnum ;
    "start_char",`Int (s.pos_cnum-s.pos_bol) ;
    "end_line",`Int e.pos_lnum ;
    "end_char",`Int (e.pos_cnum-e.pos_bol) ]

  
let rec toJSONexpr = function
  | Cst(i,p) -> `Assoc (["type", `String "cst" ; "value", `Int i] @ pos p)
  | Var(s,p) -> `Assoc (["type", `String "var" ; "name", `String s] @ pos p)
  | Binop (b,e1,e2,p) -> `Assoc ([
                            "type", `String "binop" ;
                            "binop", `String (binopname b);
                            "e1", toJSONexpr e1 ;
                            "e2", toJSONexpr e2] @ pos p)
  | Call(funname, argvalue,p) ->
     `Assoc ([
        "type", `String "application" ;
        "function", `String funname ;
        "argvalue", toJSONexpr argvalue ]@pos p)
    
    
let toJSONinst = function
  | Read(x,p)  -> `Assoc (["action", `String "read";   "var", `String x]@pos p)
  | Print(e,p) -> `Assoc (["action", `String "print";  "expr", toJSONexpr e]@pos p)
  | Lvar(s,p) -> `Assoc (["action", `String "vardef";  "name", `String s]@pos p)
  | Set(s,v,p) -> `Assoc (["action", `String "varset"; "name", `String s; "expr", toJSONexpr v]@pos p)
  | Return(e,p) -> `Assoc (["action", `String "return";"expr", toJSONexpr e]@pos p)
                                   
let toJSONdef = function
  | Gvar(name, p)  -> `Assoc (["action", `String "gvardef";
                                             "name", `String name ]@pos p)
  | Function(name,varname,expr,p) -> `Assoc (["action", `String "fundef";
                                             "name", `String name ;
                                             "arg", `String varname ;
                                             "body", `List (List.map toJSONinst expr)]@pos p)


                                   
let toJSON p =
  `List (List.map toJSONdef p)


