eval $(opam env)

cd Interpreter_ptipython/base_runtime ;
dune build ;
./ptipython.exe ../base_json/file.py
