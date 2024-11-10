
/* Analyseur syntaxique pour Arith */

%{
  open Ast

%}
// %token ALLCHAR
// %token COMMENT
%token <int> CST
%token <string> IDENT
%token PRINT_INT, READ
%token EOF 
%token LP RP COMMA LB RB
%token PLUS MINUS TIMES DIV MOD
%token EQ
%token SEMICOLON RETURN INT
%token EQEQ NOT NOTEQ LT GT LTEQ GTEQ
%token AND OR 
%token IF ELSE WHILE
%token CONTINUE BREAK


/* D�finitions des priorit�s et associativit�s des tokens */


%right EQ
%left AND OR
%left EQEQ NOTEQ LT GT LTEQ GTEQ 
%left NOT
%left PLUS MINUS 
%left TIMES DIV MOD
%nonassoc uminus
%nonassoc IF_NO_ELSE
%nonassoc ELSE


/* Point d'entr�e de la grammaire */
%start prog

/* Type des valeurs retourn�es par l'analyseur syntaxique */
%type <Ast.program> prog

%%

prog:
| p = list(def) EOF { p }
;



def:
| INT id = IDENT SEMICOLON { Gvar(id, $loc) }
| INT id = IDENT EQ e = expr SEMICOLON { GvarInit(id, e, $loc) }
| INT id = IDENT LP args = separated_list(COMMA,declaration) RP LB body = list(stmt)   RB            { Function(id,args,body,$loc) }
;

declaration:
| typeV = type_var id = IDENT { DECLARATION(typeV,id) }
;

type_var:
| INT { TYPE_INT }
;



stmt:
| WHILE LP cond = expr RP LB body = list(stmt) RB { While(cond, body, $loc) }
| IF LP cond = expr RP LB body1 = list(stmt) RB ELSE LB body2 = list(stmt) RB { IfElse(cond, body1, body2, $loc) }
| IF LP cond = expr RP LB body = list(stmt) RB %prec IF_NO_ELSE { IfNoElse(cond, body, $loc) }
| PRINT_INT LP e = expr RP SEMICOLON            { Print_int(e, $loc) }
| READ LP id = IDENT RP SEMICOLON           { Read(id, $loc) }
| INT id = IDENT SEMICOLON            { Lvar(id, $loc) }
| INT id = IDENT EQ e = expr SEMICOLON    { LvarInit(id,e,$loc) }
| id = IDENT EQ e = expr SEMICOLON    { Set(id,e,$loc) }
| RETURN e = expr SEMICOLON           { Return(e,$loc) }
| e = expr SEMICOLON                     { Expression(e,$loc) }
| CONTINUE SEMICOLON                     { Continue($loc) }
| BREAK SEMICOLON                     { Break($loc) }
;

expr:
| c = CST                        { Cst(c,$loc) }
| fct = IDENT LP args = separated_list(COMMA,expr) RP                 { Call(fct,args,$loc) }
| id = IDENT                     { Var(id,$loc) }
| NOT e = expr                   { Binop (Not, e, Cst(0,$loc), $loc) }
| e1 = expr o = op e2 = expr     { Binop (o, e1, e2, $loc) }
| MINUS e = expr %prec uminus    { Binop (Sub, Cst(0,$loc), e, $loc) } 
| LP e = expr RP                 { e }
;

%inline op:
| PLUS  { Add }
| MINUS { Sub }
| TIMES { Mul }
| DIV   { Div }
| MOD   { Mod }
| EQEQ  { Eqeq }
| NOTEQ { Noteq }
| LT    { Lt }
| GT    { Gt }
| LTEQ  { Lteq }
| GTEQ  { Gteq }
| AND   { And }
| OR    { Or }
| NOT  { Not }


;



