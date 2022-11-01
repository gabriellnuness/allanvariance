function [avar, taus] = fun_avar(data, m, fs)
% [avar, taus] = fun_avar(data, m, fs) returns the Allan
% variance and the correlation time array taus.
%
% when compared to the MATLAB allanvar function there is a difference in
% running time, this is 6.5 longer and the error is negligible 
% 
% Author: stnk
    
    % Correlation time array
    taus = m/fs;
    % Half vectorized approach of equation from
    % IEEE 952-2020, p. 75
    N = length(data);
    data_sum = cumsum(data)/fs;
    avar = zeros(length(m), 1);
    for k = 1:length(m)
        avar(k) = sum((data_sum(k+2*m(k):N) ...
                        - 2*data_sum(k+m(k):N-m(k)) ...
                        + data_sum(k:N-2*m(k))).^2 );
    end
    avar = avar./(2.*taus.^2 .* (N-2*m));

end