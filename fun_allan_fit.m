function [arw, bias, rrw, iN, iB, iK] = fun_allan_fit(taus, adev)
% Fittings ARW, RRW, and Bias drift from Allan deviation plot
% function from MATLAB website

    x = log10(taus);
    y = log10(adev);
    dy = diff(y)./diff(x);

    % Angle random walk
    slope = -1/2; 
    % tau can be 1s or 1h
    % check reference for the posterior calculations
    tau = 1; 

% EXPLAIN THIS PART!
    % what if there are oscilations?
    % finding the minimum local error slope
    [~, iN] = min(abs(dy-slope));
    % Fitting a line with slope -1/2 
    % at the point with minimum error from the slope  
    b = y(iN) - slope*x(iN);
    % finding the value of the line at tau=1
    logN = slope*log(tau) + b;
    arw = 10^logN; % value at tau=1

    % Bias drift
    slope = 0;
    [~, iB] = min(abs(dy-slope));
    b = y(iB) - slope*x(iB);
    scfB = sqrt(2*log(2)/pi);  % 0.6643
    logB = b - log10(scfB);
    bias = 10^logB;
    % If it does not work, try the minimum value instead.    
    % bias = min(adev)/scfB;

    % Rate Random Walk
    slope = 1/2; 
    tau = 3; % or at 3h
    [~, iK] = min(abs(dy-slope));
    b = y(iK) - slope*x(iK);
    logK = slope*log10(tau) + b;
    rrw = 10^logK;

end