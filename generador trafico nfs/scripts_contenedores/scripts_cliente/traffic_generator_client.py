#!/usr/bin/env python3

import os
import threading
from time import sleep


class TrafficGeneratorClient:
    BLOCK_SIZE = 4096
    PATH_FICHERO_OBSERVACIONES = '/home/observacion'

    # Constructor
    def __init__(self, block_size=BLOCK_SIZE):

        self.tiempo_anterior = 0
        self.block_size = block_size
        # Lee fichero con las observaciones
        with open(self.PATH_FICHERO_OBSERVACIONES) as fichero_obs:
            self.arr_obs = [line for line in fichero_obs]

    def ejecuta_operacion(self, num_bytes, tipo_operacion, path_file):
        block_of_bytes = bytes(self.block_size)

        # ls del directorio
        # path_directory = path_file.rsplit('/', 1)[0]
        # os.system("ls -l " + path_directory + " > /dev/null")

        if tipo_operacion == "w":
            bytes_left_to_write = num_bytes

            with open(path_file, 'wb', 0) as myfile:

                while bytes_left_to_write >= self.block_size or bytes_left_to_write > 0:
                    if bytes_left_to_write >= self.block_size:
                        myfile.write(block_of_bytes)
                    else:
                        myfile.write(bytes(bytes_left_to_write))
                    # Fuerza a escribir en disco los bytes
                    myfile.flush()
                    os.fsync(myfile.fileno())
                    bytes_left_to_write -= self.block_size

        elif tipo_operacion == "r":
            with open(path_file, 'rb', 0) as myfile:
                bytes_left_to_read = num_bytes
                while bytes_left_to_read >= self.block_size or bytes_left_to_read > 0:
                    if bytes_left_to_read >= self.block_size:
                        myfile.read(self.block_size)
                    else:
                        myfile.read(bytes_left_to_read)

                    bytes_left_to_read -= self.block_size

    def start(self):
        i = 0
        while True:

            # Procesado observacion ej. ('tiempo entre llegadas' 'bytes' 'path' 'tipo op')
            obs = self.arr_obs[i].split()
            interarrival_time = float(obs[0])
            num_bytes = int(obs[1])
            tipo_op = obs[2]
            path_file = obs[3]

            # Espera el tiempo entre llegadas para volver a entrar en la funcion
            sleep(float(interarrival_time))
            threading.Thread(target=self.ejecuta_operacion, args=(num_bytes, tipo_op, path_file)).start()

            i += 1

            # Termina el programa cuando se acaben las observaciones
            if i == len(self.arr_obs):
                break
