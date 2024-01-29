function smoothMap = phase_velocity_smoothor(config, input_map)
%% Inputs
% config - system and run configuration
% input_map - container map including aggregated and averaged measurments
%% Output
% smoothMap - container map including filtered timeseries of fields desired
% as input in config
% 
H = 72 / config.shear_calculation_configuration.number_of_measurements_to_average;
dt = 24 / H ;
smoothMap = containers.Map;

keys_to_smooth = config.shear_calculation_configuration.filter_params.fields_to_smooth;
for i = 1:length(keys_to_smooth)
    currentKey = keys_to_smooth{i};
    currentArray = input_map(currentKey);
    filteredArray = filter_timeseries(config, dt, currentArray);
    smoothMap(currentKey) = real(filteredArray); 
end

end