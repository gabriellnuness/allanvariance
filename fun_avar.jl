function [taus, avar] = calc_avar(Ω,fs,m)
   
    N = length(Ω);
    θ = cumsum(Ω)/fs;
    
    tau0 = 1/fs;
    taus = m*tau0;      # Cluster durations
    
    avar = zeros(length(m), 1);
    # Half vectorized approach
    tic
    for k = 1:length(m)
        avar(k) = sum( (θ(k+2*m(k):N)
                    - 2*θ(k+m(k):N-m(k))
                    + θ(k:N-2*m(k))).^2 );
    end
    avar = avar./(2 .* taus.^2 .* (N-2*m));
    toc
end