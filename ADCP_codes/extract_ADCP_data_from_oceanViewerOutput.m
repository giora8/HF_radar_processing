%% load ADCP .mat data %%

%load('S100287A004_AshkelonA15_0012_4.mat');
load('C:\Giora\TAU\MEPlab\HF_Radar\files\ADCP_files\BURSTV_1.mat');

%% extracting relevant data %

% cells unformation

instrument_name = Config.Instrument_instrumentName;
N_cells = Config.Instrument_burst_nCells;
blanking_distance = Config.Instrument_burst_blankingDistance;  % [m]
cell_size = Config.Instrument_burst_cellSize;  % [m]

% time information

Fs = 1/5; % [1/s]

% matlab time

t_matlab = Burst_Data.TimeMatlab;

% instrument pressure

P = Burst_Data.Pressure;  % [dbar]

% velocities [m/s]

u = Burst_Data.BinMapVelEast;
v = Burst_Data.BinMapVelNorth;

%% compare pressure to altimeter measurements

P_bar = 0.1 .*P ;  % [bar]
bar_seaWater_constant = 9.931170631574;  % bar to sea water colum depth converter
P_meter = P_bar .* bar_seaWater_constant;

mean_sensor_depth = mean(P_meter);
std_sensor_depth = std(P_meter);

%% generating depth axis

bottom = mean_sensor_depth + blanking_distance;
z = -double(bottom)+0.1 : double(cell_size) : -bottom+double(N_cells*cell_size);

%%

t0_index = 55441; % 23/3/21 at 00:00:02
average_every = 60*60; % 20 minutes
average_every_index = round(average_every * Fs);

day_to_analyze = 6;
delta_index = round((day_to_analyze * 24 * 60 * 60)*Fs);

crop_t = t_matlab(t0_index: t0_index+delta_index);
crop_u = u(1:56, t0_index: t0_index+delta_index);
crop_v = v(1:56, t0_index: t0_index+delta_index);
z = z(1:56);

%%

Vr = crop_u*cos(deg2rad(30)) + crop_v*cos(deg2rad(60));
Vtheta = crop_u*sin(deg2rad(30)) + crop_v*sin(deg2rad(60));

%%
T1 = 1; T2 = 5;
index1 = T1*60*60*Fs+1;
index2 = T2*60*60*Fs+1;
Vr_mean = mean(Vr(:, index1:index2), 2);
Vtheta_mean = mean(Vtheta(:, index1:index2), 2);

figure(); plot(Vr_mean , z);
title(strcat(string(T1), '-', string(T2)));
figure(); plot(Vtheta_mean , z);
title(strcat(string(T1), '-', string(T2)));

%%
figure(); plot(mean(Vr(:, 1:average_every_index), 2), z);
for ii = average_every_index+1 : average_every_index : length(crop_t)-average_every_index
    plot(mean(Vr(:, ii:ii+average_every_index-1), 2), z);
    title(datestr(crop_t(ii)));
    pause(0.1);
end
   
%%


