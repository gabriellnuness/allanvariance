% function [q, arw, bias, rrw, rr] = fun_allan_fit_msqr(taus, adev)
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
    weight = 1./avar;  % Needed for performing weighted least squares
    
    % [Q; ARW; BIAS; RRW; RR]
    TAUS = [taus.^(-2);taus.^(-1);taus.^(0);taus.^(1);taus.^(2)];

    AVARwt = diag(weight)*avar';
    invTAUS = (inv(TAUS*diag(weight)*TAUS'))*TAUS;
    
    % Fitted Allan Variance noise values 
    avarFit = invTAUS*AVARwt;

    % Fitted Allan deviation noise values
    % This values result in complex numbers
    q       = avarFit(1)^(0.5);
    arw     = avarFit(2)^(0.5);
    bias    = avarFit(3)^(0.5);
    rrw     = avarFit(4)^(0.5);
    rr      = avarFit(5)^(0.5);

    adevFit = sqrt(avarFit'*TAUS);
    
    figure
    hold on;
    plot(taus, adevFit, ...
        'color', [0.9059 0.2980 0.2353 .8], ...
        'LineWidth',2);
    plot(taus, adev, ...
        'Color',[.2 .2 .2]); 
        set(gca,'YScale','log','XScale','log')
% end