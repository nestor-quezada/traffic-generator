#!/usr/bin/env python3

import os

import numpy as np
import numpy.random as ra
from scipy import interpolate


class GeneradorEventos:

    # Constructor
    def __init__(self, load_file_helper, id):
        self.id = id
        # Path de la carpeta con los ficheros cdf (tiempos entre llegads)de cada estado
        self.cdfs_time_array = load_file_helper.get_cdfs_time()
        # Path de la carpeta con los ficheros cdf (bytes w/r) de cada estado
        self.cdfs_bytes_array = load_file_helper.get_cdfs_bytes()
        # Lee fichero con las probabilidades de w/r
        self.arr_prob_w_r = load_file_helper.get_pdf_w_r()
        # ra.seed(self.id)

    def get_cdf_inv(self, cdf_array, estado_actual):
        split_cdf_arr = np.hsplit(cdf_array[estado_actual][0], 2)
        # eje x (observaciones) de la cdf
        x_axis = split_cdf_arr[0].squeeze()
        # eje y (probabilidades acumuladas) de la cdf
        cum_prob = split_cdf_arr[1].squeeze()
        # Interpolacion de la transformada inversa de la CDF,
        # para valores donde no es posible interpolar se le asigna el primer valor de los datos x[0]

        cdf_inv = interpolate.interp1d(cum_prob, x_axis, fill_value=(x_axis[0]), bounds_error=False)
        return cdf_inv

    def update_state(self, estado_actual):
        self.inv_cdf_time = self.get_cdf_inv(self.cdfs_time_array, estado_actual)
        self.inv_cdf_bytes = self.get_cdf_inv(self.cdfs_bytes_array, estado_actual)
        self.current_prob_w_r = self.arr_prob_w_r[estado_actual]

    # Get del siguiente tiempro entre llegadas
    def get_next_time(self):
        r = ra.uniform(0, 1)
        time_sample = self.inv_cdf_time(r)
        #print("time:",time_sample)
        return time_sample

    # Obtiene el numero de bytes a leer o escribir
    def genera_num_bytes(self):
        r = ra.uniform(0, 1)
        bytes_sample = self.inv_cdf_bytes(r)
        #print("bytes:", bytes_sample)
        return np.round(bytes_sample)

    # obtiene el tipo de operacion (leer o escribir), se van a ignorar los casos de ambas a la vez (only 4% global)
    def genera_tipo_op(self):
        tipo_op = np.random.choice(['r', 'w'], p=[self.current_prob_w_r[0], self.current_prob_w_r[1]])
        return tipo_op
