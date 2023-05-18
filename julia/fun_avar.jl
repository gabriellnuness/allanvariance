function fun_avar(Ω, fs, m)
# Homemade function to calculate the Allan variance.
# It is 30 times longer than the function in AllanDeviations 

    if length(Ω)<3
        error("Allan variance needs at least 3 data points")
    end
    
    θ = cumsum(Ω)/fs;
    N = length(Ω)

    tau0 = 1/fs;
    taus = m*tau0;      # Cluster durations

    avar = zeros(length(m),1);
    # Homemade Allan variance calculation
    for (k, τ) in enumerate(m)
        avar[k] = sum( (θ[k+2*τ:N]
                        - 2*θ[k+τ:N-τ]
                        + θ[k:N-2*τ]).^2);
        avar[k] = avar[k]/(2* (τ/fs)^2 * (N-2*τ));
    end
        
    (taus, avar)
end