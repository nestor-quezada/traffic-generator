#!/usr/bin/env python3

import os
import sched
import time
import numpy as np
import numpy.random as ra
from generador_eventos import GeneradorEventos


class TrafficGeneratorHost:
    # duracion del intervalo 5 minutos, pero se puede cambiar si se le pasa otro valor como parametro
    INTERVAL_DURATION = 60 * 5
    # Duracion total de la ejecucion del programa
    TOTAL_DURATION = 60 * 60 * 8

    # Constructor
    def __init__(self, load_files_helper, id_cliente, tipo_usuario, total_execution_time=TOTAL_DURATION,
                 interval_time=INTERVAL_DURATION):

        self.id = id_cliente
        self.total_execution_time = total_execution_time
        self.interval_time = interval_time

        # var que controla el tiempo que transcurre. Al ser una simulación no se puede usar time.time()
        self.elapsed_time = 0
        self.out_directory_name = os.path.join(os.getcwd(), "observaciones")
        self.arr_prob_intervalo_inicial = load_files_helper.get_pdf_intervalo_inicial()
        self.primer_estado = self.get_first_state()
        # pasar el primer estado y que ejecute las operaciones durante el primer intervalo
        self.mgenerador_eventos = GeneradorEventos(load_files_helper, self.id)
        # Carga las matrices de transiciones segun el tipo de usuario
        self.matriz_transiciones = load_files_helper.get_matrices_transiciones()[tipo_usuario]
        self.fix_next_time = False
        self.sum=0
        self.time_to_fix = 0
        # ra.seed(self.id)

    # obtiene el primer estado utilizando probabilidades experimentales
    # Se hace de esta manera para modelar mejor el comportamiento,
    # ya que según la matriz de transiciones importa el estado del que se parte para calcular el siguiente estado.
    def get_first_state(self):
        prob_axis = self.arr_prob_intervalo_inicial[:, 1]
        state_axis = self.arr_prob_intervalo_inicial[:, 0]
        cum_prob = np.cumsum(prob_axis)

        r = ra.uniform(0, 1)
        # Transformada inversa discreta para obtener las muestras de los estados
        state_sample = state_axis[np.argwhere(cum_prob == min(cum_prob[(cum_prob - r) >= 0]))]
        return int(state_sample.squeeze())

    # Obtiene el estado siguiente
    def get_next_state(self, current_state):
        state_axis = np.array([])
        prob_array = self.matriz_transiciones[current_state]
        cont: int = 0
        # Crea array con estados, esto se hace asi ya que hay casos en los que no existen transiciones e.j. prob=0 ->
        # estado 3-> estado 5
        for i in prob_array:
            if i != 0:
                state_axis = np.append(state_axis, cont)
            cont += 1
        if 0 in prob_array:
            prob_array = np.delete(prob_array, np.where(prob_array == 0))
        cum_prob = np.cumsum(prob_array)
        r = ra.uniform(0, 1)
        state_sample = state_axis[np.argwhere(cum_prob == min(cum_prob[(cum_prob - r) >= 0]))]

        return int(state_sample.squeeze())

    def start(self, estado_actual=None, scheduler=None):

        if scheduler is None:
            estado_actual = self.get_first_state()

            self.mgenerador_eventos.update_state(estado_actual)
            # tiempo inicial del intervalo
            self.initial_time = 0
            # tiempo inicial de ejecución del programa
            self.initial_program_time = 0
            # Se crea el planificador para que ejecute el loop
            scheduler = sched.scheduler(time.time, time.sleep)
            scheduler.enter(0, 1, self.start, ([estado_actual, scheduler]))
            scheduler.run()

        if self.interval_time <= (self.elapsed_time - self.initial_time):

            if self.total_execution_time <= self.elapsed_time - self.initial_program_time:
                # print('tiempo_total:', self.elapsed_time)
                # sys.exit()

                return None

            self.initial_time = self.elapsed_time
            next_state = self.get_next_state(estado_actual)
            self.mgenerador_eventos.update_state(next_state)
            # print('Estado anterior:', estado_actual, 'Estado actual:', next_state)
            estado_actual = next_state



        # print('elapsed_time:', self.elapsed_time)
        next_time = self.mgenerador_eventos.get_next_time()
        num_bytes = self.mgenerador_eventos.genera_num_bytes()
        tipo_op = self.mgenerador_eventos.genera_tipo_op()

        # print de las observaciones
        # print("%0.12f %d %s %s" % (next_time, num_bytes, tipo_op, '/my/route/to/file'))

        # Se comprueba si el siguiente tiempo supera la duración del intervalo
        if self.interval_time <= ((self.elapsed_time + next_time) - self.initial_time):

            # si se supera, guardo el tiempo restante hasta finalizar el intervalo y se lo sumo al tiempo
            # transcurrido, de modo que se avance al siguiente intervalo
            self.remaining_time = self.interval_time - (self.elapsed_time - self.initial_time)

            self.elapsed_time += self.remaining_time
            self.fix_next_time = True
            self.time_to_fix += self.remaining_time
            #print("elapsed_time:", self.elapsed_time - self.initial_time)
        else:
            self.elapsed_time += next_time
            if self.fix_next_time:
                next_time += self.time_to_fix
                self.time_to_fix = 0
                self.fix_next_time = False

            self.sum += next_time

            with open(self.out_directory_name + "/cliente-" + str(self.id), 'a+') as myfile:
                myfile.write("%0.12f %d %s\n" % (next_time, num_bytes, tipo_op))

        scheduler.enter(0, 1, self.start, ([estado_actual, scheduler]))