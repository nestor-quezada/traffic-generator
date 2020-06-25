#!/bin/awk -f



function find_state(num_access, num_bytes){
  if(num_access == 0 && num_bytes == 0){
  	return 0
  }
    
  if(eje_y_var == 1){
    num_access_interval = find_num_access_interval(num_access);
    num_bytes_interval = find_num_bytes_interval(num_bytes, num_access_interval);

    
  } else {

    num_bytes_interval = find_num_bytes_interval(num_bytes);
    num_access_interval = find_num_access_interval(num_access, num_bytes_interval);
  }
  
  if(num_bytes_interval == 0 && num_access_interval == 0) {return 1}
  if(num_bytes_interval == 0 && num_access_interval == 1) {return 2}
  if(num_bytes_interval == 0 && num_access_interval == 2) {return 3}
  
  if(num_bytes_interval == 1 && num_access_interval == 0) {return 4}
  if(num_bytes_interval == 1 && num_access_interval == 1) {return 5}
  if(num_bytes_interval == 1 && num_access_interval == 2) {return 6}
  
  if(num_bytes_interval == 2 && num_access_interval == 0) {return 7}
  if(num_bytes_interval == 2 && num_access_interval == 1) {return 8}
  if(num_bytes_interval == 2 && num_access_interval == 2) {return 9}
  
  if(num_bytes_interval == 3 && num_access_interval == 0) {return 10}
  if(num_bytes_interval == 3 && num_access_interval == 1) {return 11}
  if(num_bytes_interval == 3 && num_access_interval == 2) {return 12}
   
}

function find_num_bytes_interval(num_bytes, num_column){
 
	if(eje_y_var == 1) {
	   
	   if(num_column == 0){
		limit_y0 = 10462
		limit_y1 = 18878
	   }else if (num_column == 1){
		limit_y0 = 26670
		limit_y1 = 172508
	   }else if (num_column == 2){
		limit_y0 = 596125
		limit_y1 = 3313305
	   }

	   if(num_bytes > limit_y1) {return 2}
	   else if (num_bytes > limit_y0) {return 1}
	   else { return 0}
	
	} else {
	   if(num_bytes >= 2563542) {return 3}
	   else if(num_bytes >= 350122) {return 2}
	   else if (num_bytes >= 43922) {return 1}
	   else { return 0}
	}
}

function find_num_access_interval(num_access, num_column){

	if(eje_y_var != 1) {
		
	          if(num_column == 0){
			limit_x0 = 4
			limit_x1 = 8
		  }else if (num_column == 1){
			limit_x0 = 9
			limit_x1 = 20
		  }else if (num_column == 2){
			limit_x0 = 19
			limit_x1 = 46
		  }else if (num_column == 3){
			limit_x0 = 60
			limit_x1 = 123
		  }
           
	   if(num_access > limit_x1) {return 2}
	   else if (num_access > limit_x0) {return 1}
	   else { return 0}
	
	}else{
	   
	   if(num_access >= 17) {return 2}
	   else if (num_access >= 4) {return 1}
	   else { return 0}
   	}
}
BEGIN {before_time=0;time_interval=20*60;eje_y_var=0;sum_of_bytes=0;total_num_access=0;}
{ 

	if(NR==1){
		### Para hallar el tiempo de referencia que serán las 00:00 horas se convierte el timestamp al formato HH/mm/ss/nn
		
		"date +%H -d @"$1| getline ref_inicial_horas;
		"date +%M -d @"$1| getline ref_inicial_minutos;
		"date +%S.%N -d @"$1| getline ref_inicial_segundos;
		
		
		### Estas horas posteriormente se convierten a segundos, estos segundos representan el tiempo transcurrido desde las 00:00 			hasta el primer acceso
		### Por ejemplo se obtiene a partir del timestamp (1484571026.725658000)-> 13:50:26.725658000, posteriormente se pasa a 		segundos
		
		timestamp_since_midnight = (ref_inicial_horas * 3600 + ref_inicial_minutos * 60 + ref_inicial_segundos);

		 
		### Con estos segundos (49826.72566) ahora se divide entre 5*60 para averiguar el timestamp correspondiente al comienzo del 			primer intervalo de 5 minutos que afectaría a la traza correspondiente
		timestamp_primer_intervalo_relativo = timestamp_since_midnight / (time_interval);
		
		timestamp_primer_intervalo_relativo_parte_entera = int(timestamp_primer_intervalo_relativo);
		
		timestamp_primer_intervalo_relativo_parte_decimal = timestamp_primer_intervalo_relativo - 				       		        timestamp_primer_intervalo_relativo_parte_entera; 

		### En este punto se tiene el timestamp correspondiente al primer intervalo de cinco minutos
		timestamp_primer_intervalo_absoluto = $1-(timestamp_primer_intervalo_relativo_parte_decimal*time_interval);
		
		### Una vez se tiene la referencia de este primer timestamp del primer intervalo de 5 minutos ya se puede ir calculando cual 			será el comienzo del siguiente intervalo sumando a este 5*60 segundos. Ej. 1484571000 segundos -> primer referencia o dandole 			formato 13:50:00.000000000
		timestamp_siguiente_intervalo = timestamp_primer_intervalo_absoluto + (time_interval);		
		
		#printf "%.10f", ref_inicial_segundos
	}
	
	time_elapsed = $1 
		
	
	if(time_elapsed >= timestamp_siguiente_intervalo){

		 #printf"%s\n",strftime("%H:%M:%S", (timestamp_siguiente_intervalo))
		 #printf "%d \n", find_state(total_num_access, sum_of_bytes) 
		 #printf "%d %d %d\n", find_state(total_num_access, sum_of_bytes),total_num_access, sum_of_bytes
		 print find_state(total_num_access,sum_of_bytes), tot_lecturas, tot_escrituras, tot_ambas   
                 tot_lecturas = 0
		 tot_escrituras = 0
                 tot_ambas = 0		   	
                 sum_of_bytes=0;total_num_access=0;
		 # Averiguar si hay un intervalo donde no ha habido ningún acceso
		 time_elapsed_ratio = (time_elapsed - timestamp_siguiente_intervalo) / time_interval;

		 int_part=int(time_elapsed_ratio);
		 # si hay un intervalo sin ningún acceso se contabiliza
                 if(int_part >= 1 ){
			
		        
			for(i=1; i<= int_part;i++)
			{

				#printf"%d \n",find_state(total_num_access, sum_of_bytes)
				
			}
			
			timestamp_siguiente_intervalo  += (time_interval*(int_part+1));
			
		 }else{
			timestamp_siguiente_intervalo  += (time_interval);
		 }
		
		 
		
		 
	 	
	}
        
	
	sum_of_bytes += ($2 + $3)
	total_num_access +=1
	if ($2 > 0 && $3 == 0) tot_lecturas+= 1
	if ($3 > 0 && $2 == 0) tot_escrituras+= 1
        if ($3 > 0 && $2 > 0) tot_ambas+= 1

}
