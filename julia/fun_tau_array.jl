function fun_tau_array(N, pts)
    # Function to generate time array for Allan variance
    # Input: 
        # N     → length of input array
        # pts   → number of correlation points 
    # Output:
        # m     → array of Allan variance correlation time

    # Check input size
    if pts > N/2
        error("Number of points must be less or equal N/2")
    end

    # Calculating correlation time array
    max_m = 2^floor(log2(N/2)); 
    m = 10 .^(range(0, stop=log10(max_m), length=pts));
    m = floor.(Int,m);     
    m = unique(m);

    (m)
end