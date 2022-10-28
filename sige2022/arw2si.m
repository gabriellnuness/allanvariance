function [arw_si] = arw2si(arw)
% Function to convert angle random walk value
% from deg/sqrt(h) to deg/s/sqrt(Hz)
%
% Input: angle random walk [deg/sqrt(h)]
%
% Output: angle random walk [rad/s/sqrt(Hz)]
%
% Gabriel Nunes / 2022.06.22


    arw_si = arw*60;            % [deg/h/sqrt(Hz)]
    arw_si = arw_si/3600;       % [deg/s/sqrt(Hz)]

end





