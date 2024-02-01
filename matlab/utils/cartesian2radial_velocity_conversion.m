function [Vr, Vtheta] = cartesian2radial_velocity_conversion(u, v, az)
%% Inputs
% u - eastwards velocity component
% v - northwards velocity component
% az - azimuth of the radial direction (positive)
%% Output
% Vr - radial velocity (positive point towards the azimuth direction)
% Vtheta - tangential velocity
%
ang = deg2rad(360-az);
Vr = -u .* sin(ang) + v .* cos(ang);
Vtheta = u .* cos(ang) + v .* sin(ang);
end

