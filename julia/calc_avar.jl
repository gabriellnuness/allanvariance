# Script to import sensor data and calculate the Allan varianc
using DelimitedFiles
using Plots
using AllanDeviations
include("fun_avar.jl")
include("fun_tau_array.jl")

@time begin
# Importing file
sensor  = "gyroscope";
file    = "example_data.txt";
fs      = 100;   # [Hz]
println("Chosen file: ",file)

path = pwd()*"\\";
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

scatter(taus, adev,
xscale = :log10, yscale = :log10)

# Allan deviation from library
@time begin
result = allandev(data[:,1], 100.0,
            frequency = true, 
            taus = 1.05) # log 1.001 space among taus

scatter(result.tau, result.deviation,
    xscale = :log10, yscale = :log10)
end

plot(taus, avar,
    title="Allan variance",
    xaxis=:log, yaxis=:log,
    xlabel="Correlation time [s]",ylabel="Ω [deg/h]",
    linewidth=2,legend=false)

plot(taus, sqrt.(avar),
    title="Allan deviation",
    xaxis=:log, yaxis=:log,
    xlabel="Correlation time [s]",ylabel="Ω [deg/h]",
    linewidth=2,legend=false)