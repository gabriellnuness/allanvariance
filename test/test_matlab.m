cd('..\matlab')
clc

input = [3,1,0,-4,5,2]';
m = [1,2,3]';
output = [11.1, 7.7083, 0.0556];
matlab_output = allanvar(input,m)
act_output = fun_avar(input,m,1)
tolerance = 0.001;

for i = 1:3
    
    assert(abs(output(i)-matlab_output(i)) < tolerance)
    assert(abs(output(i)-act_output(i)) < tolerance)
   
end


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