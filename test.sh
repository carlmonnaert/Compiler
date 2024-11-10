eval $(opam env)

cd expr2json;
dune build ;
cd ..
cp expr2json/expr2json.exe .
./expr2json.exe tests/test.c
jq . tests/test.json > tests/test2.json
python3 ./eval_micro_C/compil.py tests/test.json
gcc tests/test.s -o tests/test
./tests/test
