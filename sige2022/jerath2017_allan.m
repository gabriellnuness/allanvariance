function [avar, taus, arw, bias, rrw] = jerath2017_allan(data, fs)
    % Determine 'reasonable' temporal correlation lengths 
    %         (or correlation time (tau))
    
    len = length(data);
    % Maximum possible correlation time based on data length
    ordermax = numel(num2str(fix(len/fs)))-2;             
    order = fix(log10(1/fs));
    tau1 = [2, 3, 4, 5, 6, 7, 8, 9];
    tau2 = [];
    
    while order < ordermax
        tau2 = [tau2, (10^order).*tau1];
        order = order + 0.5;
    end
    tau = sort(tau2);
    RootAllanVar = zeros(1,length(tau));
    
    % Calculate Allan Variance for each value of determined
    %          correlation time
    for count = 1:1:length(tau)
        % Determine number of measurements per correlation time 'block'
        t = round(tau(count)*fs);                         
        
        % Determine number of 'blocks' of data with given correlation time
        numDivisions = floor(len/t);                            
        Avg = zeros(1,numDivisions);
        Diff = zeros(1, numDivisions-1);
        
        % Calculate average value within each 'block' of data
        for index = 1:1:numDivisions
            Avg(index) = (sum(data(t*(index-1)+1:t*index)))/t;  
        end
        
        % Calculate the difference between successive averaged 'block' values
        for index = 1:1:numDivisions-1
            Diff(index) = Avg(index+1) - Avg(index);            
        end
        
         % Calculate Root Allan Variance
        RootAllanVar(count) = sqrt(0.5*mean(Diff.*Diff ));
    end
    
    % Calculate the sensor noise parameters/coefficients from the 
    %          Allan Variance data using Weighted Linear Regression
    % NOTE: Choice of regression model plays a critical part in determining 
    % noise model
    
    AllanVar = RootAllanVar.^2;
    weight = 1./AllanVar;  % Needed for performing weighted least squares
    
    TAU = [tau.^(-1);tau.^(0);tau.^(1)]; % arw, bias, rrw
       
    AVARwt = diag(weight)*AllanVar';
    invTAU = (inv(TAU*diag(weight)*TAU'))*TAU;
    
    AWLS = invTAU*AVARwt;
    
    arw = AWLS(1)^(1/2);
    bias = abs(AWLS(2)^(1/2));
    rrw = AWLS(3)^(1/2);
    avar = AllanVar;
    taus = tau;
    AVARfit = sqrt(AWLS'*TAU);
    
    figure
    hold on;
    plot(tau, AVARfit,'color', [0.9059 0.2980 0.2353]);
    plot(taus, sqrt(avar),'k'); 
        set(gca,'YScale','log','XScale','log')
end