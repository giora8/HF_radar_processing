function measurement_map = phase_velocity_aggregator(config)
%% Inputs
% config - system and run configuration
%% Output
% measurement_map - container map including aggregated values of all keys
% over desired period defined by config
% 
measurement_map = containers.Map('KeyType', 'char', 'ValueType', 'any');

if ~isempty(config.shear_calculation_configuration.run_existing_extraction_path)
    mat_files_folder = config.shear_calculation_configuration.run_existing_extraction_path;
    days = string(config.shear_calculation_configuration.days_to_analyze);
    for ii = 1 : length(days) 
        fullPath = fullfile(mat_files_folder, strcat(days(ii), '.mat'));
        day_map = phase_velocity_extractor(config, fullPath);
        keys = day_map.keys();
        for j = 1:length(keys)
            key = keys{j};
            % Check if the key is already in the final map
            if isKey(measurement_map, key)
                % Concatenate values for the existing key
                measurement_map(key) = [measurement_map(key); day_map(key)];
            else
                % Add the key to the final map
                measurement_map(key) = day_map(key);
            end
        end
    end
end

