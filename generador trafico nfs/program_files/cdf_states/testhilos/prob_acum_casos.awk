BEGIN {arr[0]=0.00001;arr[1]=0.0001;arr[2]=0.005;arr[3]=0.01;arr[4]=0.1;i=0}

{ 

	if ($1 > arr[i] && listo == 0 )

	{
		
		prob_casos[i]= $2 
		
		if(arr[i] == 0.1) { listo = 1 }
		i++

	}

	
}

END {

	printf "%0.12f %0.12f %0.12f %0.12f %0.12f\n", prob_casos[0], prob_casos[1],prob_casos[2],prob_casos[3],prob_casos[4] 

}
