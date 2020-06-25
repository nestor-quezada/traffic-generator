#!/bin/bash

num_cont=$1

num_times=$2

start_time=$3

for (( c=0; c < num_cont; c++ ))
do
  client_name="cliente-test-"$c
  # Elimina los contenedores que se han creado en anteriores ejecuciones
  if lxc list | grep $client_name >/dev/null ;
  then
    lxc stop "$client_name"
    lxc rm "$client_name"
  fi
  # Crea y lanza el contenedor
  lxc launch imagen-cliente $client_name
  # Copia el fichero de las observaciones correspondientes del cliente
  # lxc exec $client_name -- /home/test/test_thread_creation_time.py -nt "$num_times"
  # Run del daemon AT para ejecutar la tarea
  lxc exec $client_name -- rc-service atd restart
  if [ $c -eq 0 ]
  then
      lxc exec $client_name -- at "$start_time" <<< "/home/test/test_thread_creation_time.py -nt $num_times &> /home/test/out.log"
  else
      lxc exec $client_name -- at "$start_time" <<< "/home/test/test_thread_creation_time.py -nt $num_times"
  fi

done

echo "testing, this will take a few seconds.."

num_lines=$( lxc exec "cliente-test-0" -- awk '{sum+=1}END{print sum}' "/home/test/out.log" )
until [[  $num_lines -gt 0 ]]
  do
    num_lines=$( lxc exec "cliente-test-0" -- awk '{sum+=1}END{print sum}' "/home/test/out.log" )
    sleep 0.1s
  done

# Imprime resultados del test
echo "----------------------------------------------------------------------------------------"
echo "Resultados test:"
echo "Parámetro entrada:"
echo "+ Número contenedores="$num_cont
echo "+ Número iteraciones="$num_times
lxc exec "cliente-test-0" -- cat  "/home/test/out.log"
echo "----------------------------------------------------------------------------------------"
echo "cleaning up the house a little bit..."

for (( c=0; c < num_cont; c++ ))
do
  client_name="cliente-test-"$c
  # Elimina los contenedores que se han creado en anteriores ejecuciones
  if lxc list | grep $client_name >/dev/null ;
  then
    lxc stop $client_name
    lxc rm $client_name
  fi

done

echo "Test Finalizado"