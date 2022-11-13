import numpy as np

def fun_taus(N,pts):
    pts = 1000
    max_m = 2**np.floor(np.log2(N/2))
    m = np.logspace(0, np.log10(max_m), pts)
    m = np.floor(m)
    m = np.unique(m)

    return m
