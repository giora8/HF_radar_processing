function avg_map = general_inSitu_averagor(sub_config, varargin)
%GENERAL_INSITU_AVERAGOR Summary of this function goes here
%   Detailed explanation goes here
avg_map = containers.Map;

data_path = sub_config.data_path;
variables_to_block_average = sub_config.variables_to_block_average;
mat_data = load(data_path);

independent_variable_name = string(sub_config.variables_to_block_extract);

independent_variable = mat_data.(independent_variable_name);
datetimeValues = datetime(independent_variable', 'ConvertFrom', 'posixtime');

dt_min = (independent_variable(2)-independent_variable(1)) / 60;
block_size = round(sub_config.period.average_time_minutes / dt_min);

initial_posix_time = posixtime(datetime(sub_config.period.initial_datetime));
final_posix_time = posixtime(datetime(sub_config.period.final_datetime));
[idx_ini, idx_final] = extract_period_id_from_time(independent_variable, initial_posix_time, final_posix_time);

avg_map(independent_variable_name) = block_extraction(independent_variable(idx_ini:idx_final), block_size);
avg_map('datetime') = datetimeValues(idx_ini:idx_final);
for i = 1:length(variables_to_block_average)
    variable = variables_to_block_average{i};
    if isfield(mat_data, variable)
        variable_data = mat_data.(variable);
        cut_variable_data = variable_data(idx_ini:idx_final);
        block_avg = block_averaging(cut_variable_data', block_size);
        avg_map(variable) = block_avg;
    end

end

if sub_config.project_data && nargin == 2
    u = avg_map(variables_to_block_average{1});
    v = avg_map(variables_to_block_average{2});
    [Vr, Vtheta] = cartesian2radial_velocity_conversion(u, v, varargin{1});
    avg_map("Vr") = Vr;
    avg_map("Vtheta") = Vtheta;
end

end
