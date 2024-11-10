
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
%token VOID
%token ADR


/* D�finitions des priorit�s et associativit�s des tokens */


%left AND OR
%left EQEQ NOTEQ LT GT LTEQ GTEQ 
%left NOT
%left PLUS MINUS 
%left TIMES DIV MOD
%right DEREF
%nonassoc uminus
// %nonassoc IF_NO_ELSE
// %nonassoc ADR


/* Point d'entr�e de la grammaire */
%start prog

/* Type des valeurs retourn�es par l'analyseur syntaxique */
%type <Ast.program> prog

%%

prog:
| p = list(def) EOF { p }
;



def:

| typeF = type_var id = IDENT LP args = separated_list(COMMA,declaration) RP LB body = list(stmt) RB { Function(typeF,id,args,body,$loc) }
| typeV = type_var id = IDENT SEMICOLON { Gvar(typeV,id, $loc) }
| typeV = type_var id = IDENT EQ e = expr SEMICOLON { GvarInit(typeV,id, e, $loc) }

;

declaration:
| typeV = type_var id = IDENT { DECLARATION(typeV,id) }
;

type_var:
| INT { TYPE_INT }
| VOID { TYPE_VOID }
| t = type_var TIMES { PTR(t) }
;



stmt:
| WHILE LP cond = expr RP LB body = list(stmt) RB { While(cond, body, $loc) }
| IF LP cond = expr RP LB body1 = list(stmt) RB ELSE LB body2 = list(stmt) RB { IfElse(cond, body1, body2, $loc) }
| IF LP cond = expr RP LB body = list(stmt) RB /*%prec IF_NO_ELSE*/ { IfNoElse(cond, body, $loc) }
| PRINT_INT LP e = expr RP SEMICOLON            { Print_int(e, $loc) }
| READ LP id = IDENT RP SEMICOLON           { Read(id, $loc) }
| tVar = type_var id = IDENT EQ e = expr SEMICOLON    { LvarInit(tVar,id,e,$loc) }
| tVar = type_var id = IDENT SEMICOLON            { Lvar(tVar,id, $loc) }
// | TIMES ide = expr EQ e = expr SEMICOLON           { SetPtr(ide,e,$loc) }
| id = IDENT EQ e = expr SEMICOLON    { Set(id,e,$loc) }
| RETURN e = expr SEMICOLON           { Return(e,$loc) }
| CONTINUE SEMICOLON                     { Continue($loc) }
| BREAK SEMICOLON                     { Break($loc) }
| e = expr SEMICOLON                     { Expression(e,$loc) }

;

expr:
| ADR e = expr %prec DEREF {  Binop(Adr, e, Cst(0,$loc), $loc) }
| TIMES e = expr %prec DEREF {  Binop(Deref, e, Cst(0,$loc), $loc) }
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



