# Script to import sensor data and calculate the Allan varianc
using DelimitedFiles
using PyPlot
using AllanDeviations
include("fun_avar.jl")
include("fun_tau_array.jl")

@time begin
# Importing file
sensor  = "gyroscope";
file    = "example_data.txt";
fs      = 100.0;   # [Hz]
println("Chosen file: ",file)

path = pwd()*"\\examples\\";
data = readdlm("$path$file", '\n');

# Creating time vector
N = length(data);
t = LinRange(0, (N-1)/fs, N);
end

# Plot big dataset is not working in julia
# plot(t/60/60, data,
#     xlabel = "Time [h]",
#     ylabel = sensor)

# Calculating correlation time array
m = fun_tau_array(N, 1000);

# Homemade Allan variance function
@time begin
(taus, avar) = fun_avar(data[:,1], fs, m);
end

adev = sqrt.(avar);

# Allan deviation from library
@time begin
result = allandev(data[:,1], fs,
            frequency = true, 
            taus = m/fs) # log 1.001 space among taus

PyPlot.plot(result.tau, result.deviation)
PyPlot.xscale("log")
PyPlot.yscale("log")
end

PyPlot.figure()
PyPlot.plot(taus, avar)
PyPlot.plot(title,"Allanvariance")
PyPlot.title("Allan variance")
PyPlot.xscale("log")
PyPlot.yscale("log")
PyPlot.xlabel("Correlation time [s]")
PyPlot.ylabel("Ω [deg²/h²]")

PyPlot.figure()
PyPlot.plot(taus, sqrt.(avar))
PyPlot.plot(title,"Allanvariance")
PyPlot.title("Allan variance")
PyPlot.xscale("log")
PyPlot.yscale("log")
PyPlot.xlabel("Correlation time [s]")
PyPlot.ylabel("Ω [deg/h]")
