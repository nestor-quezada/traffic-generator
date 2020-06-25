#!/bin/bash

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

## CONTENEDOR-SERVIDOR
server_name="servidor-ficheros"
# Elimina el contenedor que se ha creado en anteriores ejecuciones
if lxc list | grep $server_name >/dev/null ;
then
  lxc stop $server_name
  lxc rm $server_name
fi
# Crea y lanza el contenedor
lxc launch alpine-cliente $server_name
# Lo configuramos como privilegiado para poder hacer el mount de ficheros SMB (Docs Apparmor for more info!!)
lxc config set $server_name security.privileged true
# Restart del container para que tenga en cuenta los cambios
lxc restart $server_name
# Permitir mounts NFS/SMB
lxc config set $server_name raw.apparmor 'mount fstype=rpc_pipefs, mount fstype=nfsd, mount fstype=nfs, mount fstype=nfs4, mount fstype=cifs, '
# Elimina la carpeta con las observaciones cada vez que arranca
lxc exec $server_name -- rm -rfv /home/observaciones >/dev/null #&>/dev/null
# Copia las observaciones al servidor para que este genere los archivos a leer por los clientes
lxc file push -r observaciones/ $server_name/home/ >/dev/null
# Sobreescribir los ficheros para que tengan el tamaño segun la cdf de bytes w/r
lxc exec $server_name -- /home/create_files_from_observations.sh /home/observaciones/
# Merge de los ficheros de observaciones para que tengan los correspondientes paths creado por impressions
lxc exec $server_name -- /home/update_observations_file_path.sh observaciones/
echo "Creando ficheros para operaciones w/r en el servidor..."
lxc exec $server_name -- python3 /home/create_files_to_read.py
lxc exec $server_name -- chmod -R 777 /mnt/shared
# Copia las observaciones al host para pasarselas a los clientes, esto se hace asi ya que impressions se ejecuta dentro del contenedor
# y por lo tanto las rutas de los ficheros no las conoce el host.
rm -rfv observaciones-with-path/
lxc file pull -r $server_name/home/observaciones-with-path/ ./  #>/dev/null

# Get IP del servidor para configurar los clientes
# Hack para esperar que el contenedor obtenga una IP, también se podría configurar manualmente
echo "Obteniendo dirección IP del servidor..."
server_ip="$(get_ip "$server_name")"