import sys
import json




class Interpret_exception(BaseException):
    def __init__(self, msg, term):
        pos = (term["start_line"],term["start_char"],term["end_line"],term["end_char"])
        self.msg = msg + (" at positions (%d,%d)-(%d,%d)"%pos)


def codeFromPos(pos): 
    # take Pos and return a code
    return f"{pos['start_line']}{pos['start_char']}{pos['end_line']}{pos['end_char']}"

list_data = []
list_instr = []


functions = {}

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
            x = 1
            local_env = {}
            for t in stmt["args"]:
                local_env[t["name"]] = x
                x += 1
            functions[stmt["name"]] = x -1
            
            x = -1
            for t in stmt["body"]:
                if t["action"] == "vardef" or t["action"] == "varinitdef":
                    local_env[t["name"]] = x
                    x -= 1
            list_instr.append("\tpush %rbp")
            list_instr.append("\tmov %rsp, %rbp")  
            
            tmp = 0
            for t in local_env:
                if local_env[t] < 0:
                    tmp += 1
            list_instr.append("\tsub $%d, %%rsp"%(tmp*8+8))
            eval_stmt(stmt["body"], local_env)
            

        elif stmt["action"] == "gvardef" :
            list_data.append(".globl  %s"%stmt["name"])
            list_data.append("%s:"%stmt["name"])
            list_data.append("\t.quad 0")
        
        elif stmt["action"] == "gvarinitdef":
            list_data.append(".globl  %s"%stmt["name"])
            list_data.append("%s:"%stmt["name"])
            if stmt["expr"]["type"] == "cst":
                list_data.append("\t.quad %d"%stmt["expr"]["value"])

                    


def eval_stmt(stmt, local_env = None):
    for instr in stmt:
        if instr["action"] == "return":
            eval_expr(instr["expr"], local_env)
            list_instr.append("\tpop %rax")
            tmp = 0
            for t in local_env:
                if local_env[t] < 0:
                    tmp += 1
            list_instr.append("\tadd $%d, %%rsp"%int((tmp+1)*8))
            list_instr.append("\tpop %rbp")
            list_instr.append("\tret")

        if instr["action"] == "print_int":
            eval_expr(instr["expr"], local_env)
            if instr["expr"]["type"] == "application":
                list_instr.append("\tpop %rax")
                list_instr.append("\tmov %rax, %rsi")
            else:
                list_instr.append("\tpop %rax")
                list_instr.append("\tmov %rax, %rsi")
            
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

        
        if instr["action"] == "varset" or instr["action"] == "varinitdef":


            if instr["name"] in local_env:

                
                if instr["expr"]["type"] == "application":
                    eval_expr(instr["expr"], local_env)
                    list_instr.append("\tpop %rax")
                    if local_env[instr["name"]] < 0:
                        list_instr.append("\tmov %%rax, %d(%%rbp)"%int(local_env[instr["name"]]*8))
                    else:
                        list_instr.append("\tmov %%rax, %d(%%rbp)"%int(local_env[instr["name"]]*8 + 8))
                    
                else:
                    
                    if local_env[instr["name"]] < 0:
                        eval_expr(instr["expr"], local_env)
                        list_instr.append("\tpop %rax")
                        list_instr.append("\tmov %%rax, %d(%%rbp)"%int(local_env[instr["name"]]*8))
                    else:
                        eval_expr(instr["expr"], local_env)
                        list_instr.append("\tpop %rax")
                        list_instr.append("\tmov %%rax, %d(%%rbp)"%int(local_env[instr["name"]]*8 + 8))
                
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
            # if instr["expr"]["name"] == "break":
            #     list_instr.append(f"\tjmp .L{posBreak}end")
            # if instr["expr"]["name"] == "continue":
            #     list_instr.append(f"\tjmp .L{posBreak}") 
        
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
            list_instr.append(f".L{codeFromPos(instr['cond'])}:")
            eval_expr(instr["cond"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp $0, %rax")
            list_instr.append(f"\tje .L{codeFromPos(instr['cond'])}end")
            eval_stmt(instr["body"], local_env)
            list_instr.append(f"\tjmp .L{codeFromPos(instr['cond'])}")
            list_instr.append(f".L{codeFromPos(instr['cond'])}end:")







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
        if expr["binop"] == "&&": #normal evaluation
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tpop %rbx")
            # cast rax and rbx to 0 or 1
            list_instr.append("\tcmp $0, %rax")
            list_instr.append("\tsetne %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tcmp $0, %rbx")
            list_instr.append("\tsetne %bl")
            list_instr.append("\tmovzb %bl, %rbx")
            list_instr.append("\tand %rbx, %rax")
            list_instr.append("\tpush %rax")


        if expr["binop"] == "||": #normal evaluation
            eval_expr(expr["e1"], local_env)
            eval_expr(expr["e2"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tpop %rbx")
            # cast rax and rbx to 0 or 1
            list_instr.append("\tcmp $0, %rax")
            list_instr.append("\tsetne %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tcmp $0, %rbx")
            list_instr.append("\tsetne %bl")
            list_instr.append("\tmovzb %bl, %rbx")
            list_instr.append("\tor %rbx, %rax")
            list_instr.append("\tpush %rax")

        if expr["binop"] == "!":
            eval_expr(expr["e1"], local_env)
            list_instr.append("\tpop %rax")
            list_instr.append("\tcmp $0, %rax")
            list_instr.append("\tsete %al")
            list_instr.append("\tmovzb %al, %rax")
            list_instr.append("\tpush %rax")


    
    if expr["type"] == "var":
        if expr["name"] in local_env:
            if local_env[expr["name"]] < 0:
                list_instr.append("\tpush %d(%%rbp)"%int(local_env[expr["name"]]*8))
            else:
                list_instr.append("\tpush %d(%%rbp)"%int(local_env[expr["name"]]*8 + 8))
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