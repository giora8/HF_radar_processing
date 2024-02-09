function averageMap = adcp_averagor(config, input_map)
%% Inputs
% config - system and run configuration
% input_map - container map including ADCP measurements
%% Output
% cut_map - container_map of blocked average values
% 
averageMap = containers.Map;
t_matlab = input_map('matlab_time');
dt_min = (t_matlab(2) - t_matlab(1)) * 24 * 60;
R = config.ADCP.period.average_time_minutes / dt_min;
if rem(floor(R * 10), 10) == 5
    block_size = floor(R);
else
    block_size = round(R);
end

allKeys = input_map.keys();
for ii = 1 : length(allKeys)
    currentKey = allKeys{ii};
    currentArray = input_map(currentKey);
    if strcmp(currentKey, 'u') | strcmp(currentKey, 'v')
        block_avg = block_averaging(currentArray', block_size);
        averageMap(currentKey) = block_avg';
    elseif strcmp(currentKey, 'ADCP_sampling_rate') | strcmp(currentKey, 'z')
        averageMap(currentKey) = currentArray;
    else
        averageMap(currentKey) = block_extraction(currentArray, block_size);
    end
end