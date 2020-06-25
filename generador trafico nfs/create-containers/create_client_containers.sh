#!/bin/bash

# SET PARAMETROS
server_ip=$1
block_size=$2
start_time=$4
num_cont=$3

# Hack para detectar cuando el contenedor tiene ya una IP, también se podría asignar manualmente.
get_ip () {

  ip=$(lxc list "$1" -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')
  until [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
  do
    ip=$(lxc list "$1" -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')
    sleep 0.1s
  done

  echo "$ip"
}

## Borra los contenedores existentes de anteriores lanzamientos, ya que sino se bloquea al obtener IP's

num_cont_del=$(lxc list | grep -c cliente- )

for (( c=0; c < num_cont_del; c++ ))
do
  client_name_del="cliente-"$c
  # Elimina los contenedores que se han creado en anteriores ejecuciones
  if lxc list | grep $client_name_del >/dev/null ;
  then
    lxc stop $client_name_del
    lxc rm $client_name_del
  fi

done


for (( c=0; c < $num_cont; c++ ))
do
  client_name="cliente-"$c
  # Elimina los contenedores que se han creado en anteriores ejecuciones
  if lxc list | grep $client_name >/dev/null ;
  then
    lxc stop cliente-"$c"pa
    lxc rm cliente-"$c"
  fi
  # Crea y lanza el contenedor
  lxc launch imagen-cliente $client_name
  # Copia el fichero de las observaciones correspondientes del cliente
  lxc file push observaciones-with-path/"$client_name" "$client_name"/home/observacion >/dev/null
  # Lo configuramos como privilegiado para poder hacer el mount de ficheros SMB (Docs Apparmor for more info!!)
  lxc config set $client_name security.privileged true
  # Restart del container para que tenga en cuenta los cambios
  lxc restart $client_name
  # Permitir mounts NFS/SMB
  lxc config set $client_name raw.apparmor 'mount fstype=rpc_pipefs, mount fstype=nfsd, mount fstype=nfs, mount fstype=nfs4, mount fstype=cifs, '
  #Crear directorio para mount
  lxc exec $client_name -- mkdir /mnt/shared-client
  # Config mount SMB
  # Hack para que el cliente espere a tener IP
  echo "Obteniendo dirección IP de $client_name..."
  client_ip="$(get_ip "$client_name")"
  lxc exec $client_name  -- mount -t cifs -o rw,guest,vers=2.0  //$server_ip/main_directory /mnt/shared
  # Run del daemon AT para ejecutar la tarea
  lxc exec $client_name -- rc-service atd restart
  # Programa el script de generacion del cliente para que se ejecute en el tiempo determinado por parametro o default
  if [ -z "$start_time" ];
    then

      # Opcion por defecto, programalo de forma immediata
      ahora=$(date +"%H:%M")
      echo "El programa de acceso a ficheros de "$client_name" iniciara a las ""$ahora"
      lxc exec $client_name -- at now <<< "python3 /home/main_app_client.py -bs "$block_size" &> /home/out.log"
    else

      echo "El programa de acceso a ficheros de "$client_name" iniciara a las ""$start_time"
      # Caso de que el usuario programe que empieze a una hora determianda formato e.j. 12:00
      lxc exec $client_name -- at $start_time <<< "python3 /home/main_app_client.py -bs "$block_size" &> /home/out.log"

    fi

done