%% load ADCP .mat data %%

%load('S100287A004_AshkelonA15_0012_4.mat');
load('S100926A010_AshkelonB30_0006_1.mat');

%% extracting relevant data %

% cells unformation

instrument_name = Config.InstrumentName;
N_cells = Config.Burst_NCells;
blanking_distance = Config.Burst_BlankingDistance;  % [m]
cell_size = Config.Burst_CellSize;  % [m]

% time information

Fs = Config.Burst_SamplingRate; % [1/min]

% matlab time

t_matlab = Data.IBurst_Time;

% instrument pressure

P = Data.IBurst_Pressure;  % [dbar]
altimeter_distanceAST = Data.Burst_AltimeterDistanceAST;  % [m]

% velocities [m/s]

u = Data.Burst_VelEast;
v = Data.Burst_VelNorth;

%% compare pressure to altimeter measurements

P_bar = 0.1 .*P ;  % [bar]
bar_seaWater_constant = 9.931170631574;  % bar to sea water colum depth converter
P_meter = P_bar .* bar_seaWater_constant;

mean_sensor_depth = mean(P_meter)
std_sensor_depth = std(P_meter)

mean_altimeter_depth = mean(altimeter_distanceAST)
std_altimeter_depth = std(altimeter_distanceAST)

%% generating depth axis

bottom = mean_sensor_depth + blanking_distance;
z = -double(bottom)+0.1 : double(cell_size) : -bottom+double(N_cells*cell_size);


