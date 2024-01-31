addpath(genpath('..\..\'));

try
    config = jsondecode(fileread('../../../run_config.json'));
catch
    config = jsondecode(fileread('run_config.json'));
end

agg_map = adcp_aggregator(config);
cut_map = adcp_cutter(config, agg_map);
avg_map = adcp_averagor(config, cut_map);
projected_map = adcp_projection(config, avg_map);
