function ims_map = get_ims_data(config)
%% Inputs
% config - config with system and run configuration
%% Output
% ims_map - extracted measurements from the csv file
% 
ims_map = containers.Map;
ims_file_path = config.wind.data_path;
selected_column_names = string(config.wind.columns);

data_table = readtable(ims_file_path, 'VariableNamingRule', 'preserve');
selected_data = data_table(:, selected_column_names);

ISR_datetime = selected_data.("Date & Time (Winter)");
wind_speed = selected_data.("Wind speed (m/s)");
wind_direction = selected_data.("Wind direction (°)");

UTC_datetime = ISR_datetime - hours(2);  % convert ISR winter time to UTC time
t_matlab = datenum(UTC_datetime);
u = wind_speed .* sin(deg2rad(wind_direction)) * (-1);
v = wind_speed .* cos(deg2rad(wind_direction)) * (-1);

ims_map('datetime') = UTC_datetime';
ims_map('matlab_time') = t_matlab';
ims_map('u') = u';
ims_map('v') = v';
ims_map('wind_speed') = wind_speed';
ims_map('wind_direction_deg') = wind_direction';
ims_map('std_wind_speed') = selected_data.("Standard deviation wind direction (°)")';

end

