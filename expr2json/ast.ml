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


let rec type_to_string x =
  match x with
  | TYPE_INT -> "int"
  | TYPE_VOID -> "void"
  | PTR t -> type_to_string t ^ "*"

let binopname = function
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Eqeq -> "=="
  | Noteq -> "!="
  | Lt -> "<"
  | Gt -> ">"
  | Lteq -> "<="
  | Gteq -> ">="
  | And -> "&&"
  | Or -> "||"
  | Not -> "!"

  let unopname = function
  | Deref -> "*"
  | Adr -> "&"



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
  | Unop (u,e,p) -> `Assoc ([ "type", `String "unop" ;
                              "unop", `String (unopname u);
                              "e", toJSONexpr e] @ pos p)
  | Call(funname, args,p) ->
     `Assoc ([
        "type", `String "application" ;
        "function", `String funname ;
        "args", `List (List.map toJSONexpr args) ]@pos p)
  | Acces(s,e,p) -> `Assoc (["type", `String "acces" ; "name", `String s; "expr", toJSONexpr e]@pos p)
    
    
let rec toJSONinst = function
  | Read(x,p)  -> `Assoc (["action", `String "read";   "var", `String x]@pos p)
  | Print_int(e,p) -> `Assoc (["action", `String "print_int";  "expr", toJSONexpr e]@pos p)
  | Lvar(t,s,p) -> `Assoc (["type" , `String (type_to_string t) ;"action", `String "vardef";  "name", `String s]@pos p)
  | LvarInit(t,s,v,p) -> `Assoc (["type" , `String (type_to_string t) ; "action", `String "varinitdef"; "name", `String s; "expr", toJSONexpr v]@pos p)
  | SetTab(s,i,v,p) -> `Assoc (["action", `String "tabset"; "name", `String s; "index", toJSONexpr i; "expr", toJSONexpr v]@pos p)
  | Set(s,v,p) -> `Assoc (["action", `String "varset"; "name", `String s; "expr", toJSONexpr v]@pos p)
  | SetPtr(s,v,p) -> `Assoc (["action", `String "ptrset"; "name", `String s; "expr", toJSONexpr v]@pos p)
  | Return(e,p) -> `Assoc (["action", `String "return";"expr", toJSONexpr e]@pos p)
  | Break(p) -> `Assoc (["action", `String "break"]@pos p)
  | Continue(p) -> `Assoc (["action", `String "continue"]@pos p)
  | Expression(e,p) -> `Assoc (["action", `String "expression";"expr", toJSONexpr e]@pos p)
  | IfElse(cond, body1, body2, p) -> `Assoc (["action", `String "ifelse";
                                               "cond", toJSONexpr cond;
                                               "then", `List (List.map toJSONinst body1);
                                               "else", `List (List.map toJSONinst body2)]@pos p)
  | IfNoElse(cond, body, p) -> `Assoc (["action", `String "ifnoelse";
                                        "cond", toJSONexpr cond;
                                        "then", `List (List.map toJSONinst body)]@pos p)
  | While(cond, body, p) -> `Assoc (["action", `String "while";
                                      "cond", toJSONexpr cond;
                                      "body", `List (List.map toJSONinst body)]@pos p)
  


                                   
let toJSONargs = function
  | DECLARATION(typeV,id) -> `Assoc (["type", `String (type_to_string typeV) ;"name", `String id; ])

let toJSONdef = function
  | Gvar(t,name, p)  -> `Assoc (["type" , `String (type_to_string t) ;"action", `String "gvardef";
                                             "name", `String name ]@pos p)
  | GvarInit(t, name,expr,p) -> `Assoc (["type", `String (type_to_string t) ;"action", `String "gvarinitdef";
                                              "name", `String name ;
                                              "expr", toJSONexpr expr]@pos p) 
  | GTab(t, name,expr,p) -> `Assoc (["type", `String ((type_to_string t)^"[]") ;"action", `String "gtabdef";
                                              "name", `String name ;
                                              "expr", toJSONexpr expr]@pos p)
  | Function(typee,name,args,expr,p) -> `Assoc (["type", `String (type_to_string typee);
                                             "action", `String "fundef";
                                             "name", `String name ;
                                             "args", `List (List.map toJSONargs args); 
                                             "body", `List (List.map toJSONinst expr)]@pos p)


                                   
let toJSON p =
  `List (List.map toJSONdef p)


