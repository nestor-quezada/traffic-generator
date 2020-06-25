#!/bin/bash

# Write the path when executing the script as an argument ".../accionesUsuario/"
name=$1


# Imprime todos los intervalos de 5 minutos(bytes o nº accesos) y su estado(ej. estado: 8 numbytes: 8220 )

# Loop through the directory
for file in "$name"*
do
    # Store the awk result in a bash array in order to have this results available to create the global statistics
	if [ -s "$file" ]
		then
				declare -a arr
				readarray -t arr < <( sort -s -n -k 1,1 "$file" |awk -f  "get_matriz_global.awk" )
				#declare -A density_function
				
		        for i in "${arr[@]}";
					do

						echo $i
						
							
					done #|sort -s -n -k 1,1 

	    		#echo "end_of_file"
		
		fi
	# Add the intervals statistics per file to the global statistics
	
done | awk '{ arr[$1"1"]+=$2;arr[$1"2"]+=$3;arr[$1"3"]+=$4;  } 
END { for(i=1;i<=12;i++){ printf "%d %0.2f %0.2f %0.2f\n", i,
arr[i"1"]/(arr[i"1"] + arr[i"2"] + arr[i"3"]), 
arr[i"2"]/(arr[i"1"] + arr[i"2"] + arr[i"3"] ), arr[i"3"]/(arr[i"1"] + arr[i"2"] + arr[i"3"])  }}'

