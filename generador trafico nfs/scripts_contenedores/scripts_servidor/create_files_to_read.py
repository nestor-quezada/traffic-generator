#!/usr/bin/env python3
import multiprocessing
import os


# Crea los ficheros que se van a leer por los clientes
def create_file(num_bytes, path):
    content = bytes(int(num_bytes))
    if num_bytes == 0:
        with open(path, 'w') as server_file:
            server_file.truncate(0)
    else:
        with open(path, 'wb') as server_file:
            server_file.seek(0)
            server_file.write(content)


# Lee las lineas del fichero de observaciones
def load_obs_file(path):
    cont = 0
    with open(path, 'r') as obs_file:
        for line in obs_file:
            split = line.split()
            if len(split) == 4 and split[2] == 'r':
                create_file(split[1], os.path.join("/home/", split[3]))


# Recorre el directorio con los ficheros de observaciones de cada cliente
# para crear aquellos ficheros que se van a leer
def iterate_over_directory():

    directory_name = "/home/observaciones-with-path"
    for filename in os.listdir(directory_name):
        print(filename)
        # load_obs_file(os.path.join(directory_name , filename))
        multiprocessing.Process(target=load_obs_file, args=(os.path.join(directory_name, filename),)).start()


iterate_over_directory()
