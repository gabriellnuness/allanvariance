import numpy as np

def fun_fit_avar(taus, adev):

    avar = adev**2

    w = 1/avar
    W = np.diag(w)
    
    T = [taus**(-2),taus**(-1),taus**(0),taus**(1),taus**(2)]

    # weighted least squares
    # avarfit = (T*W*T')\T*W*avar';
    avarfit = np.dot(np.dot(T,W),np.transpose(T))
    avarfit = np.dot(np.dot(np.linalg.inv(avarfit),T),W)
    avarfit = np.dot(avarfit,np.transpose(avar))

    Q    = (avarfit[0]/3)**(0.5)
    # C = N**2
    arw  = avarfit[1]**(0.5)
    # C = (0.6643*B)**2
    bias = (avarfit[2]**(0.5)) / np.sqrt(2*np.log(2)/np.pi)
    # C = K**2 /3
    rrw  = (3*avarfit[3])**(0.5)
    # C = R**2 / 2
    rr   = (2*avarfit[4])**(0.5)

    adevfit = np.sqrt(np.dot(np.transpose(avarfit),T))
    adevfit = np.transpose(adevfit)

    return Q, arw, bias, rrw, rr, adevfit
