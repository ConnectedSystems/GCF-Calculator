import random
import cProfile
import pyximport
pyximport.install()

import numpy as np

from cy_gcf import recursive_cy, improved_modulo_cy

from joblib import Parallel, delayed
import multiprocessing as mp


def get_gcf(func, params):
    sets = map(func, map(abs, params))
    temp = reduce(lambda x, y: list(set(x).intersection(y)), sets)

    return max(temp)
# End get_gcf()


def mod_get_gcf(func, params):
    params = map(abs, params)
    params.sort()
    sets = [func(params[0])]
    limit = max(sets[0])

    sets.extend([func(params[1], limit)])
    temp = reduce(lambda x, y: list(set(x).intersection(y)), sets)

    return max(temp)
# End mod_get_gcf()


def naive_py(val):
    factors = [1, val]
    for x in range(2, val):
        for y in range(x, val):
            if (x * y) == val:
                factors.extend([x, y])
            # End if
        # End for
    # End for

    return factors
# End naive_py()


def improved_modulo_py(val, limit=0):
    factors = [1, val]
    for x in xrange(2, val):
        if limit > 0 and x > limit:
            return factors

        if (val % x) == 0:
            factors.append(x)
        # End if
    # End for

    return factors
# End improved_modulo_py()


def recursive(x1, x2):
    if x2 == 0:
        return x1

    return recursive(x2, x1 % x2)
# End recursive()


def single_rec(func, params):
    map(abs, params).sort()
    return reduce(func, params)


def recursive(x1, x2):
    if x2 == 0:
        return x1

    return recursive(x2, x1 % x2)
# End recursive()


def single_rec_map(func, params):
    assert len(params) % 2 == 0, "Parallel method expects number of parameters to be even!"
    params = map(abs, params)
    params = [(params[i], params[i + 1]) for i in xrange(0, len(params), 2)]
    res = [func(*i) for i in params]

    return zip(params, res)
# End


def py_loop(func, params):
    p_arr = np.array(params)
    res_arr = np.empty(int(len(params) / 2), dtype='int')

    for i in xrange(0, len(res_arr)):
        j = i * 2
        res_arr[i] = func(p_arr[j], p_arr[j + 1])
    # End for

    return res_arr
# End py_loop


if __name__ == '__main__':
    random.seed(10)
    print("Available threads: {}".format(mp.cpu_count()))
    # n_procs = mp.cpu_count()
    n_procs = 4
    print("Using {} threads".format(n_procs))

    vals = [1600, 1200, 800]
    expanded = [1600, 1200, 800, 8000, 7260, 9800, 6520]

    # Generate random numbers
    params = random.sample(xrange(16000, 2501296), 1000000)

    print "Single Thread Python (recursion) {}".format(vals)
    print(single_rec(recursive, vals))
    cProfile.run('single_rec(recursive, vals)')

    print "Single Thread Cython (recursion) {}".format(vals)
    print(single_rec(recursive_cy, vals))
    cProfile.run('single_rec(recursive_cy, vals)')

    print "Single Thread Python (recursion) {}".format(expanded)
    print(single_rec(recursive, expanded))
    cProfile.run('single_rec(recursive, expanded)')

    print "Single Thread Cython (recursion) {}".format(expanded)
    print(single_rec(recursive_cy, expanded))
    cProfile.run('single_rec(recursive_cy, expanded)')

    print "Single Thread Python map (recursion)"
    print(single_rec_map(recursive, params)[0:6], "...")
    cProfile.run('single_rec_map(recursive, params)[0:6]')

    print "Single Thread Cython map (recursion)"
    print(single_rec_map(recursive_cy, params)[0:6], "...")
    cProfile.run('single_rec_map(recursive_cy, params)[0:6]')
