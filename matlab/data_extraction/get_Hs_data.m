function Hs_map = get_Hs_data(config)
%GET_HS_DATA Summary of this function goes here
%   Detailed explanation goes here
Hs_map = containers.Map;
matFilePath = config.Hs.mat_file_path;
loadedData = load(matFilePath);
if isfield(loadedData, string(config.Hs.time_variable))
    time = loadedData.(string(config.Hs.time_variable));
    UTC_datetime = datetime(time', 'ConvertFrom', 'posixtime');
    time_matlab = datenum(UTC_datetime);
else
    time_matlab = zeros(1,1);
end

if isfield(loadedData, string(config.Hs.measurements_variable))
    Hs = loadedData.(string(config.Hs.measurements_variable));
else
    Hs = zeros(1,1);
end

Hs_map('matlab_time') = time_matlab;
Hs_map('datetime') = UTC_datetime;
Hs_map('Hs') = Hs';

end

