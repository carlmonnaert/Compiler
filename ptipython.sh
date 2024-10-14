#!/bin/bash

eval $(opam env)




cd Interpreter_ptipython/base_runtime ;
dune build ;
cd ../..;
cp Interpreter_ptipython/base_runtime/ptipython.exe .
cp Interpreter_ptipython/base_json/ptipython2json.exe .
./ptipython2json.exe file.py
jq . file.json > file2.json
./ptipython.exe file.py
