import random

import cython
cimport cython

import itertools as itools

from cython.parallel import prange

from cpython cimport array
import array
cimport numpy as np
import numpy as np

def py_recursive(x1, x2):
    if x2 == 0:
        return x1

    return py_recursive(x2, x1 % x2)
# End py_recursive()

@cython.cdivision(True)
@cython.nonecheck(False)
cdef int nogil_rec(Py_ssize_t x1, Py_ssize_t x2) nogil:
    if x2 == 0:
        return x1

    return nogil_rec(x2, x1 % x2)
# End nogil_rec()

cpdef Py_ssize_t cy_recursive(Py_ssize_t x1, Py_ssize_t x2):
    if x2 == 0:
        return x1

    return cy_recursive(x2, x1 % x2)
# End recursive_cy()

def py_single_rec(func, params):
    params = map(abs, params)
    return reduce(func, params)
# End py_single_rec()

def py_single_iter_rec(func, params):
    params = itools.imap(abs, params)
    return reduce(func, params)
# End py_single_rec()

@cython.boundscheck(False)
@cython.nonecheck(False)
@cython.cdivision(True)
@cython.wraparound(False)
cpdef Py_ssize_t cy_large_gcf(np.ndarray[int, ndim=1] params):
    cdef int i, tmp
    cdef np.ndarray[int, ndim=1] ret = params[0:2]

    tmp = params.size
    for i in range(1, tmp):
        ret[1] = params[i]
        ret[0] = nogil_rec(ret[0], ret[1])
        if ret[0] == 1:
            return 1
        # End if
    # End for

    return ret[0]
# End cy_large_gcf()

@cython.boundscheck(False)
@cython.nonecheck(False)
@cython.cdivision(True)
@cython.wraparound(False)
cpdef Py_ssize_t cy_large_array_gcf(array.array[int, ndim=1] params):
    cdef int i, tmp
    cdef array.array[int, ndim=1] res = params[0:2]

    tmp = params.buffer_info()[1]
    for i in range(1, tmp):
        res[1] = params[i]
        res[0] = nogil_rec(res[0], res[1])
        if res[0] == 1:
            return 1
    # End for

    return res[0]
# End cy_large_gcf()

@cython.boundscheck(False)
@cython.nonecheck(False)
@cython.cdivision(True)
@cython.wraparound(False)
cpdef Py_ssize_t cython_parallel(np.ndarray[int, ndim=1] p_arr, Py_ssize_t n_jobs):
    cdef int i, j
    cdef int res_len = (p_arr.size / 2)
    cdef np.ndarray[int, ndim=1] res_arr = p_arr[0:res_len]

    for i in prange(0, res_len, nogil=True, num_threads=n_jobs):
        j = i * 2
        res_arr[i] = nogil_rec(p_arr[j], p_arr[j+1])
    # End for

    if np.any(res_arr == 1):
        return 1

    if res_len > 1:
        res_arr = cython_parallel(res_arr, n_jobs)

    return res_arr[0]
# End cython_parallel()
