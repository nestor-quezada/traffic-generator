#!/bin/bash

# Write the path when executing the script as an argument ".../accionesUsuario/"
f1=$1
f2=$2

paste  "$f1" "$f2" | awk '{ total+=$2*$4} END { printf "%d\n", total}'