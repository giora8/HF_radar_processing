function projected_map = adcp_projection(config, input_map)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

projected_map = input_map;
u = input_map('u');
v = input_map('v');
HF_station_to_run = config.ADCP.HF_station;
HF_station_radial_azimuth = config.sys_config.(HF_station_to_run).boresight_angle_azimuth;

Vr = -u .* sin(deg2rad(360-HF_station_radial_azimuth)) + v .* cos(deg2rad(360-HF_station_radial_azimuth));
Vtheta = u .* sin(deg2rad(360-HF_station_radial_azimuth)) + v .* cos(deg2rad(360-HF_station_radial_azimuth));

projected_map('Vr') = Vr;
projected_map('Vtheta') = Vtheta;

end