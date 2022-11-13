function fun_tau_array(N, pts)
# Function to generate time array for Allan variance
    
# Calculating correlation time array
pts = 1000;
max_m = 2^floor(log2(N/2)) 
m = 10 .^(range(0, stop=log10(max_m), length=pts));
m = floor.(Int,m);     
m = unique(m);

(m)
end