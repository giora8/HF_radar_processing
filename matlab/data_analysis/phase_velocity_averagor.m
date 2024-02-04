function averageMap = phase_velocity_averagor(config, input_map)
%% Inputs
% config - system and run configuration
% input_map - aggregated map containing all measurement over desired period
%% Output
% averageMap - container map including block averaged values of all keys
% 
averageMap = containers.Map;
block_size = config.shear_calculation_configuration.number_of_measurements_to_average;
allKeys = keys(input_map);
for i = 1:length(allKeys)
    currentKey = allKeys{i};
    currentArray = input_map(currentKey);
    if strcmp(currentKey, 'timestamp') || strcmp(currentKey, 'datetime')
        averageMap(currentKey) = block_extraction(currentArray, block_size);
    else
        averagedValue = block_averaging(currentArray, block_size);
        averageMap(currentKey) = averagedValue;
    end
end
end

