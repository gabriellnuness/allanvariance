using AllanDeviations
include("fun_avar.jl")

input = Float64[3;1;0;-4;5;2];
m = [1;2];
fs = 1.0;

# Homemade Allan variance function
(taus, avar) = fun_avar(input, fs, m)

# Allan deviation from library
# (tau, deviation, error, count) = allandev(arr, r)
(taus1,adev1) = allandev(input, fs, frequency=true, taus=length(m)) 


dif = avar .- adev1.^2