# Description :
You will find **2 subprojects** in this repository :
- A C compiler for RISK-V architectures handlind the main features of the C language (such as pointers).
- An interpreter for a simplified version of Python (that we called PtiPython), which interprets Python code in C

# Getting started :
## C compiler
For this project, the files are located in [eval_micro_C](eval_micro_C). To use the compiler, write C code in [file.c](file.c) and run [cc.sh](cc.sh)

```bash
./cc.sh
```
Here are the features handled by the compiler:
- assigning global variables (bool, int, string, pointers)
- for loops, while loops
- defining functions (non recursive only)
- defining local variables in functions
- evaluating expressions (artihmetic, logic, strings)
- printf

## PtiPython interpreter
For this project, the files are located in [Interpreter_ptipython](Interpreter_ptipython). To use the interpreter, write python code in [file.py](file.py) and run [ptipython.sh](ptipython.sh)

Just write the following in your terminal when located at the root of the project:

```bash
./ptipython.sh
```
Here is an extract of the [ast](/Interpreter_ptipython/base_json/ast.ml) file that contains the handled features :
```python
type ppos = Lexing.position * Lexing.position

type program = global_stmt list
 and global_stmt =
   | GFunDef of string * string list * stmt * ppos
   | Gstmt of stmt * ppos
and stmt =  
  | Sfor of string*expr*stmt * ppos
  | Sblock of stmt list  * ppos
  | Sreturn of expr * ppos
  | Sassign of left_value*expr * ppos
  | Sval of expr * ppos
  | Sif of expr * stmt * (expr * stmt) list * stmt option * ppos

and const = 
  | Int of string * ppos
  | Str of string * ppos
  | Bool of bool * ppos
  | Non of ppos

and left_value = 
  | Tab of expr*expr * ppos
  | Var of string * ppos

and expr =
  | Const of const * ppos
  | Val of left_value * ppos
  | Moins of expr * ppos
  | Not of expr * ppos
  | Op of binop * expr*expr * ppos
  | List of expr list * ppos
  | Ecall of string*expr list * ppos
and binop = Add | Sub | Mul | Div | Mod | Leq | Le | Geq | Ge | Neq | Eq | And | Or
```
