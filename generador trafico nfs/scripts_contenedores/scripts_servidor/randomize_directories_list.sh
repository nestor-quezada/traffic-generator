#!/bin/bash

# path del fichero a aleatorizar
filename=$1

# Crea fichero temporal
tmpfile=$(mktemp)
# Aleatoriza el fichero y lo guarda en el archivo temporal
shuf "$filename" > ${tmpfile}
# cat al archivo original, '>' sobreescribe el fichero inicial
cat ${tmpfile} > "$filename"
# Borra el fichero temporal
rm -f ${tmpfile}