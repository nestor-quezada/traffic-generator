#!/bin/bash

# Write the path when executing the script as an argument ".../accionesUsuario/"
name=$1


# Imprime todos los intervalos de 5 minutos(bytes o nº accesos) y su estado(ej. estado: 8 numbytes: 8220 )
i=0
# Loop through the directory
for file in "$name"*
do
    # Store the awk result in a bash array in order to have this results available to create the global statistics
	if [ -s "$file" ]
		then
				
				#echo "${file##*_}"

				
				casos=$(awk -f "prob_acum_casos.awk" "$file") #>> "out_prob_casos.txt"
				#declare -A density_function

				echo "${file##*_}" $casos
				i=$((i+1))
	
		        
	    		#echo "end_of_file"
		
		fi
	# Add the intervals statistics per file to the global statistics
	
done #>> all_lines_bytes.txt
