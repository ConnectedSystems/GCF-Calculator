# cython: profile=True

from __future__ import division
import multiprocessing as mp
from joblib import Parallel, delayed
import random

import cython
from cython.parallel import prange
cimport numpy as np
import numpy as np
import time

def improved_modulo_cy(int val, int limit=0):
    cdef list factors = [1, val]
    cdef int x

    for x in xrange(2, val):
        if limit > 0 and x > limit:
            return factors

        if (val % x) == 0:
            factors.append(x)
        # End if
    # End for

    return factors
# End improved_modulo_cy()

@cython.cdivision(True)
cdef int nogil_rec_cy(int x1, int x2) nogil:
    if x2 == 0:
        return x1

    return nogil_rec_cy(x2, x1 % x2)
# End recursive_cy()

def recursive_cy(Py_ssize_t x1, Py_ssize_t x2):
    if x2 == 0:
        return x1

    return recursive_cy(x2, x1 % x2)
# End recursive_cy()


def parallel_rec_cy(list params, Py_ssize_t n_jobs):
    cdef list res
    cdef Py_ssize_t list_len

    list_len = len(params)
    res = Parallel(n_jobs=n_jobs)(delayed(reduce)(recursive_cy, (params[i], params[i + 1]))
                                  for i in xrange(0, list_len, 2))
    return reduce(recursive_cy, res)
# End

@cython.boundscheck(False)
def cython_parallel(list params, Py_ssize_t n_jobs):
    cdef np.ndarray[int] p_arr = np.array(params)
    cdef int l_len = len(params)
    cdef np.ndarray[int] res_arr = np.empty(int(l_len / 2), dtype='int')
    cdef int res_len = int(l_len / 2)
    cdef int i, j

    for i in prange(0, res_len, nogil=True, num_threads=n_jobs):
        j = i * 2
        res_arr[i] = nogil_rec_cy(p_arr[j], p_arr[j+1])

        with gil:
            time.sleep(1)
    # End for

    return res_arr
# End cython_parallel()
