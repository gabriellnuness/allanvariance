# Script to import sensor data and calculate the Allan varianc

# macro to start running script from its original folder
cd(@__DIR__)

using DelimitedFiles
import PyPlot as plt
using AllanDeviations
include("fun_avar.jl")
include("fun_tau_array.jl")

@time begin
# Importing file
sensor  = "gyroscope";
file    = "\\example_data.txt";
fs      = 100.0;   # [Hz]
println("Chosen file: ",file)

path = "..\\examples\\";
data = readdlm("$path$file", '\n');

# Creating time vector
N = length(data);
t = LinRange(0, (N-1)/fs, N);
end

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
result = allandev(data[:,1], fs, frequency=true, taus=1.05) # log 1.001 space among taus
end

plt.figure()
plt.plot(result.tau, result.deviation,"o", linewidth=6, alpha=.3, label="library")
plt.plot(taus, sqrt.(avar), "o", markersize=1, label="homemade")
plt.title("Allan variance")
plt.xlabel("Correlation time [s]")
plt.ylabel("Ω [deg/h]")
plt.xscale("log")
plt.yscale("log")
plt.legend()