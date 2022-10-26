% Script used to generate a simulated signal of gyroscopes and calculate
% the Allan variance.
%
% Author: stnk
%
% https://www.sige.ita.br/edicoes-anteriores/2022/st/226646_1.pdf

clear; close all; clc;

time = 10*60*60;    % seconds
fs = 100;           % sampling frequency (Hz)
fc = 100;            % sensor bandwidth

% input values
w_ie_down = -sind(-23.251476)*15.0411;    % earth's rotation in deg/h
% Noises values from gyroscope
arw_in = 5.4e-4;                 % deg/rt-h
bias_in = 1.7e-3;                % deg/h
rrw_in = 2e-7;                   % guessed value

% Treating data for simulations input - all variables in deg/s
arw_in = arw2si(arw_in);         % deg/s/rt-Hz
arw_std = arw_in*sqrt(fc);       % deg/s

bias_in = bias_in/3600;          % deg/s

w_ie_down = w_ie_down/3600;      % deg/s

t = 0:1/fs:time;
N = length(t);

%% Jerath's model
% Model from the paper titled "Bridging the gap between sensor noise 
% modeling and sensor characterization", Jerath, et al. (2017).
% doi: 10.1016/j.measurement.2017.09.012

fprintf('Running 1st Model...\n')
omega1 = jerath2017_noise(w_ie_down,bias_in,arw_in,rrw_in, ...
        fs,time);

figure
plot(t/60/60, omega1*3600,'color',[.3 .3 .3])

% Allan variance by Jerath's model
% it retrieves the coefficient by a weighted fit.
fprintf('Calculating Allan variance for the 1st Model...\n')
[avar1, taus1, arw1, bias1, rrw1] = jerath2017_allan(omega1,fs);
adev1 = sqrt(avar1);

%% Matlab imuSensor function model
fprintf('Running 2nd model...\n'); 
gyro = gyroparams( ...
        'NoiseDensity', arw_in, ...
        'BiasInstability', bias_in, ...
        'RandomWalk', rrw_in); 
acc = zeros(N, 3);
input_imusensor = w_ie_down + zeros(N, 3);
omegaSim = zeros(N,1);
imu = imuSensor('SampleRate', fs, 'Gyroscope', gyro);
[~, gyroDataSim] = imu(acc, input_imusensor);
omega2 = gyroDataSim(:,1);

figure
plot(t/60/60, omega2*3600,'color',[.3 .3 .3])

% Allan variation of 2nd model
fprintf('Calculating Allan variance for the 2nd Model...\n')
[avar2, taus2, arw2, bias2, rrw2] = jerath2017_allan(omega2,fs);
adev2 = sqrt(avar2);

%% Simple model in Simulink
fprintf('Running 3rd model...\n'); 

out = sim('model_gyro_sim.slx');
% out = sim('model_ifog_sim.slx');
omega3 = out.ifog.data;

figure
plot(t/60/60, omega3*3600,'color',[.3 .3 .3])

% Allan variation of 3rd model
fprintf('Calculating Allan variance for the 3rd Model...\n')

[avar3, taus3, arw3, bias3, rrw3] = jerath2017_allan(omega3,fs);
adev3 = sqrt(avar3);

%% 
fprintf('\nRecovered error values with weighted fitting:')

fprintf('\nARW 1 = %.2s\nARW 2 = %.2s\nARW 3 = %.2s\n\n', ...
    [arw1 arw2 arw3]*60)
fprintf('Bias 1 = %.2s\nBias 2 = %.2s\nBias 3 = %.2s\n\n', ...
    [bias1 bias2 bias3]*3600)
fprintf('RRW 1 = %.2s\nRRW 2 = %.2s\nRRW 3 = %.2s\n\n', ...
    [rrw1 rrw2 rrw3]*60^3)

%% Allan variance without weighted fitting

fprintf('Calculating Allan variance for all models...\n')
% Creating vector of taus
pts = 1000;
max_m = 2^floor(log2(N/2));     % Max m in power of 2
m = logspace(0, log10(max_m), pts)';
m = ceil(m);        
m = unique(m);

[avar_2_1, taus_2_1] = allanvar(omega1, m, fs); % matlab function
adev_2_1 = sqrt(avar_2_1);
[arw_2_1, bias_2_1,rrw_2_1] = allan_fittings(taus_2_1, adev_2_1); 

[avar_2_2, taus_2_2] = allanvar(omega2, m, fs); % matlab function
adev_2_2 = sqrt(avar_2_2);
[arw_2_2, bias_2_2,rrw_2_2] = allan_fittings(taus_2_2, adev_2_2); 

[avar_2_3, taus_2_3] = allanvar(omega3, m, fs); % matlab function
adev_2_3 = sqrt(avar_2_3);
[arw_2_3, bias_2_3,rrw_2_3] = allan_fittings(taus_2_3, adev_2_3); 

%%
figure; hold on
plot(taus_2_1,adev_2_1*3600,'--','color',[.3 .3 .3])
plot(taus_2_2,adev_2_2*3600,'-.','color',[.3 .3 .3])
plot(taus_2_3,adev_2_3*3600,'-', ...
    'color',[41/255 128/255 185/255])
    set(gca,'YScale','log','XScale','log')
    ylim([1e-3 1e0])
    legend('Model 1','Model 2', 'Model 3')
    xlabel('\tau [s]')
    ylabel('Allan deviation [deg/h]')
    grid on
% standard_plot(gcf);
% print(gcf,'Allan_models','-dpdf','-r600')
%%
fprintf('\nRecovered error values with simple fitting:')
fprintf('\nARW 1 = %.2s\nARW 2 = %.2s\nARW 3 = %.2s\n\n', ...
    [arw_2_1 arw_2_2 arw_2_3]*60)
fprintf('Bias 1 = %.2s\nBias 2 = %.2s\nBias 3 = %.2s\n\n', ...
    [bias_2_1 bias_2_2 bias_2_3]*3600)
fprintf('RRW 1 = %.2s\nRRW 2 = %.2s\nRRW 3 = %.2s\n\n', ...
    [rrw_2_1 rrw_2_2 rrw_2_3]*60^3)

%% Calculating errors
% Errors for simple fit
error1 = [(arw_2_1 - arw_in)/arw_in
             (bias_2_1 - bias_in)/bias_in
             (rrw_2_1 - rrw_in)/rrw_in]*100;
error2 = [(arw_2_2 - arw_in)/arw_in
             (bias_2_2 - bias_in)/bias_in
             (rrw_2_2 - rrw_in)/rrw_in]*100;
error3 = [(arw_2_3 - arw_in)/arw_in
             (bias_2_3 - bias_in)/bias_in
             (rrw_2_3 - rrw_in)/rrw_in]*100;

% Errors for weighted fit
error1_w = [(arw1 - arw_in)/arw_in
             (bias1 - bias_in)/bias_in
             (rrw1 - rrw_in)/rrw_in]*100;
error2_w = [(arw2 - arw_in)/arw_in
             (bias2 - bias_in)/bias_in
             (rrw2 - rrw_in)/rrw_in]*100;
error3_w = [(arw3 - arw_in)/arw_in
             (bias3 - bias_in)/bias_in
             (rrw3 - rrw_in)/rrw_in]*100;

fprintf('\nErrors using weighted fit:\n')
fprintf('\nErrors from 1st model:\n')
fprintf(['ARW error = %.2f %%\n' ...
    'BIAS error = %.2f %%\n' ...
    'RRW error = %.2f %%\n'], ...
    error1_w)

fprintf('\nErrors from 2nd model:\n')
fprintf(['ARW error = %.2f %%\n' ...
    'BIAS error = %.2f %%\n' ...
    'RRW error = %.2f %%\n'], ...
    error2_w)

fprintf('\nErrors from 3rd model:\n')
fprintf(['ARW error = %.2f %%\n' ...
    'BIAS error = %.2f %%\n' ...
    'RRW error = %.2f %%\n'], ...
    error3_w)

fprintf('\nErrors using simple fit:\n')
fprintf('\nErrors from 1st model:\n')
fprintf(['ARW error = %.2f %%\n' ...
    'BIAS error = %.2f %%\n' ...
    'RRW error = %.2f %%\n'], ...
    error1)

fprintf('\nErrors from 2nd model:\n')
fprintf(['ARW error = %.2f %%\n' ...
    'BIAS error = %.2f %%\n' ...
    'RRW error = %.2f %%\n'], ...
    error2)

fprintf('\nErrors from 3rd model:\n')
fprintf(['ARW error = %.2f %%\n' ...
    'BIAS error = %.2f %%\n' ...
    'RRW error = %.2f %%\n'], ...
    error3)

%% Exporting figures to paper
for i = 1:2:5
    f = figure(i);
    
    xlabel('Time [h]')
    ylabel('Ang. velocity [deg/h]')
    ylim([4 8])

    set(f,'Units', 'Centimeters', 'Position' , [1 1 8 4]);
    set(f, 'PaperUnits', 'centimeters')
    set(gca, 'FontSize', 7)
    set(f, 'PaperSize', [8 4]);
    title('')
end

standard_plot(figure(7))

% print(figure(1),'results/jerath_time','-dpdf')
% print(figure(3),'results/imusensor_time','-dpdf')
% print(figure(5),'results/simulink_time','-dpdf')
% print(figure(7),'results/Allan_models','-dpdf')