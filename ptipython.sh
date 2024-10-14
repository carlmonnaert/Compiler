#!/bin/bash

eval $(opam env)

# Vérifier si un argument est fourni
if [ -z "$1" ]; then
  echo "Veuillez fournir un fichier en argument."
  exit 1
fi

# Récupérer le nom du fichier
fichier="$1"




# Interpréter le fichier
cd Interpreter_ptipython/base_runtime ;
dune build ;
cd ../..;
cp Interpreter_ptipython/base_runtime/ptipython.exe .
./ptipython.exe $fichier
