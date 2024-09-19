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
        


def eval_program(program):
    pass
    
if __name__ == "__main__":
    assert(len(sys.argv) == 2)
    try:
        eval_program(read(sys.argv[-1]))
        exit(ret)
    except Interpret_exception as i:
        print(i.msg)
        exit(-1)
