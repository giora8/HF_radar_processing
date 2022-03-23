% This script reads .asc file & .mat file contains netcdf values of the
% same time step and compare them

%% read cur_asc file
close all;
ftime = 'C:\Giora\TAU\MEPlab\HF_Radar\files\check_duplicates_files\20210600000_izr.cur_asc';
[IX,IY,U,V,Uer,Ver,KL]=read_WERA_asc_cur(ftime);

U_mat = nan(160, 200);
V_mat = nan(160, 200);

for ii = 1 : length(IX)
    U_mat(IX(ii), IY(ii)) = U(ii);
    V_mat(IX(ii), IY(ii)) = V(ii);
end

%% compare with netcdf absolute velocity
load('C:\Giora\TAU\MEPlab\HF_Radar\files\check_duplicates_files\abs_vel.mat');

id1 = find(~isnan(U_mat));
id2 = find(~isnan(U));

max(id1-id2)

del_U = U_mat - U;
figure(); imagesc(del_U);

id1 = find(~isnan(V_mat));
id2 = find(~isnan(V));

max(id1-id2)

del_V = V_mat - V;
figure(); imagesc(del_V);

load('coastlines');
figure();plot(coastlon, coastlat);
hold on; quiver(lon, lat, U_mat', V_mat', 2.5);
xlim([0.99*min(lon) 1.01*max(lon)]);
ylim([0.99*min(lat) 1.01*max(lat) ]);

hold on; quiver(lon, lat, U', V', 2.5);
%% read crad file

fname = 'C:\Giora\TAU\MEPlab\HF_Radar\files\check_duplicates_files\20210600000_is1.crad';
[Time,lat,lon,x,y,u,uvar,uacc,pwr,ang,Range]=read_WERA_crad(fname);


%% compare with netcdf radial velocity
load('C:\Giora\TAU\MEPlab\HF_Radar\files\check_duplicates_files\rad_vel.mat');

id1 = find(~isnan(u));
id2 = find(~isnan(U));
max(id1-id2)

del = u - U;
figure(); imagesc(del);
u(isnan(u)) = 0;
load('coastlines');
figure();plot(coastlon, coastlat);
hold on;
imagesc(lon, lat, u);
