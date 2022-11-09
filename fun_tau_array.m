function m = fun_tau_array(N, pts, optm)
%% Function to generate time array for Allan variance
% optm = "optimized"    --> logspace array
% optm = "all"          --> complete array
    
    % Most AVAR algorithms do not allow the last m value to be floor(N/2).
    % Apparently, the last m must be smaller than N/2 - length(m)
    max_m = 2^floor(log2(N/2));     % Max m in power of 2
    
    if optm == "all" 
        max_m = N/2 - 1;
        m = 2:max_m;
    elseif optm == "optimized" 
        m = logspace(0, log10(max_m), pts)';
    end
    m = floor(m);        
    m = unique(m);
    
end