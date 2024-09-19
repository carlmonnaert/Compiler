import json

import sys

if len(sys.argv) != 2:
    print("Usage: python interpreterfromjson.py <json_file>")
    sys.exit(1)
json_file = sys.argv[1]

with open(json_file) as f:
    data = json.load(f)

globalvar = {}
globalfunc = {}


def gvardef(data):
    global globalvar
    globalvar[data['name']] = 0
    print(globalvar)
    
def gfundef(data):
    print(data)
    print(data['arg'])
    global globalfunc
    globalfunc[data['name']] = {"body" : data['body'], "localvar" : {}, 'arg' : {'name' : data['arg'], 'value': 0}}
    
def vardef(data, funcname):
    localvar = globalfunc[funcname]['localvar']
    localvar[data['name']] = 0
    print(localvar)
    
def evalexpr(data, funcname):
    if 'expr' in data:
        evalexpr(data['expr'])
    if 'binop' in data:
        left = evalexpr(data['e1'], funcname)
        right = evalexpr(data['e2'], funcname)
        if data['binop'] == '+':
            return left + right
        if data['binop'] == '-':
            return left - right
        if data['binop'] == '*':
            return left * right
        if data['binop'] == '/':
            return left / right
    if 'value' in data:
        return data['value']
    if 'name' in data:
        
        if funcname is not None and data['name'] in globalfunc[funcname]['localvar']:
            return globalfunc[funcname]['localvar'][data['name']]
        
        if funcname is not None and data['name'] == globalfunc[funcname]['arg']['name']:
            return globalfunc[funcname]['arg']['value']
        if data['name'] in globalvar:
            return globalvar[data['name']]
        # gerer les args de la fonction
        
        else:
            raise Exception("Variable not found")
    if 'application' == data['type']:
        print("Application found")
        print(data)
        funcname2 = data['function']
        if funcname2 in globalfunc:
            arg = evalexpr(data['argvalue'], funcname)
            print(arg)
            func = globalfunc[funcname2]
            func['arg']['value'] = arg
            return interpret(func, funcname2)
        else:
            raise Exception("Function not found")
    return None
def varset(data, funcname):
    if 'expr' in data:
        val = evalexpr(data['expr'], funcname)
    else:
        val = data['value']
    if funcname is not None and data['name'] in globalfunc[funcname]['localvar']:
        globalfunc[funcname]['localvar'][data['name']] = val
        print(globalfunc[funcname]['localvar'])
    elif data['name'] in globalvar:
        globalvar[data['name']] = val
    else:
        raise Exception("Variable not found")
    
def returnfunc(data, funcname):
    print(data)
    if 'expr' in data:
        val = evalexpr(data['expr'], funcname)
    else:
        val = data['value']
    print("Function returned")
    print(val)
    return val

def interpret(data, funcname=None):
    if 'body' in data:
        for key in data['body']:
            # if key is a action
            action = key['action']
            switcher = {
                "gvardef": gvardef,
                "fundef": gfundef,
                "vardef": vardef,
                "varset": varset,
                "return": returnfunc,
            }
            func = switcher.get(action)
            if func is None:
                print("Action not found")
                continue
            if func == vardef or func == varset:
                func(key, funcname)
            elif func == returnfunc:
                return func(key, funcname)
            else:
                func(key)
        return
    for key in data:
        # if key is a action
        action = key['action']
        switcher = {
            "gvardef": gvardef,
            "fundef": gfundef,
        }
        func = switcher.get(action)
        if func is None:
            print("Action not found")
            continue
        if func == vardef or func == varset:
            func(key, funcname)
        else:
            func(key)
    
  
        
        
            
        
interpret(data)
if 'main' in globalfunc:
    interpret(globalfunc['main'])