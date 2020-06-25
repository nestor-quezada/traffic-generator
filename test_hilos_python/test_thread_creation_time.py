#!/usr/bin/env python3

import threading
import time
import argparse

arr = []

parser = argparse.ArgumentParser(description='Lanza el generador de tráfico SMB/NFS')
parser.add_argument("-nt", "--number_times", default=5, type=int, help="Number of times to execute the thread "
                                                                       "creation time, default: 5 ")

args = parser.parse_args()
number_times = args.number_times


def get_diff_time(time_creation):
    # if i == 0 or i == 9:
    arr.append(time.time() - time_creation)
    #print(time.time() - time_creation)


def foo_2():
    pass


def test_1(num_threads):
    sum = 0
    for i in range(num_threads):

        time_creation = time.time()
        threading.Thread(target=get_diff_time, args=(time_creation,)).start()
        #time.sleep(0.0001)

    for i in arr:
        sum = sum + i

    return (sum - 1) / num_threads


def test_2(num_threads):
    t0 = time.time()
    for i in range(num_threads):
        threading.Thread(target=foo_2, args=()).start()

    t1 = time.time() - t0
    return t1 / num_threads


num = number_times
print("Metodo 1 %0.12f s/hilo" % test_1(num))
#print("Metodo 2 %0.12f ms/hilo" % test_2(num))

