%% import vector and ADCP measurements

load('C:\Giora\TAU\MEPlab\HF_Radar\files\InSitu_files\Vector_Ashdod_Ashkelon_8_2_22\vector_measurement.mat');
load('C:\Giora\TAU\MEPlab\HF_Radar\files\InSitu_files\ADCP_Ashdod_Ashkelon_8_2_22\TRDI_data.mat');

%% Platform velocity

U_platform = 0.20585;
V_platform = 0.18801;

%% TRDI downward looking - extract measuring period

initial_datestr = '08-Feb-2022 10:00:00';
final_datestr = '08-Feb-2022 10:57:00';
N_z_cells = 60;

V = wt.vel;
z = wt.r(1, 1:N_z_cells);
t_dnum_adcp = sens.dnum;

initial_dnum = datenum(initial_datestr);
final_dnum = datenum(final_datestr);

[~, id_init_adcp] = min(abs(initial_dnum-t_dnum_adcp));
[~, id_final_adcp] = min(abs(final_dnum-t_dnum_adcp));

V_adcp = V(id_init_adcp:id_final_adcp, 1:N_z_cells, 1:3);
u_adcp = V_adcp(:, :, 1);
v_adcp = V_adcp(:, :, 2);

u_adcp = u_adcp + U_platform;
v_adcp = v_adcp + V_platform;

%% Vector tool - extract measuring period
start_aquisition = datenum('08-Feb-2022 08:00:00');
end_aquisition = datenum('09-Feb-2022 00:23:02');
t_dnum_vector = linspace(start_aquisition, end_aquisition, size(vector_vel_pres, 1))';

V_vector = vector_vel_pres(:, 1:3);
P_vector = vector_vel_pres(:, 4);

V_vector(:, 1) = V_vector(:, 1) + U_platform;  % fix movement of the platform
V_vector(:, 2) = V_vector(:, 2) + V_platform; % fix movement of the platform

initial_datestr = 'February 08, 2022 10:00:00.000 AM';
final_datestr = 'February 08, 2022 10:57:00.000 AM';

initial_dnum = datenum(initial_datestr);
final_dnum = datenum(final_datestr);

[~, id_init_vector] = min(abs(initial_dnum-t_dnum_vector));
[~, id_final_vector] = min(abs(final_dnum-t_dnum_vector));

%id_init = 63232;  % time index when the platform inserted to the sea
%id_final = 89552; % time index when the platform taken out from to the sea

V_vector_cut = V_vector(id_init_vector:id_final_vector, :);
P_vector_cut = P_vector(id_init_vector:id_final_vector);
mean_depth_first_cell = 0.1 * mean(P_vector_cut) * 9.931170631574;

%% averaging ADCP
%id_first_cycle = 3;
%u_adcp = u_adcp(id_first_cycle:end, :);% 12:20
%v_adcp = v_adcp(id_first_cycle:end, :);% 12:20
dt_adcp = 5*60 ;
average_every = 60; % [minutes]
N_cells = round(average_every * 60 / dt_adcp);

% Define the block parameter.  Average in a N_cells row by 1 column wide window.
blockSize = [N_cells, 1];
% Block process the image to replace every element in the 
% N_cells element wide block by the mean of the pixels in the block.

% First, define the averaging function for use by blockproc().
meanFilterFunction = @(theBlockStructure) mean(theBlockStructure.data(:));
% Now do the actual averaging (block average down to smaller size array).
u_adcp = blockproc(u_adcp, blockSize, meanFilterFunction);
v_adcp = blockproc(v_adcp, blockSize, meanFilterFunction);

%% averaging Vector

dt = 1/8;
average_every = 60; % [minutes]

%id_first_cycle = 1569; % 12:15
%first_val = mean(V_vector_cut(1:id_first_cycle-1, :));
%id_first_cycle = 3969;  % 12:20
%first_val = [];
%V_vector_cut = V_vector_cut(id_first_cycle:end, :);

N_cells = round(average_every * 60 / dt);
% Define the block parameter.  Average in a N_cells row by 1 column wide window.
blockSize = [N_cells, 1];
% Block process the image to replace every element in the 
% N_cells element wide block by the mean of the pixels in the block.

% First, define the averaging function for use by blockproc().
meanFilterFunction = @(theBlockStructure) mean(theBlockStructure.data(:));
% Now do the actual averaging (block average down to smaller size array).
V_vector_avg = blockproc(V_vector_cut, blockSize, meanFilterFunction);

%% merging Vector and ADCP

u_merged = [V_vector_avg(:, 1) u_adcp];
v_merged = [V_vector_avg(:, 2) v_adcp];
z_merged = [mean_depth_first_cell z];
  
figure(); plot(u_merged, z_merged);
set(gca, 'YDir','reverse'); xlabel('u [m/s]'); ylabel('Depth [m]');
figure(); plot(v_merged, z_merged);
set(gca, 'YDir','reverse'); xlabel('v [m/s]'); ylabel('Depth [m]');
VV_merged = sqrt(u_merged.^2 + v_merged.^2);
figure(); plot(VV_merged, z_merged);
set(gca, 'YDir','reverse'); xlabel('|V| [m/s]'); ylabel('Depth [m]');

%% convert to radial velocity

r_hat = 120;  % azimuth of Ashdod's radial with respect to the north
% alpha_u = r_hat - 270;
% alpha_v = r_hat - 240;
% 
% Vr = u_merged .* cos(deg2rad(alpha_u)) - v_merged .* cos(deg2rad(alpha_v));
% Vtheta = u_merged .* sin(deg2rad(alpha_u)) + v_merged .* sin(deg2rad(alpha_v));

%theta = 360 - (360-r_hat);

Vr = u_merged .* cos(deg2rad(150)) + v_merged .* sin(deg2rad(150));
Vtheta = u_merged .* sin(deg2rad(150)) + v_merged .* cos(deg2rad(150));

figure(); plot(Vr, z_merged);
xlabel('V_r [m/s]'); ylabel('Depth [m]'); 
set(gca, 'YDir','reverse');

u_mean = mean(u_merged, 1);
v_mean = mean(v_merged, 1);

% Vr_mean = u_mean .* cos(deg2rad(alpha_u)) - v_mean .* cos(deg2rad(alpha_v));
% Vtheta_mean = u_mean .* sin(deg2rad(alpha_u)) + v_mean .* sin(deg2rad(alpha_v));
% 
% Vr_run_mean = movmean(Vr_mean, 6);
% 
% figure(); plot(Vr_run_mean, z_merged);
% xlabel('V_r [m/s]'); ylabel('Depth [m]'); 
% set(gca, 'YDir','reverse');

%% output the profile
zero_pad = [17.5 Vr(end)/2 ; 20 0];
profile = [0 Vr(1) ; z_merged' Vr' ; zero_pad];
profile(:, 1) = -1 .* profile(:, 1);