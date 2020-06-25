#!/bin/bash

usage="$(basename "$0") [-h] [-n] [-b] [-s] [-t] [-i] [-u] -- launches container-clients that execute file access operations against the container-server.

where:
    -h  show this help text
    -n  set the number of clients(containers) (default: 1)
    -b  set the block size of writing/reading, in bytes (default: 4096)
    -s  set the start time of the client acceses, e.g 17:00 (default: as immediately as it can)
    -t  set the total execution time of the traffic generation, in hours (default: 8)
    -i  set the interval time, in minutes (default: 5)
    -u  set the user types, e.g. 1,7,1 (3 types) or 1,2 (2 types) (default: 1( 1 type)), depends on the available number of user types"

die () {
    echo >&2 "$@"
    exit 1
}

while getopts ':hn:b:s:t:i:u:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    # Número de contenedores
    n) num_cont=$OPTARG
       ;;
    # Tamaño del bloque de w/r
    b)echo "$OPTARG" | grep -E -q '^[0-9]+$' || die "Numeric argument required, $OPTARG provided"
       block_size=$OPTARG
       ;;
    # Hora de inicio del generador cliente
    s) start_time=$OPTARG
       ;;
    # Tiempo total de ejecución
    t) total_time=$OPTARG
	     ;;
	  # Tipo usuarios
    u) echo "$OPTARG" | grep -E -q '^[0-9]*(,[0-9]*)*$' || die "Invalid argument: $OPTARG, e.g: 1 or 1,2,3"
       tipo_usuarios=$OPTARG
	     ;;
	  # Tiempo del intervalo
    i) echo "$OPTARG" | grep -E -q '^[0-9]+$' || die "Numeric argument required, $OPTARG provided"
       interval_time=$OPTARG
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done

# PARAMETROS
num_cont="${num_cont:-0}"
block_size="${block_size:-4096}"
total_time="${total_time:-8}"
interval_time="${interval_time:-5}"
tipo_usuarios="${tipo_usuarios:-"1"}"

# Validacion argumento tipos de usuario
num_tipos_user=$(ls 'program_files/tipos_usario/matrices_transiciones' | wc -l)
IFS=',' read -r -a arr_tipos_user <<< "$tipo_usuarios"
cont=0
minimum=0
for el in "${arr_tipos_user[@]}"
do
    if (( el>0 )); then minimum=1 ; fi
    ((cont++))
done

# Comprueba que el numero de usuarios sea mayor de cero
if((minimum == 0 )); then die " Argument not valid, number of users equal to zero" ;fi
# Comprueba que el usuario no pase al programa tipos de usuario que no existen.
if((cont > num_tipos_user )); then die "There are not enought user type files, currently user types files: $num_tipos_user
 User types folder path: program_files/tipos_usario/matrices_transiciones/" ;fi

## CREACION FICHEROS OBSERVACIONES
# Lanza el script para crear los ficheros con las observaciones(operaciones de w/r) que se ejecutarán desde cada contenedor cliente.
# Al final de este loop se tendrá un directorio con tantos ficheros de observaciones como clientes.
mkdir -p observaciones
## TODO:rm es un comando con el que hay que andarse con cuidado, buscar otra forma de safely-remove things rm-trash maybe¿?
rm -rfv observaciones/*
echo "Creando ficheros de observaciones(operaciones w/r) para los clientes ..."
## TODO:borrar variable num_cont
python3 "traffic_generator_host_scripts/main_app_host.py" -tt "$total_time"  -it "$interval_time" -tc "$tipo_usuarios"

## CREACION SERVIDOR
./create-containers/create_server_container.sh

server_ip=$(lxc list "servidor-ficheros" -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')
# lxc exec servidor-ficheros -- tshark -p -w traza_smb_1c.pcap -f "port 445" >/dev/null
lxc exec servidor-ficheros -- at now <<< 'tshark -p -w traza.pcap -f "port 445"'


#CREACION CLIENTES
num_cont=0
IFS=',' read -r -a array <<< "$tipo_usuarios"
for element in "${array[@]}"
do
    num_cont=$((num_cont + element))
done

./create-containers/create_client_containers.sh "$server_ip" "$block_size" $num_cont "$start_time"


