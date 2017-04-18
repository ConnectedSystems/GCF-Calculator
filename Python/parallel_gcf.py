import random
import cProfile
import pyximport
pyximport.install()

from py_gcf import improved_modulo_py, improved_modulo_cy, recursive, py_loop
from cy_gcf import cython_parallel, cy_loop, recursive_cy

import multiprocessing as mp
from joblib import Parallel, delayed


def parallel_get_gcf(func, params, n_jobs=4):
    params = map(abs, params)
    params.sort()
    sets = []

    res = Parallel(n_jobs=n_jobs)(delayed(func)(val) for val in params[0:2])
    sets.extend(res)

    temp = reduce(lambda x, y: list(set(x).intersection(y)), sets)

    return max(temp)
# End parallel_get_gcf()


def parallel_mod(func, params, n_jobs):
    return parallel_get_gcf(func, params, n_jobs)
# End parallel()


def parallel_mod_cy(func, params, n_jobs):
    return parallel_get_gcf(improved_modulo_cy, params, n_jobs)
# End parallel()


def parallel_rec_py(params, n_jobs):
    assert len(params) % 2 == 0, "Parallel method expects number of parameters to be even!"
    params = Parallel(n_jobs=n_jobs)(delayed(abs)(i) for i in params)
    # params = map(abs, params)
    params = [(params[i], params[i + 1]) for i in xrange(0, len(params), 2)]
    res = Parallel(n_jobs=n_jobs)(delayed(recursive)(*i) for i in params)

    # Return a list of parameters mapped to their GCF
    return zip(params, res)
# End


def parallel_rec_cy(params, n_jobs):
    assert len(params) % 2 == 0, "Parallel method expects number of parameters to be even!"

    params = Parallel(n_jobs=n_jobs)(delayed(abs)(i) for i in params)
    # params = map(abs, params)

    params = [(params[i], params[i + 1]) for i in xrange(0, len(params), 2)]
    res = Parallel(n_jobs=n_jobs)(delayed(recursive_cy)(*i) for i in params)

    return zip(params, res)
# End


if __name__ == '__main__':

    random.seed(10)
    print("Available threads: {}".format(mp.cpu_count()))
    # n_procs = mp.cpu_count()
    n_procs = 3
    print("Using {} threads".format(n_procs))

    # Generate random numbers
    params = random.sample(xrange(16000, 2501296), 2000000)

    # print("Parallel Python (modulo)")
    # print(parallel_mod(improved_modulo_py, params, n_procs))
    # cProfile.run('parallel_mod(improved_modulo_py, params, n_procs)')

    # print("Parallel Cython (modulo)")
    # print(parallel_mod(improved_modulo_cy, params, n_procs))
    # cProfile.run('parallel_mod(improved_modulo_cy, params, n_procs)')

    # print("Parallel Python (recursion)")
    # print(parallel_rec_py(params, n_procs)[0:6], "...")
    # cProfile.run('parallel_rec_py(params, n_procs)')

    print("Parallel Cython (recursion)")
    res = cython_parallel(params, n_procs)
    print(res[0:6], "...\n")
    cProfile.runctx("res = cython_parallel(params, n_procs)", globals(), locals())

    print("Equivalent single thread Python (recursion)")
    res = py_loop(recursive, params)
    print(res[0:6], "...\n")
    cProfile.runctx("res = py_loop(recursive, params)", globals(), locals())

    print("Equivalent single thread Python with Cython recursion")
    res = py_loop(recursive_cy, params)
    print(res[0:6], "...\n")
    cProfile.runctx("res = py_loop(recursive_cy, params)", globals(), locals())

    print("Equivalent single thread Cython (recursion)")
    res = cy_loop(params)
    print(res[0:6], "...\n")
    cProfile.runctx("res = cy_loop(params)", globals(), locals())

    # print "On Windows, the overhead of spawning threads seems to outweight the benefits..."
    # print(reduce(recursive_cy, params))
    # cProfile.run('reduce(recursive_cy, params)')
