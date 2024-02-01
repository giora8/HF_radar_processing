function agg_map = adcp_aggregator(config)
%% Inputs
% config - system and run configuration
%% Output
% agg_map - container_map contains the measurements of all burst file
% 
agg_map = containers.Map('KeyType', 'char', 'ValueType', 'any');
burst_path = config.ADCP.burst_path;
if ~isempty(burst_path)
    burst_files = string(config.ADCP.burst_filenames);
    for ii = 1 : length(burst_files)
        fullPath = fullfile(burst_path, burst_files(ii));
        file_map = adcp_extractor(fullPath);
        keys = file_map.keys();
        for j = 1:length(keys)
            key = keys{j};
            if strcmp(key, 'z') | strcmp(key, 'ADCP_sampling_rate')
                 agg_map(key) = file_map(key);
                 continue
            end               
            % Check if the key is already in the final map
            if isKey(agg_map, key)
                % Concatenate values for the existing key
                agg_map(key) = [agg_map(key) , file_map(key)];
            else
                % Add the key to the final map
                agg_map(key) = file_map(key);
            end
        end
    end
end


end