%% set environment
% Get the current working directory
currentDirectory = pwd;

config = jsondecode(fileread('../../run_config.json'));

% Add current directory and its parent directory to the MATLAB path
addpath(currentDirectory, fileparts(currentDirectory));

% Generate a path string that includes all subfolders
allSubfolders = genpath(currentDirectory);

% Add all subfolders to the MATLAB path
addpath(allSubfolders);
allSubfolders = genpath(pwd);

%% extract shear from HF radar

agg_map = phase_velocity_aggregator(config);
avg_map = phase_velocity_averagor(config, agg_map);
smooth_map = phase_velocity_smoothor(config, avg_map);
solution_map = linear_shear_calculation(smooth_map);

a1 = solution_map('alpha1');
b1 = solution_map('beta1');

a2 = solution_map('alpha2');
b2 = solution_map('beta2');
datetime_HF_str = avg_map('datetime');
datetime_HF = str2datetime(datetime_HF_str);


%% extract measurements from ADCP

agg_map = adcp_aggregator(config);
cut_map = adcp_cutter(config, agg_map);
avg_map = adcp_averagor(config, cut_map);
projected_map_adcp = adcp_projection(config, avg_map);
Vr_adcp = projected_map_adcp('Vr');
datetime_adcp_str = projected_map_adcp('datetime');
datetime_adcp = str2datetime(datetime_adcp_str);

%% extract Hs from ADCP

Hs_map = get_Hs_data(config);
cut_map_Hs= adcp_cutter(config, Hs_map);
avg_map_Hs = adcp_averagor(config, cut_map_Hs);
datetime_Hs_str = avg_map_Hs('datetime');
datetime_Hs = str2datetime(datetime_Hs_str);
Hs = str2double(avg_map_Hs('Hs'));

%% extract measurments from ims

ims_map = get_ims_data(config);
cut_map_ims = adcp_cutter(config, ims_map);
avg_map_ims = adcp_averagor(config, cut_map_ims);
projected_map_ims = adcp_projection(config, avg_map_ims);
Vr_ims = projected_map_ims('Vr');
datetime_ims_str = projected_map_ims('datetime')';
datetime_ims = str2datetime(datetime_ims_str);

%% real results of alpha

date1 = datetime('2021-03-23 17:00:00');
date2 = datetime('2021-03-25 03:00:00');

date3 = datetime('2021-04-02 03:00:00');
date4 = datetime('2021-04-02 17:00:00');

date5 = datetime('2021-04-09 23:00:00');
date6 = datetime('2021-04-11 13:00:00');


%% plot timeseries - wind

fig=figure; fig.Position = [10 10 1100 450];
plot(datetime_ims, Vr_ims);

xline(date1, 'black--', 'LineWidth', 2)
xline(date2, 'black--', 'LineWidth', 2)

xline(date3, 'black--', 'LineWidth', 2)
xline(date4, 'black--', 'LineWidth', 2)

xline(date5, 'black--', 'LineWidth', 2)
xline(date6, 'black--', 'LineWidth', 2)

xlabel('date');
ylabel('Wind along radial [m/sec]')

%% plot timeseries - Hs
fig=figure; fig.Position = [10 10 1100 450];
plot(datetime_Hs, Hs);

xline(date1, 'black--', 'LineWidth', 2)
xline(date2, 'black--', 'LineWidth', 2)

xline(date3, 'black--', 'LineWidth', 2)
xline(date4, 'black--', 'LineWidth', 2)

xline(date5, 'black--', 'LineWidth', 2)
xline(date6, 'black--', 'LineWidth', 2)

xlabel('date');
ylabel('H_s [m]');