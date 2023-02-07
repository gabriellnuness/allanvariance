% Matlab runtests uses sections with %% as 
% separate variable environments for the tests
% the first section can have shared variables

addpath('..\matlab')
clear; close all; clc

% fixed values
known_input = [3,1,0,-4,5,2]';
known_output = [11.1, 7.7083, 0.0556];

% random values
rand_input = 10*randn(1,1e4)';


%% Comparing hand-calculated results
m = [1,2]'; % [1,n]
output = fun_avar(known_input,m,1);
matlab_output = allanvar(known_input,m);

assert(abs(known_output(1) - matlab_output(1)) < 3);
assert(abs(known_output(2) - output(2)) < 0.2);



%% Comparing random input
m = 1:length(rand_input)/2;
m = m';

output = fun_avar(rand_input,m,1);
matlab_output = allanvar(rand_input,m);

percent_error = abs(output - matlab_output) ./ matlab_output *100;
assert(percent_error(1) <= 1)
assert(max(percent_error(1:end-40)) <= 10)


%% finish test
fprintf('Test completed successfully!\n')