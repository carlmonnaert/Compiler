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
    
    for stmt in program:
        if stmt["action"] == "fundef" and stmt["name"] == "main":
            list_instr.append("\t.text")
            list_instr.append("\t.globl main")
            list_instr.append("main:")
            eval_stmt(stmt["body"])
        elif stmt["action"] == "fundef":
            list_instr.append("\t.text")
            list_instr.append("\t.globl " + stmt["name"])
            list_instr.append(stmt["name"] + ":")
            eval_stmt(stmt["body"])
            

        elif stmt["action"] == "gvardef" :
            list_data.append(".globl  %s"%stmt["name"])
            list_data.append("%s:"%stmt["name"])
            list_data.append("\t.quad 0")
        
        elif stmt["action"] == "fundef":
            list_instr.append("\t.text")
            list_instr.append("\t.globl %s"%stmt["name"])
            list_instr.append("%s:"%stmt["name"])
            eval_stmt(stmt["body"])


def eval_stmt(stmt):
    for instr in stmt:
        if instr["action"] == "return":
            eval_expr(instr["expr"])
            list_instr.append("\tpop %rax")
            list_instr.append("\tret")

        if instr["action"] == "print":
            eval_expr(instr["expr"])
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
        
        if instr["action"] == "varset":
            if "%s:"%instr["name"] in list_data:
                if instr["expr"]["type"] == "application":
                    eval_expr(instr["expr"])
                    list_instr.append("\tpop %r8")
                    list_instr.append("\tmov %%r8, %s(%%rip)"%instr["name"])
                else:
                    eval_expr(instr["expr"])
                    list_instr.append("\tpop %r8")
                    list_instr.append("\tmov %%r8, %s(%%rip)"%instr["name"])

def eval_expr(expr):
    if expr["type"] == "cst":
        list_instr.append(f"\tpush ${expr['value']}")

    if expr["type"] == "binop":
        if expr["binop"] == "+":
            eval_expr(expr["e1"])
            eval_expr(expr["e2"])
            list_instr.append("\tpop %rax")
            list_instr.append("\tpop %rbx")
            list_instr.append("\tadd %rbx, %rax")
            list_instr.append("\tpush %rax")
        if expr["binop"] == "-":
            eval_expr(expr["e1"])
            eval_expr(expr["e2"])
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
            list_instr.append("\tsub %rbx, %rax")
            list_instr.append("\tpush %rax")
        if expr["binop"] == "*":
            eval_expr(expr["e1"])
            eval_expr(expr["e2"])
            list_instr.append("\tpop %rax")
            list_instr.append("\tpop %rbx")
            list_instr.append("\timul %rbx, %rax")
            list_instr.append("\tpush %rax")
        if expr["binop"] == "/":
            eval_expr(expr["e1"])
            eval_expr(expr["e2"])
            list_instr.append("\tpop %rbx")
            list_instr.append("\tpop %rax")
            list_instr.append("\tcqo")
            list_instr.append("\tidiv %rbx")
            list_instr.append("\tpush %rax")
    
    if expr["type"] == "var":
        list_instr.append("\tpush %s(%%rip)"%expr["name"])
    
    if expr["type"] == "application":
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