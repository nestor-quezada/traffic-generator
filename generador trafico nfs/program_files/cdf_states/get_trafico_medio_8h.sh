#!/bin/bash

# Write the path when executing the script as an argument ".../accionesUsuario/"
f1=$1
f2=$2

paste  "$f1" "$f2" | awk '{ if ($2 != 0 ){printf "%d %d\n",$1,(8*3600/$2)*$4}else { print 0, 0}}'