cd('..\matlab')
clc

input = [3,1,0,-4,5,2]';
m = [1,2]';
output = [11.1, 7.7083, 0.0556];
matlab_output = allanvar(input,m);
act_output = fun_avar(input,m,1);

% compare results
%
% @warning Matlab has a function runtests(), learn how to use it.
%
assert(abs(output(1)-matlab_output(1)) < 3);
assert(abs(output(2)-act_output(2)) <0.2);

% finish test
fprintf('Test executed!\n')
cd('..\test')

%% Recommended way for matlab testing
% classdef test < matlab.unittest.TestCase
%     methods(Test)
%         function overlap(testCase)
%             actSolution = allanvar([3,1,0,-4,5,2]);
%             expSolution = [11.1, 7.7083, 0.0556];
%             testCase.verifyEqual(actSolution,expSolution)
%         end
%         % function nonoverlap(testCase)
%         %     actSolution = allanvar([3,1,0,-4,5,2]);
%         %     expSolution = [11.1,  11.5625];
%         %     testCase.verifyEqual(actSolution,expSolution)
%         % end
%     end
% end