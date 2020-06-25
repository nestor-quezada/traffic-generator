#!/bin/bash

# Path del directorio con los fihceros de las observaciones
name=$1

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"


mkdir -p "/mnt/shared/server-directories"
mkdir -p "server-directories-list"


# Crea un arbol de directorios por cada cliente
for file in "$name"*
do
  # Numero de ficheros a crear con impressions
  num_files=$(awk '{sum+=1}END{print sum}' $file)

  # ID del cliente
  indice="${file##*-}"

  # Crea directorio particular de cada cliente
  mkdir -p "/mnt/shared/server-directories/directory-"$indice

  # Crea el arbol para cada cliente y ademas crea una serie de  ficheros con una lista de estructura del arbol para cada cliente
  ./create_server_directories.sh  "/mnt/shared/server-directories/directory-"$indice"/"  $num_files "server-directories-list/directory-"$indice

done