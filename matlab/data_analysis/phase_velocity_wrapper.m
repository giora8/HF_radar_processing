addpath(genpath('..\..\'));

try
    config = jsondecode(fileread('../../../run_config.json'));
catch
    config = jsondecode(fileread('run_config.json'));
end
if ~isempty(config.shear_calculation_configuration.run_existing_extraction_path)
    measurement_dir = config.shear_calculation_configuration.run_existing_extraction_path;
    files = dir(measurement_dir);
    for ii = 1 : length(files) 
        if ~strcmp(files(ii).name, '.') && ~strcmp(files(ii).name, '..') && length(files(ii).name) == 11
            fullPath = fullfile(directoryPath, contents(ii).name);
            day_measurements = get_whole_day_all_measurements(config, fullPath);
        end
    end
end
