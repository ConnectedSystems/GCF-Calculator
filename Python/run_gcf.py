import random
import cProfile
import pyximport
pyximport.install()

import numpy as np
import array
from fractions import gcd
from gcf import py_single_rec, py_single_iter_rec, py_recursive, cy_recursive, \
    cy_large_gcf, cy_large_array_gcf, cython_parallel

import itertools as itools
import multiprocessing as mp
from joblib import Parallel, delayed

if __name__ == '__main__':
    random.seed(10)
    print("Available threads: {}".format(mp.cpu_count()))
    n_procs = int(max(1, round(mp.cpu_count() / 2) - 1))
    n_procs = 3
    print("Using {} threads for parallel examples".format(n_procs))

    # Import search values
    with open("../data/input.in", "r") as infile:
        lines = infile.readlines()[1:]
        for i, l in enumerate(lines):
            lines[i] = map(int, l.split(" "))
    # End with
    params = lines[0]

    print "Builtin gcd function"
    print(reduce(gcd, map(abs, params)))
    cProfile.run('reduce(gcd, params)')

    print "Single Thread Python map (recursion)"
    print(py_single_rec(py_recursive, params))
    cProfile.run('py_single_rec(py_recursive, params)')

    print "Single Thread Python with itertools (recursion)"
    print(py_single_iter_rec(py_recursive, params))
    cProfile.run('py_single_iter_rec(py_recursive, params)')

    print "Single Thread Python map (recursion) w/ array.array"
    print(py_single_rec(py_recursive, array.array('i', params)))
    cProfile.run('py_single_rec(py_recursive, array.array("i", params))')

    print "Single thread Cython (recursion)"
    print(cy_large_gcf(np.array(params)))
    cProfile.run('cy_large_gcf(np.array(params))')

    print "Single thread Cython w/ array.array (recursion)"
    print(cy_large_array_gcf(array.array('i', params)))
    cProfile.run('cy_large_array_gcf(array.array("i", params))')

    print "Parallel Cython (recursion)"
    print(cython_parallel(np.array(params, dtype=int), n_procs))
    cProfile.run('cython_parallel(np.array(params), n_procs)')
