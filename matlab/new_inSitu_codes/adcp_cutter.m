function cut_map = adcp_cutter(config, input_map)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

cut_map = containers.Map();

datatime_ini = config.ADCP.period.initial_datetime;
datatime_final = config.ADCP.period.final_datetime;

datenum_ini = datenum(datatime_ini);
datenum_final = datenum(datatime_final);
t_datenum = input_map('matlab_time');
[idx_ini, idx_final] = extract_period_id_from_time(t_datenum, datenum_ini, datenum_final);
keys = input_map.keys();
for ii = 1:length(keys)
    current_key = keys{ii};
    input_key_value = input_map(current_key);
    if strcmp(current_key, 'ADCP_sampling_rate') | strcmp(current_key, 'z')
        cut_map(current_key) = input_key_value;
        continue
    end
    if size(input_key_value, 1) > 1
        cut_values = input_key_value(:, idx_ini:idx_final);
    else
        cut_values = input_key_value(idx_ini:idx_final);
    end
    cut_map(current_key) = cut_values;
    
end

end