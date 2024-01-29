addpath(genpath('..\..\'));

try
    config = jsondecode(fileread('../../../run_config.json'));
catch
    config = jsondecode(fileread('run_config.json'));
end
agg_map = phase_velocity_aggregator(config);
avg_map = phase_velocity_averagor(config, agg_map);
smooth_map = phase_velocity_smoothor(config, avg_map);
