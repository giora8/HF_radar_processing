addpath(genpath('..\..\'));

try
    config = jsondecode(fileread('../../../run_config.json'));
catch
    config = jsondecode(fileread('run_config.json'));
end

ims_map = get_ims_data(config);
cut_map = adcp_cutter(config, ims_map);
avg_map = adcp_averagor(config, cut_map);
projected_map = adcp_projection(config, avg_map);
