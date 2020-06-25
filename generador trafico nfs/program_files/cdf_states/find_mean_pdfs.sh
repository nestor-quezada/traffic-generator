#!/bin/bash

# Write the path when executing the script as an argument ".../accionesUsuario/"
name=$1


# Imprime todos los intervalos de 5 minutos(bytes o nº accesos) y su estado(ej. estado: 8 numbytes: 8220 )
i=0
# Loop through the directory
for file in "$name"*
do
    # Store the awk result in a bash array in order to have this results available to create the global statistics %0.12f
	if [ -s "$file" ]
		then
				
				indice="${file##*_}"
				media=$(tac "$file" | 
				awk '{if(NR!=1){printf"%0.12f %0.12f\n",prev_index, (prev_value-$2) };prev_index=$1; prev_value=$2;}'  | #tac| awk '{printf"%0.12f %0.12f\n",$1, $2 + 0.000435232}'  | awk '{ if(NR==1){sum=$2}else{sum+=$2}  printf"%0.12f %0.12f\n",$1,sum ; }' > cdf_norm_accesos.txt 
				awk -v var="$indice" '{total += $1*$2 } END { printf "%d %d \n",var, total }' )
				#| sort -s -n -k 1n,2n -k 2,2n 

				#echo $media

				sd=$(tac "$file" | 
				awk '{if(NR!=1){printf"%0.12f %0.12f\n",prev_index, (prev_value-$2) };prev_index=$1; prev_value=$2;}'  | #tac| awk '{printf"%0.12f %0.12f\n",$1, $2 + 0.000435232}'  | awk '{ if(NR==1){sum=$2}else{sum+=$2}  printf"%0.12f %0.12f\n",$1,sum ; }' > cdf_norm_accesos.txt 
				awk -v var="$indice" -v media="$media" '{total += ($1-media)^2*$2 } END { printf "%d %0.2f \n",var, sqrt(total) }' )


				echo $sd
					#> "pdf_mean_bytes/state_mean_"$i
				#declare -A density_function
				i=$((i+1))
	
		        
	    		#echo "end_of_file"
		
		fi
	# Add the intervals statistics per file to the global statistics
	
done #>> all_lines_bytes.txt
