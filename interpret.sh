#!/bin/bash

cd expr2json ;
dune build ;
cd ..
cp expr2json/expr2json.exe .
./expr2json.exe file.c
jq . file.json > file2.json
python3 eval_micro_C/eval.py file.json