function x = jerath2017model( ...
    input_signal, input_bias, input_arw, input_rrw,fs, time)

% -------------------------------------------------------------------------
% Angle Random Walk (ARW) noise
% -------------------------------------------------------------------------
N_ARW = input_arw;%0.025;    % units of deg/rt-sec for angular rate noise

% -------------------------------------------------------------------------
% Flicker Noise / Bias Instability (FN)
% -------------------------------------------------------------------------
B = input_bias;
% bias_mult = 5.4772;
% N_FN = B/bias_mult; %0.005;
% PSD_FN = N_FN^2;      % PSD of white noise (unit^2/Hz)
% sigma_FN = sqrt(PSD_FN*fs);
alpha = 1;      % for 1/f^(alpha) noise

% -------------------------------------------------------------------------
% Rate Random Walk noise  (RRW)
% -------------------------------------------------------------------------
K = input_rrw; % (units/sec)/rt-sec for angular acceleration noise

%% Simulation of Angle Random Walk Noise
PSD_ARW = N_ARW^2;                      % units of deg^2/sec

% Standard deviation of sampled white noise for angular rate
sigma_ARW = sqrt(PSD_ARW*fs);           
x_ARW = sigma_ARW.*randn(time*fs+1,1);  % White noise in angular rate
ARW = x_ARW;

%% Simulation of Flicker Noise/Bias Instability
% Define IIR filter truncation limits
numTerms = 500;
w_FN = randn(time*fs + 1,1);                % white noise ~ N(0,1)

% Re-initialize to seros in every run
x_FN = zeros(length(numTerms),time*fs+1);   

% Set up the IIR filter coefficients
a(1,1) = 1;
for(i=1:1:numTerms)
    a(1,i+1) = (i-1-alpha/2)*(a(1,i))/i;
end
x_FN(1:numTerms) = 0;
wNew = B.*w_FN;

% Generate the flicker noise
for(count = (numTerms+1):1:time*fs)
    x_FN(count+1) = -a(1,2:end)*(fliplr(x_FN(count-numTerms:count-1)))' ...
                                                            + wNew(count);
end

omega_FN = circshift(x_FN,[0 -numTerms]);

FN = omega_FN';

%% Simulation of Rate Random Walk Noise
PSD_RRW = K^2;                   % units of (units/sec)^2/sec
% Standard deviation of sampled white noise for angular acceleration
sigma_RRW = sqrt(PSD_RRW*fs);               
% White noise in angular rate (units/sec^2)
acc_RRW = sigma_RRW.*randn(time*fs+1,1);    
% Angle Random Walk Noise in rate (units/sec)
omega_RRW = (1/fs).*cumsum(acc_RRW);        

RRW = omega_RRW;

%% Noise signal in sensor measurements
x = input_signal + ARW + FN + RRW;

end