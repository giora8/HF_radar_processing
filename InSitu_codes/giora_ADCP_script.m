path1 = 'C:\Giora\TAU\MEPlab\HF_Radar\files\InSitu_files\ADCP_Ashkelon_MarchMay2021\BURSTV_1.mat';
path2 = 'C:\Giora\TAU\MEPlab\HF_Radar\files\InSitu_files\ADCP_Ashkelon_MarchMay2021\BURSTV_2.mat';
path3 = 'C:\Giora\TAU\MEPlab\HF_Radar\files\InSitu_files\ADCP_Ashkelon_MarchMay2021\BURSTV_3.mat';

% extracting basic measurements

[u1, v1, z1, t_matlab1, Fs] = get_basic_data_from_ADCP(path1);
[u2, v2, z2, t_matlab2, ~] = get_basic_data_from_ADCP(path2);
[u3, v3, z3, t_matlab3, ~] = get_basic_data_from_ADCP(path3);
%load('radar_result_to_ADCP.mat');

% extracting overlapping period

tStart_index = 55441; % 23-Mar-2021 at 00:00:02
tEnd_index = 83520; % 02-Apr-2021 23:59:57

[u1, v1, z1, t1] = extract_uvzt_periods(u1, v1, t_matlab1, z1, tStart_index, length(t_matlab1));
[u2, v2, z2, t2] = extract_uvzt_periods(u2, v2, t_matlab2, z2, 1, length(t_matlab2));
[u3, v3, z3, t3] = extract_uvzt_periods(u3, v3, t_matlab3, z3, 1, length(t_matlab3));

% merge measurements

u = [u1 u2 u3(2:end, :)];
v = [v1 v2 v3(2:end, :)];
z = z1;
t = [t1 t2 t3];

% convert to radial and tangential velocity
% TODO: verify correction of angles

r_hat = 300;  % azimuth of the radial with respect to the north
alpha_u = r_hat - 270;
alpha_v = r_hat - 240;

%Vr = u .* cos(deg2rad(alpha_u)) - v .* cos(deg2rad(alpha_v));
%Vtheta = u .* sin(deg2rad(alpha_u)) + v .* sin(deg2rad(alpha_v));

Vr = -u .* sin(deg2rad(60)) + v .* cos(deg2rad(60));
Vtheta = -u .* sin(deg2rad(330)) + v .* cos(deg2rad(330));

%% plot upper layer TS
plotADCPUpperLayerTimeSeries(Vr, 60, Fs)

%% compare with HF

p%%lotCompHF2ADCP(x_plot, U_all_filt, Vr, Vtheta, t, z, 60, Fs, 1);
