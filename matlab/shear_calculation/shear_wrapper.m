try
    config = jsondecode(fileread('../../../run_config.json'));
catch
    config = jsondecode(fileread('run_config.json'));
end

if strcmp(config.shear_calculation_configuration.model, "linear")
    solution_map = linear_shear_calculation(smooth_map);
end