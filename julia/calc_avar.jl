# Script to import sensor data and calculate the Allan varianc
using DelimitedFiles
using Plots
using AllanDeviations

# include("fun_tau_array.jl")
# include("fun_avar.jl")

# Importing file
sensor  = "gyroscope"
file    = "example_data.txt"
fs      = 100   # [Hz]
println("Chosen file: ",file)

path = pwd()*"\\"
data = readdlm("$path$file", '\n')

# Creating correlation time array
N = length(data)
t = LinRange(0, (N-1)/fs, N)

# plot(t/60/60, data,
    # xlabel = "Time [h]",
    # ylabel = sensor)

# Calculating correlation time array
pts = 1000
optm = "optimized" 

max_m = 2^floor(log2(N/2)) 
if optm == "all" 
    m = 2:max_m;
elseif optm == "optimized" 
    m = 10 .^(range(0, stop=log10(max_m), length=pts));
end
m = floor.(m);        
m = unique(m);

# Calculating Allan variance
Ω = data;
θ = cumsum(Ω[:,1])/fs;
    
tau0 = 1/fs;
taus = m*tau0;      # Cluster durations

avar = Float64[];
# Half vectorized approach
for k = 1:length(m)
    avar(k) = sum( (θ(k+2*m(k):N)
                        - 2*θ(k+m(k):N-m(k))
                        + θ(k:N-2*m(k))).^2 );
end
avar = avar./(2 .* taus.^2 .* (N-2*m));


plot(taus,avar)