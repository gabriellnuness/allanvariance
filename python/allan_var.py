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
raw_data  = pd.read_csv(("..\\" + file), sep='\t' ,header=None, names=["Sensor data", "Temperature"])
# to use allantools the data needs to be numpy array    
data = raw_data["Sensor data"].to_numpy()

# Creating time vector
N = len(data)
t = np.linspace(0, (N-1)/fs, N) # time in seconds

plt.figure()
plt.plot(t/60/60, data,
    linewidth=.8)
plt.xlabel('Time [h]')
plt.ylabel('Sensor data [units]')

# Creating correlation time array (taus)
m = fun_taus(N, 1000)

# Calculating overlapping Allan variance
(taus, adev, ade, adn) = allantools.oadev(data, rate=fs, data_type="freq", taus=m/fs)

# Fitting Allan noise coefficients
(Q, arw, bias, rrw, rr, adevfit ) = fun_fit_avar(taus, adev)
print(Q,arw,bias,rrw,rr)

plt.figure()
plt.loglog(taus, adev,'.')
plt.plot(taus, adevfit)
plt.xlabel("Correlation time [s]")
plt.ylabel("Allan deviation [units]")
plt.grid(True, which="both", alpha=0.2)
plt.legend([f"ARW:{(arw*1e3):.2e} mdeg/sqrt(h)\nBIAS:{(bias*1e3):.2e} mdeg\nRRW:{(rrw*1e3):.2e} mdeg/h/sqrt(h)"])
plt.show()
