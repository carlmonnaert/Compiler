import json
from collections import defaultdict
import sys

def read(filename):
    with open(filename) as f:
        term = json.load(f)
        return term

class Interpret_exception(BaseException):
    def __init__(self, msg, term):
        pos = (term["start_line"],term["start_char"],term["end_line"],term["end_char"])
        self.msg = msg + (" at positions (%d,%d)-(%d,%d)"%pos)

gvar = {} # global variables
ret = 0 # return value
fun = {} # global functions


def get_var_value(var_name, local_env, pos):
    global gvar
    if var_name in local_env:
        return local_env[var_name]["value"]
    elif var_name in gvar:
        return gvar[var_name]["value"]
    else:
        raise Interpret_exception("Undefined variable '%s'"%var_name, pos)

def set_var_value(var_name, var_val, local_env, pos):
    global gvar
    if var_name in local_env:
        local_env[var_name]["value"] = var_val
    elif var_name in gvar:
        gvar[var_name]["value"] = var_val

    else:
        raise Interpret_exception("Undefined variable '%s'"%var_name, pos)



def eval_expr(term, local_env):
    if term["type"] == "cst":
        return term["value"]
    if term["type"] == "var":
        if term["name"] in local_env:
            return local_env[term["name"]]["value"]
        elif term["name"] in gvar:
            return gvar[term["name"]]["value"]
        else:
            raise Interpret_exception("Undefined variable '%s'"%term["name"], term)
    if term["type"] == "binop":
        left = eval_expr(term["e1"], local_env)
        right = eval_expr(term["e2"], local_env)
        if term["binop"] == "+":
            return left + right
        if term["binop"] == "-":
            return left - right
        if term["binop"] == "*":
            return left * right
        if term["binop"] == "/":
            return left // right
    if term["type"] == "call":
        if term["name"] not in fun:
            raise Interpret_exception("Undefined function '%s'"%term["name"], term)
        if len(term["args"]) != len(fun[term["name"]]["arg"]):
            raise Interpret_exception("Wrong number of arguments in function call '%s'"%term["name"], term)
        new_local_env = {}
        for i in range(len(term["args"])):
            new_local_env[fun[term["name"]]["arg"][i]] = {"value" : eval_expr(term["args"][i], local_env)}
        return eval_func(fun[term["name"]]["body"], new_local_env)
    if term["type"] == "application":
        func = fun[term["function"]]
        func["localvar"][func["arg"]] = {"value" : eval_expr(term["argvalue"], local_env)}
        
        eval_func(func["body"], func["localvar"])
        return ret

def eval_func(term, local_env):
    for stmt in term:
        eval_stmt(stmt, local_env)

def eval_stmt(term, local_env):
    global gvar
    if term["action"] == "vardef":
        if term["name"] in local_env:
            raise Interpret_exception("Variable '%s' already defined"%term["name"], term)
        local_env[term["name"]] = {"value" : 0}
    if term["action"] == "varset":
        if term["name"] in local_env:
            local_env[term["name"]]["value"] = eval_expr(term["expr"], local_env)
        elif term["name"] in gvar:
            gvar[term["name"]]["value"] = eval_expr(term["expr"], local_env)
        else:
            raise Interpret_exception("Undefined variable '%s'"%term["name"], term)
    if term["action"] == "return":
        global ret
        ret = eval_expr(term["expr"], local_env)
    if term["action"] == "print":
        print(eval_expr(term["expr"], local_env))



def eval_program(program):
    global gvar
    global fun
    for dic in program:
        if dic["action"] == "gvardef":
            gvar[dic["name"]] = {"value" : 0, "start_line" : dic["start_line"], "start_char" : dic["start_char"], "end_line" : dic["end_line"], "end_char" : dic["end_char"]}  
        if dic["action"] == "fundef":
            fun[dic["name"]] = {"arg" : dic["arg"], "localvar" : {} ,"body" : dic["body"], "start_line" : dic["start_line"], "start_char" : dic["start_char"], "end_line" : dic["end_line"], "end_char" : dic["end_char"]}
    eval_func(fun["main"]["body"], fun["main"]["localvar"])

if __name__ == "__main__":
    assert(len(sys.argv) == 2)
    try:
        eval_program(read(sys.argv[-1]))
        exit(ret)
    except Interpret_exception as i:
        print(i.msg)
        exit(-1)
