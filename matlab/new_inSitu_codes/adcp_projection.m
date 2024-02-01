function projected_map = adcp_projection(config, input_map)
%% Inputs
% config - system and run configuration
% input_map - container map including ADCP measurements
%% Output
% projected_map - container map including 2 more fields: radial and
% tangential current according to config file
% 

projected_map = input_map;
u = input_map('u');
v = input_map('v');
HF_station_to_run = config.ADCP.HF_station;
HF_station_radial_azimuth = config.sys_config.(HF_station_to_run).boresight_angle_azimuth;

[Vr, Vtheta] = cartesian2radial_velocity_conversion(u, v, HF_station_radial_azimuth);

projected_map('Vr') = Vr;
projected_map('Vtheta') = Vtheta;

end