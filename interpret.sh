#!/bin/bash

cd expr2json ;
dune build ;
cd ..
cp expr2json/expr2json.exe .
./expr2json.exe file.c
python3 eval_micro_C/interpreterfromjson.py file.json
