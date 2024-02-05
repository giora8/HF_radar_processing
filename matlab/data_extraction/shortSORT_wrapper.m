%% set environment and load configuration
addpath(genpath('..\'));
config = jsondecode(fileread('../shortSORT_run_config.json'));
global_params;

%% import run configuration params
input_map = containers.Map;

input_map("root_synology_path") = config.sys_config.synology_root;
input_map("root_target_path") = config.sys_config.output_path;

HF_station_to_run = config.extraction_configuration.HF_station;
station_id = config.sys_config.(HF_station_to_run).name;
input_map("station_id") = station_id;

cell_size = config.extraction_configuration.division_params.short_samples;
step_size = config.extraction_configuration.division_params.shift_samples;
num_range_cells = config.extraction_configuration.division_params.num_range_cells;
distance = config.extraction_configuration.range;
input_map("cell_size") = cell_size;
input_map("step_size") = step_size;
input_map("num_cells") = num_range_cells;
params_string = strcat(short_', string(cell_size), '_shift_', string(step_size), '_range_', string(num_range_cells));

angles_borders = config.extraction_configuration.angles;
input_map("max_distance_to_calc") = distance;
input_map("angles_borders") = angles_borders;

input_map("chirp_duration") = config.sys_config.(HF_station_to_run).chirp_duration_sec;
input_map("total_SORT_time") = config.sys_config.(HF_station_to_run).total_SORT_time_min;

days_to_run = string(config.days_to_analyze);

input_map('shortSORT_run_root') = fullfile(config.sys_config.short_SORT_root_path, station_id, "shortSORT", params_string);
input_map('target_output_root') = fullfile(config.sys_config.short_SORT_ascii_path, params_string);

start_time = char(sort_times(min(config.extraction_configuration.hours_to_run)));
end_time = char(sort_times(max(config.extraction_configuration.hours_to_run)));
input_map('start_time') = start_time;
input_map('end_time') = end_time;


%% run internal waves matrix extraction

for ii = 1 : length(days_to_run)
    current_day = days_to_run(ii);
    day_map = generate_internal_wave_container(input_map, current_day);
    mat_name = strcat(station_id, '_cell_', cell_size, '_step_', step_size, '_distance_', range, '_ang_', string(min(angles_borders)), '_', string(max(angles_borders)), '_day_', current_day, '_from_', start_time, '_to_', end_time, '.mat');
    fname = fullfile(config.sys_config.output_path, mat_name);
    save(fname, day_map);
end


