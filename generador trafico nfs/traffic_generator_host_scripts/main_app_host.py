#!/usr/bin/env python3

from traffic_generator_host import TrafficGeneratorHost
from load_files_helper import LoadFilesHelper
import multiprocessing
import argparse
import os
import shutil

# Se puede cambiar la duracion de los intervalos
# pero cabe recalcar que el estudio se ha hecho para intervalos de 5 minutos
parser = argparse.ArgumentParser(description='Lanza el generador observaciones(muestras de operaciones para los clientes de w/r) de '
                                             'tráfico SMB/NFS')
parser.add_argument("-tt", "--total_time", default=8, type=int, help="Total execution time, in hours, default: 8")
parser.add_argument("-it", "--interval_time", default=5, type=int, help="Interval time, in minutes, default: 5")
## del tipo ya se ve que numero deusuarios se quiere crear
parser.add_argument("-tc", "--type_clients", default="1,0,0", type=str, help="Type of clients, default: 1,0,0; "
                                                                             "e.g: 1,2,0 -> this means 1 of type 0, "
                                                                             "2 of type 1 ,etc. or 9 only -> 9 type 0 ")
args = parser.parse_args()

interval_duration = args.interval_time
total_time = args.total_time
tipos_usuario = args.type_clients
# Carga de ficheros del programa
load_files_helper = LoadFilesHelper()


# Crea el array con todos los tipos de usuario que se necesitan instanciar, ej. [1 1 2 0] -> 2 tipo 1, 1 tipo 2 y 1
# tipo 0
def process_tipos_usario_arg(param):
    param_split = param.split(',')
    arr = []
    indice_user = 0
    for item in param_split:
        if int(item) > 0:
            arr += [indice_user] * int(item)
        indice_user += 1
    return arr


def create_generator(id_cliente, tipo_usuario):
    generador = TrafficGeneratorHost(load_files_helper, id_cliente, tipo_usuario, total_time * 3600,
                                     interval_duration * 60)
    generador.start()


## TODO:revisar si esta funcion es util, ya que creo se borra con bash la carpeta, aunque esta sirve para debug
def delete_observaciones_folder():
    folder = os.path.join(os.getcwd(), "observaciones")
    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))


def start():
    delete_observaciones_folder()
    arr_usuarios = process_tipos_usario_arg(tipos_usuario)
    ## TODO: este for debe cambiar por un array que sería una lista con todos lo stipos de usuarios
    ## Esta i es para controlar la reproducibilidad de las trazas
    i = 0
    for item in arr_usuarios:
        # TODO: Se puede utilizar el multiprocessing para generar las observaciones en menos tiempo
        # pero hay que decidir como configurar las semillas ya que random utiliza como semilla
        # el tiempo del sistema y crea observaciones iguales para todos los clientes
        # multiprocessing.Process(target=create_generator, args=(i,)).start()
        print('Creando ficheros observación para cliente_' + str(i))
        create_generator(i, item)
        i += 1


start()
