import sys
import json


class Interpret_exception(BaseException):
    def __init__(self, msg, term):
        pos = (term["start_line"],term["start_char"],term["end_line"],term["end_char"])
        self.msg = msg + (" at positions (%d,%d)-(%d,%d)"%pos)

list_data = []
list_instr = []


def eval_program(program):
    list_data.append("\t.data")
    list_data.append("format:")
    list_data.append("\t.string \"%d\\n\"") 
    # for scanf
    list_data.append("format2:")
    list_data.append("\t.string \"%d\"")
    
    for stmt in program:
        if stmt["action"] == "fundef":
            list_instr.append("\t.text")
            list_instr.append("\t.globl " + stmt["name"])
            list_instr.append(stmt["name"] + ":")
            local_env = {stmt["arg"] : 1}
            x = 1
            for t in stmt["body"]:
                if t["action"] == "vardef":
                    x += 1
                    local_env[t["name"]] = x
            list_instr.append("\tpush %rbp")
            list_instr.append("\tmov %rsp, %rbp")
            list_instr.append("\tsub $%d, %%rsp"%int((x+1)*8))
            if stmt["name"] != "main":
                list_instr.append("\tmov %rdi, -8(%rbp)")   
            eval_stmt(stmt["body"], local_env)
            

        elif stmt["action"] == "gvardef" :
            list_data.append(".globl  %s"%stmt["name"])
            list_data.append("%s:"%stmt["name"])
            list_data.append("\t.quad 0")


def eval_stmt(stmt, local_env = None):
    for instr in stmt:
        if instr["action"] == "return":
            eval_expr(instr["expr"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tadd $%d, %%rsp"%int((len(local_env)+1)*8))
            list_instr.append("\tpop %rbp")
            list_instr.append("\tret")

        if instr["action"] == "print":
            eval_expr(instr["expr"], local_env)
            list_instr.append("\tpop %rsi")
            list_instr.append("\tleaq format(%rip), %rdi")
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
        
        if instr["action"] == "read":
            list_instr.append("\tpush $0")
            list_instr.append("\tleaq (%rsp), %rsi")
            list_instr.append("\tleaq format2(%rip), %rdi")
            list_instr.append("\tmov $0, %eax")
            list_instr.append("\tmov %rsp, %r8")
            list_instr.append("\tand $0xf, %r8 ")
            list_instr.append("\tsub %r8, %rsp")
            list_instr.append("\tpush %r8")
            list_instr.append("\tsub $8, %rsp")
            list_instr.append("\tcall scanf")
            list_instr.append("\tadd $8, %rsp")
            list_instr.append("\tpop %r8")
            list_instr.append("\tadd %r8, %rsp")
            if instr["var"] in local_env:
                list_instr.append("\tmov %%rsi, -%d(%%rbp)"%int(local_env[instr["var"]]*8))
                list_instr.append("\tpop %rsi")
            else:
                list_instr.append("\tmov %%rsi, %s(%%rip)"%instr["var"])
                list_instr.append("\tpop %rsi")

        
        if instr["action"] == "varset":
            if instr["name"] in local_env:
                if instr["expr"]["type"] == "application":
                    eval_expr(instr["expr"], local_env)
                    list_instr.append("\tpop %r8")
                    list_instr.append("\tmov %%r8, -%d(%%rbp)"%int(local_env[instr["name"]]*8))
                else:
                    eval_expr(instr["expr"], local_env)
                    list_instr.append("\tpop %r8")
                    list_instr.append("\tmov %%r8, -%d(%%rbp)"%int(local_env[instr["name"]]*8))
                
            elif "%s:"%instr["name"] in list_data:
                if instr["expr"]["type"] == "application":
                    eval_expr(instr["expr"], local_env)
                    list_instr.append("\tpop %r8")
                    list_instr.append("\tmov %%r8, %s(%%rip)"%instr["name"])
                else:
                    eval_expr(instr["expr"], local_env)
                    list_instr.append("\tpop %r8")
                    list_instr.append("\tmov %%r8, %s(%%rip)"%instr["name"])

def eval_expr(expr, local_env = None):
    if expr["type"] == "cst":
        list_instr.append(f"\tpush ${expr['value']}")

    if expr["type"] == "binop":
        if expr["binop"] == "+":
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tpop %rbx")
            list_instr.append("\tadd %rbx, %rax")
            list_instr.append("\tpush %rax")
        if expr["binop"] == "-":
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
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
    
    if expr["type"] == "var":
        if expr["name"] in local_env:
            list_instr.append("\tpush -%d(%%rbp)"%int(local_env[expr["name"]]*8))
        else:
            list_instr.append("\tpush %s(%%rip)"%expr["name"])
    
    if expr["type"] == "application":
        if expr["argvalue"]["type"] == "cst":
            list_instr.append("\tmov $%s, %%rdi"%expr["argvalue"]["value"])
            list_instr.append("\tcall %s"%expr["function"])
            list_instr.append("\tpush %rax")
        else:
            eval_expr(expr["argvalue"], local_env)
            list_instr.append("\tpop %rdi")
            list_instr.append("\tcall %s"%expr["function"])
            list_instr.append("\tpush %rax")







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