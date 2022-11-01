function [adevFit, Q, arw, bias, rrw, rr] = fun_allan_fit_msq(taus, adev)
% Calculate the sensor noise parameters/coefficients from the 
% Allan Variance data using Weighted Linear Regression

    % adev and taus must be row arrays to perform matrix calc
    if ~isrow(taus)
        taus = taus';
    end
    if ~isrow(adev)
        adev = adev';
    end
    avar = adev.^2;
    
    %% Weighted Least-Squares Fitting
    
    % The weight is approximately to the order of magnitude
    weight = 1./avar;
    W = diag(weight);
    
    T = [taus.^(-2);
         taus.^(-1);
         taus.^(0);
         taus.^(1);
         taus.^(2)];

    avarFit = (T*W*T')\T*W*avar';

    %% Fitted Allan deviation noise values
    % This values result in complex numbers
    % C = avarFit
    % unit = measurement unit in SI
    %
    % Q     -->
    % arw   --> unit / (s^(1/2))
    % bias  --> unit / s
    % rrw   --> unit / (s^(3/2))
    % rr    --> 
    %

    % C = 3*Q^2
    % Q^2 = (q^2)/12, where q = quantum step size
    Q    = (avarFit(1)/3)^(0.5);
    % C = N^2
    arw  = avarFit(2)^(0.5);
    % C = (0.6643*B)^2
    bias = (avarFit(3)^(0.5) ) / sqrt(2*log(2)/pi);
    % C = K^2 /3
    rrw  = (3*avarFit(4))^(0.5);
    % C = R^2 / 2
    rr   = (2*avarFit(5))^(0.5);

    adevFit = sqrt(avarFit'*T);
    adevFit = adevFit';

end