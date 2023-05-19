# Script to import sensor data and calculate the Allan varianc

# macro to start running script from its original folder
cd(@__DIR__)

using DelimitedFiles
using Printf
import PyPlot as plt
using LinearAlgebra
using AllanDeviations

include("..\\julia\\fun_avar.jl")
include("..\\julia\\fun_tau_array.jl")
include("..\\julia\\fit_allanvar.jl")


# Importing file
sensor  = "gyroscope";
file    = "\\example_data.txt";
fs      = 100.0;   # [Hz]
println("Chosen file: ",file)

path = pwd()
data = readdlm("$path$file", '\n');

# Creating time vector
N = length(data);
t = LinRange(0, (N-1)/fs, N);

# Using PyPlot because Julia Plots.jl is slow for a big dataset
plt.figure()
plt.plot(t/60/60, data)
plt.xlabel("Time [h]")
plt.ylabel("sensor")

# Calculating correlation time array
m = fun_tau_array(N, 1000);

# Homemade Allan variance function
@time begin
    (taus, avar) = fun_avar(data[:,1], fs, m);
end
adev = sqrt.(avar);

# Allan deviation from library
@time begin
    result = allandev(data[:,1], fs, frequency=true, taus=1.05) 
        # space among taus of log(1.05)
        # or make taus=m/fs
end

# Perform fitting of noise values
(adev_fit, Q, arw, bias, rrw, rr) = fit_allanvar(taus[:,1], avar[:,1])


# Plot Allan variance
plt.figure()
plt.plot(result.tau, result.deviation,"o", linewidth=6, alpha=.3, label="library")
plt.plot(taus, adev, "o", markersize=1, label="homemade")
plt.title("Allan variance")
plt.xlabel("Correlation time [s]")
plt.ylabel("Ω [deg/h]")
plt.xscale("log")
plt.yscale("log")
plt.legend()


plt.figure()
plt.plot(taus, adev,)
plt.plot(taus, adev_fit)
plt.title("Noise values fitting example")
plt.xscale("log")
plt.yscale("log")
noises_string = @sprintf "Q = %.2e\narw = %.2e\ndrift = %.2e\nrrw = %.2e\nrr = %.2e" Q arw bias rrw rr
plt.legend(["data",noises_string])
