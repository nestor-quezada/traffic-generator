#!/usr/bin/env python3
import numpy.random as ra


def test(j):
    r = ra.uniform(0, 1)

    with open("test.txt", 'a+') as myfile:
        myfile.write("%d %0.12f\n" % (j, r))


for i in range(10000):
    test(i)
