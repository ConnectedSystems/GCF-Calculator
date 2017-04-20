import random

import cython
cimport cython

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
cdef int nogil_rec(int x1, int x2) nogil:
    if x2 == 0:
        return x1

    return nogil_rec(x2, x1 % x2)
# End nogil_rec()

def cy_recursive(Py_ssize_t x1, Py_ssize_t x2):
    if x2 == 0:
        return x1

    return cy_recursive(x2, x1 % x2)
# End recursive_cy()

def py_single_rec(func, params):
    map(abs, params)
    return reduce(func, params)
# End py_single_rec()

def py_array_rec(func, params):
    map(abs, params)
    return reduce(func, params)

@cython.boundscheck(False)
@cython.nonecheck(False)
@cython.cdivision(True)
@cython.wraparound(False)
cpdef np.ndarray[int] cy_large_gcf(np.ndarray[int] params):
    cdef int i, j, tmp
    tmp = (params.size / 2)
    cdef np.ndarray[int] res_arr = params[0:tmp]

    for i in xrange(0, tmp):
        j = i * 2
        res_arr[i] = nogil_rec(params[j], params[j + 1])
    # End for

    if tmp > 1:
        res_arr = cy_large_gcf(res_arr)

    return res_arr
# End cy_large_gcf()

@cython.boundscheck(False)
@cython.nonecheck(False)
@cython.cdivision(True)
@cython.wraparound(False)
cpdef array.array cy_large_array_gcf(array.array params):
    cdef int i, j, tmp
    tmp = (params.buffer_info()[1] / 2)
    cdef array.array res_arr = params[0:tmp]

    for i in xrange(0, tmp):
        j = i * 2
        res_arr[i] = nogil_rec(params[j], params[j + 1])
    # End for

    if tmp > 1:
        res_arr = cy_large_array_gcf(res_arr)

    return res_arr
# End cy_large_gcf()

@cython.boundscheck(False)
@cython.nonecheck(False)
@cython.cdivision(True)
@cython.wraparound(False)
cpdef np.ndarray[int] cython_parallel(np.ndarray[int] p_arr, Py_ssize_t n_jobs):
    cdef int i, j
    cdef int res_len = (p_arr.size / 2)
    cdef np.ndarray[int] res_arr = p_arr[0:res_len]

    for i in prange(0, res_len, nogil=True, num_threads=n_jobs):
        j = i * 2
        res_arr[i] = nogil_rec(p_arr[j], p_arr[j+1])
    # End for

    if res_len > 1:
        res_arr = cython_parallel(res_arr, n_jobs)

    return res_arr
# End cython_parallel()
