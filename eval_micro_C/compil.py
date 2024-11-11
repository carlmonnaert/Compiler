import sys
import json




class Interpret_exception(BaseException):
    def __init__(self, msg, term):
        pos = (term["start_line"],term["start_char"],term["end_line"],term["end_char"])
        self.msg = msg + (" at positions (%d,%d)-(%d,%d)"%pos)


def codeFromPos(pos):   # take Pos and return a code for the label (if or while)
    return f"{pos['start_line']}{pos['start_char']}{pos['end_line']}{pos['end_char']}"

list_data = []
list_instr = []




functions = {}

def stringOfPos(pos):
    return f"({pos['start_line']},{pos['start_char']})-({pos['end_line']},{pos['end_char']})"

def eval_program(program):
    list_data.append("\t.data")
    list_data.append("format:")
    list_data.append("\t.string \"%d\\n\"") 
    # for scanf
    list_data.append("format2:")
    list_data.append("\t.string \"%d\"")
    for stmt in program:
        if stmt["action"] == "fundef":
            functions[stmt["name"]] = len(stmt["args"])
    
    for stmt in program:                             # the arguments are in positive and the local variables in negative
        if stmt["action"] == "fundef":
            list_instr.append("\t.text")
            list_instr.append("\t.globl " + stmt["name"])
            list_instr.append(stmt["name"] + ":")
            x = 1
            local_env = {}
            for t in stmt["args"]:
                local_env[t["name"]] = {"index" : x,  "type" : t["type"]}
                x += 1
            
            x = -1
            for t in stmt["body"]:
                if t["action"] == "vardef" or t["action"] == "varinitdef":
                    local_env[t["name"]] = {"index" : x, "type" : t["type"]}
                    x -= 1
            list_instr.append("\tpush %rbp")
            list_instr.append("\tmov %rsp, %rbp")  
            
            tmp = 0
            for t in local_env:
                if local_env[t]["index"] < 0:
                    tmp += 1
            list_instr.append("\tsub $%d, %%rsp"%(tmp*8+8))
            eval_stmt(stmt["body"], local_env)
            list_instr.append("\tleave")
            list_instr.append("\tret")

            

        elif stmt["action"] == "gvardef" :
            list_data.append(".globl  %s"%stmt["name"])
            list_data.append("%s:"%stmt["name"])
            list_data.append("\t.quad 0")
        
        elif stmt["action"] == "gvarinitdef":
            list_data.append(".globl  %s"%stmt["name"])
            list_data.append("%s:"%stmt["name"])
            if stmt["expr"]["type"] == "cst":
                list_data.append("\t.quad %d"%stmt["expr"]["value"])
            else:
                raise Interpret_exception("Not a constant", stmt["expr"])
        elif stmt["action"] == "gtabdef":
            list_data.append(".globl  %s"%stmt["name"])
            list_data.append("%s:"%stmt["name"])
            if stmt["expr"]["type"] == "cst":
                list_data.append("\t.zero %d"%int(stmt["expr"]["value"]*8))
            else:
                raise Interpret_exception("Not a constant", stmt["expr"])

                    

posWhile = []
nbWhile = 0

def eval_stmt(stmt, local_env = None):
    global nbWhile
    for instr in stmt:
        if instr["action"] == "return":
            eval_expr(instr["expr"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tleave")
            list_instr.append("\tret")

        if instr["action"] == "print_int":
            eval_expr(instr["expr"], local_env)
            if instr["expr"]["type"] == "application":
                list_instr.append("\tpop %rax")
                list_instr.append("\tmov %rax, %rsi")
            else:
                list_instr.append("\tpop %rax")
                list_instr.append("\tmov %rax, %rsi")
            
            list_instr.append("\tleaq format(%rip), %rdi")  #for printf, the stack needs to be aligned so we get the missaligned part and we substract it from the stack then we add it back
            list_instr.append("\tmov $0, %eax")
            list_instr.append("\tmov %rsp, %r8")
            list_instr.append("\tand $0xf, %r8 ")
            list_instr.append("\tsub %r8, %rsp")
            list_instr.append("\tpush %r8")
            list_instr.append("\tsub $8, %rsp")
            list_instr.append("\tcall printf")
            list_instr.append("\tadd $8, %rsp")
            list_instr.append("\tpop %r8")
            list_instr.append("\tadd %r8, %rsp")


        
        if instr["action"] == "ptrset":
            if instr["name"] in local_env:
                eval_expr(instr["expr"], local_env)
                list_instr.append("\tpop %rax")
                if local_env[instr["name"]]["index"] < 0:
                    tmpV = int(local_env[instr["name"]]["index"]*8)
                else:
                    tmpV = int(local_env[instr["name"]]["index"]*8 + 8)
                list_instr.append(f"\tmov {tmpV}(%rbp), %rdi")
                list_instr.append(f"\tmov %rax, (%rdi)")
            elif "%s:"%instr["name"] in list_data:
                eval_expr(instr["expr"], local_env)
                list_instr.append("\tpop %rax")
                list_instr.append("\tmov %rax, %s(%%rip)"%instr["name"])


        
        if instr["action"] == "varset" or instr["action"] == "varinitdef":


            if instr["name"] in local_env:

                
                if instr["expr"]["type"] == "application":
                    eval_expr(instr["expr"], local_env)
                    list_instr.append("\tpop %rax")
                    if local_env[instr["name"]]["index"] < 0:
                        list_instr.append("\tmov %%rax, %d(%%rbp)"%int(local_env[instr["name"]]["index"]*8))
                    else:
                        list_instr.append("\tmov %%rax, %d(%%rbp)"%int(local_env[instr["name"]]["index"]*8 + 8))
                    
                else:
                    
                    if local_env[instr["name"]]["index"] < 0:
                        eval_expr(instr["expr"], local_env)
                        list_instr.append("\tpop %rax")
                        list_instr.append("\tmov %%rax, %d(%%rbp)"%int(local_env[instr["name"]]["index"]*8))
                    else:
                        eval_expr(instr["expr"], local_env)
                        list_instr.append("\tpop %rax")
                        list_instr.append("\tmov %%rax, %d(%%rbp)"%int(local_env[instr["name"]]["index"]*8 + 8))
                
            elif "%s:"%instr["name"] in list_data:
                if instr["expr"]["type"] == "application":
                    eval_expr(instr["expr"], local_env)
                    list_instr.append("\tpop %rax")
                    list_instr.append("\tmov %%rax, %s(%%rip)"%instr["name"])
                else:
                    eval_expr(instr["expr"], local_env)
                    list_instr.append("\tpop %rax")
                    list_instr.append("\tmov %%rax, %s(%%rip)"%instr["name"])
            
        if instr["action"] == "expression":
            eval_expr(instr["expr"], local_env)
            list_instr.append("\tpop %rax")
        
        if instr["action"] == "ifelse":
            eval_expr(instr["cond"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp $0, %rax")
            list_instr.append(f"\tjne .L{codeFromPos(instr['cond'])}")
            list_instr.append(f"\tjmp .L{codeFromPos(instr['cond'])}e")
            list_instr.append(f".L{codeFromPos(instr['cond'])}:")
            eval_stmt(instr["then"], local_env)
            list_instr.append(f"\tjmp .L{codeFromPos(instr['cond'])}end")
            list_instr.append(f".L{codeFromPos(instr['cond'])}e:")
            eval_stmt(instr["else"], local_env)
            list_instr.append(f".L{codeFromPos(instr['cond'])}end:")

            
        if instr["action"] == "ifnoelse":
            eval_expr(instr["cond"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp $0, %rax")
            list_instr.append(f"\tjne .L{codeFromPos(instr['cond'])}")
            list_instr.append(f"\tjmp .L{codeFromPos(instr['cond'])}end")
            list_instr.append(f".L{codeFromPos(instr['cond'])}:")
            eval_stmt(instr["then"], local_env)
            list_instr.append(f"\tjmp .L{codeFromPos(instr['cond'])}end")
            list_instr.append(f".L{codeFromPos(instr['cond'])}end:")

        if instr["action"] == "while":

            posWhile.append(codeFromPos(instr['cond']))
            list_instr.append(f".L{codeFromPos(instr['cond'])}:")
            eval_expr(instr["cond"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp $0, %rax")
            list_instr.append(f"\tje .L{codeFromPos(instr['cond'])}end")
            eval_stmt(instr["body"], local_env)
            list_instr.append(f"\tjmp .L{codeFromPos(instr['cond'])}")
            list_instr.append(f".L{codeFromPos(instr['cond'])}end:")
            nbWhile -= 1

        if instr["action"] == "break":
            list_instr.append(f"\tjmp .L{posWhile[nbWhile]}end")
        
        if instr["action"] == "continue":
            list_instr.append(f"\tjmp .L{posWhile[nbWhile]}")
        
        if instr["action"] == "tabset":
            list_instr.append(f"\tlea {instr['name']}(%rip), %rcx")
            eval_expr(instr["index"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\timul $8, %rbx")
            list_instr.append("\tadd %rbx, %rcx")
            eval_expr(instr["expr"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\tmov %rbx, (%rcx)")




def getTypes(expr, local_env):  #usleful for pointers arithmetic
    if expr["type"] == "cst":
        return "int"
    if expr["type"] == "var":
        if expr["name"] in local_env:
            return local_env[expr["name"]]["type"]
        elif "%s:"%expr["name"] in list_data:
            return "int"
        else:
            raise Interpret_exception("Variable not found", expr)
    if expr["type"] == "binop":
        e1 = getTypes(expr["e1"], local_env)
        e2 = getTypes(expr["e2"], local_env)
        if e1 == "int*" or e2 == "int*":
            return "int*"
        else:
            return "int"



def eval_expr(expr, local_env = None):
    if expr["type"] == "cst":
        list_instr.append(f"\tpush ${expr['value']}")

    if expr["type"] == "unop":
        if expr["unop"] == "&": #address of
            if expr["e"]["type"] == "var":
                if expr["e"]["name"] in local_env:
                    if local_env[expr["e"]["name"]]["index"] < 0:
                        list_instr.append("\tlea %d(%%rbp), %%rax"%int(local_env[expr["e"]["name"]]["index"]*8))
                    else:
                        list_instr.append("\tlea %d(%%rbp), %%rax"%int(local_env[expr["e"]["name"]]["index"]*8 + 8))
                else:
                    list_instr.append("\tlea %s(%%rip), %%rax"%expr["e"]["name"])
                list_instr.append("\tpush %rax")
            else:
                raise Interpret_exception("Not a variable", expr)
        if expr["unop"] == "*": #dereference
            if expr["e"]["type"] == "var":
                if expr["e"]["name"] in local_env:
                    if local_env[expr["e"]["name"]]["index"] < 0:
                        tmpV = int(local_env[expr["e"]["name"]]["index"]*8)
                        list_instr.append(f"\tmov {tmpV}(%rbp), %rdi")
                        list_instr.append(f"\tmov (%rdi), %rax")
                    else:
                        tmpV = int(local_env[expr["e"]["name"]]["index"]*8 + 8)
                        list_instr.append(f"\tmov {tmpV}(%rbp), %rdi")
                        list_instr.append(f"\tmov (%rdi), %rax")
                elif "%s:"%expr["e"]["name"] in list_data:
                    list_instr.append("\tpush %s(%%rip)"%expr["e"]["name"])
                list_instr.append("\tpush %rax")

    if expr["type"] == "binop":
        if expr["binop"] == "+":


            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tpop %rbx")
            if getTypes(expr["e1"], local_env) == "int*":
                if getTypes(expr["e2"], local_env) == "int":
                    list_instr.append("\timul $8, %rax")
                else:
                    raise Interpret_exception("Add 2 pointers", expr)
            if getTypes(expr["e2"], local_env) == "int*":
                if getTypes(expr["e1"], local_env) == "int":
                    list_instr.append("\timul $8, %rbx")
                else:
                    raise Interpret_exception("Add 2 pointers", expr)
            list_instr.append("\tadd %rbx, %rax")
            list_instr.append("\tpush %rax")

            
        if expr["binop"] == "-":
            # e1 - e2 -> rbx = e2 et rax = e1
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
            if getTypes(expr["e1"], local_env) == "int*":
                if getTypes(expr["e2"], local_env) == "int":
                    list_instr.append("\timul $8, %rbx")
            if getTypes(expr["e2"], local_env) == "int*":
                if getTypes(expr["e1"], local_env) == "int":
                    list_instr.append("\timul $8, %rax")
            list_instr.append("\tsub %rbx, %rax")
            list_instr.append("\tpush %rax")



        if expr["binop"] == "*":
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tpop %rbx")
            list_instr.append("\timul %rbx, %rax")
            list_instr.append("\tpush %rax")


        if expr["binop"] == "/":
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
            list_instr.append("\tcqo")
            list_instr.append("\tidiv %rbx")
            list_instr.append("\tpush %rax")


        if expr["binop"] == "%":
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
            list_instr.append("\tcdq")
            list_instr.append("\tidiv %rbx")
            list_instr.append("\tpush %rdx")


        if expr["binop"] == "==":
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp %rbx, %rax")
            list_instr.append("\tsete %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tpush %rax")

        if expr["binop"] == "!=":
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp %rbx, %rax")
            list_instr.append("\tsetne %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tpush %rax")
        if expr["binop"] == "<":
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp %rbx, %rax")
            list_instr.append("\tsetl %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tpush %rax")
        if expr["binop"] == "<=":
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp %rbx, %rax")
            list_instr.append("\tsetle %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tpush %rax")
        if expr["binop"] == ">":
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp %rbx, %rax")
            list_instr.append("\tsetg %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tpush %rax")
        if expr["binop"] == ">=":
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp %rbx, %rax")
            list_instr.append("\tsetge %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tpush %rax")


        if expr["binop"] == "&&" : #short-circuit evaluation
            eval_expr(expr["e1"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp $0, %rax")
            list_instr.append(f"\tje .L{codeFromPos(expr['e2'])}")
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp $0, %rax")
            list_instr.append("\tsetne %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tpush %rax")
            list_instr.append(f"\tjmp .L{codeFromPos(expr['e2'])}end")
            list_instr.append(f".L{codeFromPos(expr['e2'])}:")
            list_instr.append("\tpush %rax")
            list_instr.append(f".L{codeFromPos(expr['e2'])}end:")

        if expr["binop"] == "||" : #short-circuit evaluation
            eval_expr(expr["e1"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp $0, %rax")
            list_instr.append(f"\tjne .L{codeFromPos(expr['e2'])}")
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp $0, %rax")
            list_instr.append("\tsetne %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tpush %rax")
            list_instr.append(f"\tjmp .L{codeFromPos(expr['e2'])}end")
            list_instr.append(f".L{codeFromPos(expr['e2'])}:")
            list_instr.append("\tpush %rax")
            list_instr.append(f".L{codeFromPos(expr['e2'])}end:")

        if expr["binop"] == "!":
            eval_expr(expr["e1"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp $0, %rax")
            list_instr.append("\tsete %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tpush %rax")
        



    
    if expr["type"] == "var":
        if expr["name"] in local_env:
            if local_env[expr["name"]]["index"] < 0:
                list_instr.append("\tpush %d(%%rbp)"%int(local_env[expr["name"]]["index"]*8))
            else:
                list_instr.append("\tpush %d(%%rbp)"%int(local_env[expr["name"]]["index"]*8 + 8))
        else:
            list_instr.append("\tpush %s(%%rip)"%expr["name"])
    
    if expr["type"] == "application":
        if len(expr["args"]) != functions[expr["function"]]:
            raise Interpret_exception("Wrong number of arguments", expr)
        else:
            for arg in reversed(expr["args"]):
                if arg["type"] == "cst":
                    list_instr.append("\tpush $%s"%arg["value"])
                else:
                    eval_expr(arg, local_env)
                    
            list_instr.append("\tcall %s"%expr["function"])

            if len(expr["args"]) > 0 :  
                list_instr.append("\tadd $%d, %%rsp"%int(len(expr["args"])*8))
 
            
            list_instr.append("\tpush %rax")
    
    if expr["type"] == "acces":
        eval_expr(expr["expr"], local_env)
        nom = expr["name"]
        list_instr.append("\tpop %rbx")
        list_instr.append("\timul $8, %rbx")
        list_instr.append(f"\tlea "+ nom +"(%rip), %rax")
        list_instr.append("\tadd %rbx, %rax")
        list_instr.append("\tpush (%rax)")







def writeAsm(filename):
    with open(filename[:-5] + ".s", "w") as f:
        for data in list_data:
            f.write(data + "\n")
        for instr in list_instr:
            f.write(instr + "\n")



    
    



def read(filename):
    with open(filename) as f:
        term = json.load(f)
        return term


if __name__ == "__main__":
    assert(len(sys.argv) == 2)
    try:
        eval_program(read(sys.argv[-1]))
        writeAsm(sys.argv[-1])
        exit(0)
    except Interpret_exception as i:
        print(i.msg)
        exit(-1)