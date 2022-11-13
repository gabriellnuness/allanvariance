import numpy as np
import pandas as pd
import pylab as plt
import allantools

from fun_taus import *
from fun_fit_avar import *

# Importing data
file = "example_data.txt"
fs = 100 # Hz

# pandas read csv is super fast
data  = pd.read_csv(file, header=None, names=["Sensor data"])
# to use allantools the data needs to be numpy array    
data = data.to_numpy()

# Creating time vector
N = len(data)
t = np.linspace(0, (N-1)/fs, N) # time in seconds

fig = plt.plot(t/60/60, data,
    linewidth=.8)
plt.xlabel('Time [h]')
plt.ylabel('Sensor data [units]')
# plt.show()

# Creating correlation time array (taus)
m = fun_taus(N, 1000)

# Calculating overlapping Allan variance
(taus, adev, ade, adn) = allantools.oadev(data, rate=fs, data_type="freq", taus=m/fs)

fig = plt.loglog(taus, adev,'.')
plt.xlabel("Correlation time [s]")
plt.ylabel("Allan deviation [units]")
plt.grid(True)
# plt.show()

# Fitting Allan noise coefficients
(Q, arw, bias, rrw, rr, adevfit ) = fun_fit_avar(taus, adev)
print(Q,arw,bias,rrw,rr)

plt.loglog(taus, adev,'.')
plt.plot(taus, adevfit)
plt.xlabel("Correlation time [s]")
plt.ylabel("Allan deviation [units]")
plt.grid(True)
plt.show()
