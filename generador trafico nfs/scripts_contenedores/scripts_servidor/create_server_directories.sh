#!/bin/bash

# Path del directorio donde crear el arbol
DPATH=$1
# Numero de ficheros a crear en el arbol
NUM_FILES=$2
# Path donde se guarda el fichero con la lista de rutas
OUT_PATH=$3

# cd al directorio donde esta el programa
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

mkdir -p "$DPATH"
#rm -rfv "$DPATH"/*

    # Ejecuta el programa pero con el fichero inputFile_p parametrizable
impressions/impressions <(m4 -D __DPATH__="$DPATH" -D __NUM_FILES__="$NUM_FILES" impressions/inputFile_p )

# Script para crear la lista con los paths de cada fichero del arbol
tree -fi -a "$DPATH" | grep ".pdf" >> "$OUT_PATH"