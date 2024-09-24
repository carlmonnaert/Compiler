
/* Analyseur syntaxique pour Arith */

%{
  open Ast

%}
// %token ALLCHAR
// %token COMMENT
%token <int> CST
%token <string> IDENT
%token PRINT, READ
%token EOF 
%token LP RP LB RB
%token PLUS MINUS TIMES DIV
%token EQ
%token SEMICOLON RETURN INT

/* D�finitions des priorit�s et associativit�s des tokens */

%left PLUS MINUS 
%left TIMES DIV
%nonassoc uminus

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
| INT id = IDENT LP INT arg = IDENT RP LB body = list(stmt)   RB            { Function(id,arg,body,$loc) }
;

stmt:
| PRINT LP e = expr RP SEMICOLON            { Print(e, $loc) }
| READ LP id = IDENT RP SEMICOLON           { Read(id, $loc) }
| INT id = IDENT SEMICOLON            { Lvar(id, $loc) }
| id = IDENT EQ e = expr SEMICOLON    { Set(id,e,$loc) }
| RETURN e = expr SEMICOLON           { Return(e,$loc) }
;
// randomText : ALLCHAR {}
// | ALLCHAR e = randomText {}
// ;

expr:
| c = CST                        { Cst(c,$loc) }
| fct = IDENT LP arg = expr RP                 { Call(fct,arg,$loc) }
| id = IDENT                     { Var(id,$loc) }
| e1 = expr o = op e2 = expr     { Binop (o, e1, e2, $loc) }
| MINUS e = expr %prec uminus    { Binop (Sub, Cst(0,$loc), e, $loc) } 
| LP e = expr RP                 { e }
;

%inline op:
| PLUS  { Add }
| MINUS { Sub }
| TIMES { Mul }
| DIV   { Div }
;



