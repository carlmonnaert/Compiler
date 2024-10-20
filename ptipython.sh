#!/bin/bash

# eval $(opam env)



cd Interpreter_ptipython/base_runtime ;
dune build ;
cd ../.. ;
cp Interpreter_ptipython/base_runtime/ptipython.exe .
./ptipython.exe file.py
