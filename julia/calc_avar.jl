# Script to import sensor data and calculate the Allan varianc
using DelimitedFiles
using Plots
using AllanDeviations

@time begin
# Importing file
sensor  = "gyroscope";
file    = "example_data.txt";
fs      = 100;   # [Hz]
println("Chosen file: ",file)

path = pwd()*"\\";
data = readdlm("$path$file", '\n');

# Creating correlation time array
N = length(data);
t = LinRange(0, (N-1)/fs, N);
end

# Plot big dataset is not working in julia
# plot(t/60/60, data,
#     xlabel = "Time [h]",
#     ylabel = sensor)

# Calculating correlation time array
pts = 1000;
max_m = 2^floor(log2(N/2)) 
m = 10 .^(range(0, stop=log10(max_m), length=pts));
m = floor.(Int, m);     
m = unique(m);

@time begin
# Calculating Allan variance
Ω = data[:,1];
θ = cumsum(Ω)/fs;

tau0 = 1/fs;
taus = m*tau0;      # Cluster durations

avar = Float64[];
# Homemade Allan variance calculation
for k = 1:length(m)
    avar = [avar; sum( (θ[k+2*m[k]:N]
                        - 2*θ[k+m[k]:N-m[k]]
                        + θ[k:N-2*m[k]]).^2) ];
end
avar = avar./(2 .* taus.^2 .* (N.-2*m));

end

# Allan deviation from library
@time begin

result = allandev(Ω, 100.0, frequency = true, 
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