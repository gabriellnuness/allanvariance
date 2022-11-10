%% Importing data
clear
clc
close all

% Data info
sensor  = 'gyroscope'; 
file    = 'gyro_test_data.txt';
fs      = 100;   % [Hz]
fprintf("Chosen file: %s\n", file)

% Choose start and end points
% make t1 = t2 = 0 if it is to use all the data set
t1 = 4.5;  % start measurement [h]
t2 = 15;  % stop  measurement [h]
first_point = 20; % Ignore start of Allan variance

% Setting relative path where the data is located
user = getenv('username');
addpath(['c:\users\',user,'\Downloads']);
addpath(['d:\users\',user,'\Downloads']);

% Importing data
tic
tmp = readmatrix(file);
fprintf("File successfully imported...\n")
toc

%% Data processing
 
% Constants
g =  9.80665; % m/s^2

% Data selection from real dataset
if t1 == 0 && t2 ==0 
    data = tmp(:,1);
else
    data = tmp(t1*fs*3600:t2*fs*3600, 1);
end
% Temperature data check
% some data have temperature info as well
if size(tmp,2) == 2  && t1 == 0 && t2 ==0 
    temp = tmp(:,2);
elseif size(tmp,2) == 2
    temp = tmp(t1*fs*3600:t2*fs*3600,2);
end

%%
N = length(data);
t = linspace(0, (N-1)/fs, N);

%% Allan variance calculation

% Create array for Allan variance correlation periods
m = fun_tau_array(N, 1000, "optimized");

fprintf('Total time span of signal: %.2f h\n', ...
    N/fs/60/60);
fprintf('Time span of signal used to calculate Allan variance: %.2f h\n', ...
    (2*m(end))/fs/60/60);

% Calculate Allan variance
%  
% It requires one of the following toolbox:
%   Sensor Fusion and Tracking Toolbox
%   Navigation Toolbox
tic
fprintf("Calculating MATLAB Allan variance ...\n")
[avar, taus] = allanvar(data, m, fs);
toc

% Homemade function
tic
fprintf("Calculating HOMEMADE Allan variance...\n")
[avar1, taus1] = fun_avar(data, m, fs);
toc

% Removing start
avar = avar(first_point:end);
taus = taus(first_point:end);
avar1 = avar1(first_point:end);
taus1 = taus1(first_point:end);

adev = sqrt(avar);
error = avar-avar1;

% Comparing Allan calculations
figure
plot(taus,avar)
hold on
plot(taus1,avar1,'--')
    title('Comparison Allan variance calculations')
    set(gca,'xscale','log','yscale','log')
yyaxis right
plot(taus, abs(error))
    title('Error Allan variance')
    ax = gca;
    ax.YAxis(1).Color = 'k';

%% Calculate Allan variance confidence limit
% I = 1./sqrt(2.*(N./m-1));
I = 1./sqrt(2.*(N./m(first_point:end)-1));

%% Calculate noises and respective indexes
% This part is not working correctly yet.
% Our Allan variance has a different format due to 
% the low-pass filter we apply to the signal
% [arw,bias,rrw,iN,iB,iK] = fun_allan_fit(taus, adev);
tic
fprintf("Fitting Allan variance\n")
[adevFit, Q, arw, bias, rrw, rr] = fun_allan_fit_msq(taus,adev);
toc

% plot Allan deviation fit
figure
hold on;
plot(taus, adevFit, ...
    'color', [0.9059 0.2980 0.2353 .8], ...
    'LineWidth',2);
plot(taus, adev, ...
    'Color',[.2 .2 .2]); 
    set(gca,'YScale','log','XScale','log')

%% Converting output units
switch sensor
    case 'gyroscope'
    % input must be in deg/h
        fprintf('inside gyro\n')
        % (deg/h)*s --> deg
        q_out   = Q/(60^2);
        q_unit  = "deg";
        % deg/h/rt-Hz --> deg/rt-h
        arw_out  = arw/60;
        arw_unit = "deg/sqrt(h)";
        % deg/h
        bias_out  = bias;
        bias_unit = "deg/h";
        % (deg/h)*s^(-1/2) --> deg/h/rt-h  
        rrw_out  = rrw*60;
        rrw_unit = "deg/h/sqrt(h)";
        % deg/h/s --> deg/h/h
        rr_out  = rr*(60^2);
        rr_unit = "deg/h/h";
    case 'accelerometer'
    % input must be in g
        fprintf('inside acc\n')
        % (m/s^2)*s
        q_out  = Q;
        q_unit = "g*s";
        % (m/s^2)*s^(1/2)
        arw_out  = arw;
        arw_unit = "g*sqrt(s)";
        % (m/s^2)*s^(0)    
        bias_out  = bias;
        bias_unit = "g";
        % (m/s^2)*s^(-1/2) 
        rrw_out  = rrw;
        rrw_unit = "g/sqrt(s)";
        % (m/s^2)*s^(-1)
        rr_out  = rr;
        rr_unit = "g/s";
end

%% Print out fitted values
fprintf('\n')
fprintf('Quantization noise = %.2s [%s]\n',  q_out, q_unit)
fprintf('Random walk noise = %.2s [%s]\n',   arw_out, arw_unit)
fprintf('Bias drift = %.2s [%s]\n',          bias_out, bias_unit)
fprintf('Rate walk noise = %.2s [%s]\n',     rrw_out, rrw_unit)
fprintf('Rate ramp noise = %.2s [%s]\n',     rr_out, rr_unit)


%% Figures
gray = [.3 .3 .3];
figure('Units','centimeters','Position',[1 1 10 20])
% Plot Signal
subplot(3,1,1)
    hold on
    plot(t/60/60, data, 'color', gray)
        xlabel('Time [h]')
        ylabel('Measurement')
    xline((2*m(end))/fs/60/60)
    
    % Plot temperature
    if exist('temp','var') == 1
        yyaxis right
        plot(t/60/60, temp)
            ylim([30 31])
            ax = gca;
            ax.YAxis(1).Color = 'k';
    end    
% Plot Allan variance
subplot(3,1,2)
    hold on
    plot(taus, adev,...
        'color',[.3 .3 .3],'LineWidth',1.5)
        set(gca,'YScale','log','XScale','log')
        xlabel('Correlation time [s]')
        ylabel('Allan deviation')
% Plot Allan variance with confidence limits
subplot(3,1,3)
    patch([taus; flip(taus)], ...
        [adev-adev.*I;  flip(adev+adev.*I)], ...
        gray,'LineStyle','none')
        set(gca,'YScale','log','XScale','log')
        alpha(0.2)
    hold on
    plot(taus, adev,...
        'color',gray,'LineWidth',1.2)
        set(gca,'YScale','log','XScale','log')
        xlabel('Correlation time [s]')
        ylabel('Allan deviation')

%% test ARW
figure(2)
plot(taus(taus==1),adev(taus==1),'*'); 
adev(taus==1)
taus(end)