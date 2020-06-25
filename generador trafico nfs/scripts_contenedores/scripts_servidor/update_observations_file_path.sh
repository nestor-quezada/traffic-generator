#!/bin/bash

# Path del directorio con los ficheros de las observaciones
name=$1

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

directory_observaciones_w_path="observaciones-with-path/"
directory_observaciones="observaciones/"
directory_server_lists="server-directories-list/"

mkdir -p "$directory_observaciones_w_path"

for file in "$name"*
do
 indice="${file##*-}"
 directory_list_file="directory-"$indice
 echo "$directory_server_lists""$directory_list_file"
 ./randomize_directories_list.sh "$directory_server_lists""$directory_list_file"
 paste $directory_observaciones"cliente-""$indice" "$directory_server_lists""$directory_list_file"> \
    $directory_observaciones_w_path"cliente-""$indice"


done