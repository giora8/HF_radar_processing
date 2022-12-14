%% get_station_angle_radi.m
function [R, ANG] = get_station_angle_radi(station_location, target_location)
%% Inputs
% station_location - (long, lat) of HF radar station
% target_location - (long, lat) of desired location within HF radar coverage area
%% Output
% ANG - closest angle measurement in units of STATION angles (resolution of 1 degree)
% R - length in [km] between HF radar station to desired location
%
%-------------------------------------------------------------------------%

    AZ0 = 300;  % azimuth of 0 degree angle of the radar
    [arclen, az_shallow] = distance(station_location(2), station_location(1), target_location(2), target_location(1));
    ANG = round(az_shallow - AZ0);
    R = deg2km(arclen);

end

