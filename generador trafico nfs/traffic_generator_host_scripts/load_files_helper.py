#!/usr/bin/env python3

import os
import numpy as np


class LoadFilesHelper:

    NUMBER_OF_STATES = 10
    PATH_CDFS_INTERARRIVAL_TIME = 'program_files/cdf_states/interarrival_times'
    PATH_CDFS_BYTES_W_R = 'program_files/cdf_states/bytes_w_r'
    PATH_PROB_W_R_PER_STATE = 'program_files/probabilidades_w_r.txt'
    PATH_PROB_INI_INTERVAL = 'program_files/prob_intervalo_inicial.txt'

    # Constructor
    def __init__(self):
        # Path de la carpeta con los ficheros cdf (tiempos entre llegads)de cada estado
        self.cdfs_time_array = self.get_cdfs_array(
            os.path.join(os.getcwd(), self.PATH_CDFS_INTERARRIVAL_TIME))
        # Path de la carpeta con los ficheros cdf (bytes w/r) de cada estado
        self.cdfs_bytes_array = self.get_cdfs_array(os.path.join(os.getcwd(), self.PATH_CDFS_BYTES_W_R))
        # Lee fichero con las probabilidades de w/r
        self.arr_prob_w_r = np.loadtxt(fname=self.PATH_PROB_W_R_PER_STATE)
        self.arr_prob_intervalo_inicial = np.loadtxt(fname=self.PATH_PROB_INI_INTERVAL)

        self.tipos_usuario = TiposUsuario()

    # Obtiene el array donde cada elemento es la cdf de cada estado, bien de bytes o bien de tiempos
    def get_cdfs_array(self, path):
        # print('app:get cdfs array')
        all_cdfs = [None] * self.NUMBER_OF_STATES
        # Recorre todos los archivos y los carga en un array
        for i in range(0, self.NUMBER_OF_STATES):
            # Carga el fichero en un array 1 columna: tiempos entre llegadas 2 col: casos o prob
            cdf_state = np.loadtxt(fname=os.path.join(path, "state_norm_" + str(i)))
            all_cdfs[i] = np.array([cdf_state])

        return all_cdfs

    def get_cdfs_bytes(self):
        return self.cdfs_bytes_array

    def get_cdfs_time(self):
        return self.cdfs_time_array

    def get_pdf_w_r(self):
        return self.arr_prob_w_r

    def get_pdf_intervalo_inicial(self):
        return self.arr_prob_intervalo_inicial

    def get_matrices_transiciones(self):
        return self.tipos_usuario.get_mtx_transiciones()


class TiposUsuario:
    PATH_MATRICES_TRANSICIONES = 'program_files/tipos_usario/matrices_transiciones/'

    def __init__(self):
        directory = self.PATH_MATRICES_TRANSICIONES

        self.tipos_usuario_mtx_transiciones = []
        for filename in os.listdir(directory):
            mtx_transiciones_user = np.loadtxt(fname=directory + filename)
            self.tipos_usuario_mtx_transiciones.append(mtx_transiciones_user)

    def get_mtx_transiciones(self):
        return self.tipos_usuario_mtx_transiciones
