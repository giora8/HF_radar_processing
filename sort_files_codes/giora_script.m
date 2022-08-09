%% loading coordinates & .spec file %%
load('lonlat.mat');
basic_path = 'C:\Giora\TAU\MEPlab\HF_Radar\files\all_latest_specs\';
listdir = dir(basic_path);
listdir = listdir(3:end);
for ii = 4 : length(listdir)
    filename_spec = listdir(ii).name;
    
    [~,~,~,~,~,freq,fbragg,PXY] = read_WERA_spec(strcat(basic_path, filename_spec));
   
%% set buoys locations %%

% ADCPs locations
buoy1 = [34.512833 31.681639]; %  (longitude, latitude)
buoy2 = [34.532972 31.670556]; %  (longitude, latitude)

% random locations in Ashdod range
%buoy1 = [34.4525 31.876]; %  (longitude, latitude)
%buoy2 = [34.3564 31.9165]; %  (longitude, latitude)

locations = [buoy1 ; buoy2];
%clear basic_path
%% set range around the buoys %%

lon_max = max(buoy1(1), buoy2(1));
lon_min = min(buoy1(1), buoy2(1));

lat_max = max(buoy1(2), buoy2(2));
lat_min = min(buoy1(2), buoy2(2));

max_factor_lon = 1.008;
min_factor_lon = 0.996;

max_factor_lat = 1.008;
min_factor_lat = 0.996;

% max_factor_lon = 1.005;
% min_factor_lon = 0.996;
% 
% max_factor_lat = 1.005;
% min_factor_lat = 0.996;

lon_border_max = max_factor_lon * lon_max;
lon_border_min = min_factor_lon * lon_min;

lat_border_max = max_factor_lat * lat_max;
lat_border_min = min_factor_lat * lat_min;
border_vals = [lon_border_min lat_border_min ; lon_border_max lat_border_max];
clear buoy1 buoy2 lat_border_max lat_border_min lat_max lat_min locations ...
    lon_border_max lon_border_min lon_max lon_min max_factor_lat max_factor_lon...
    min_factor_lat min_factor_lon
%% extracting sub region %%
[ids_exist, lon_lat_exist] = extractPXY_nonEmptyCells(PXY, lon, lat);
[range_coords, ids_2d_range] = extractPXY_subRegion(lon_lat_exist, ids_exist, border_vals);
%%
[f_peaks, U, f_partial, P_partial] = ivonin_spec(PXY, ids_2d_range, lon, lat, freq, fbragg, 1);
figure(); plot(f_partial(1, :), P_partial(1, :)); hold on; plot(f_partial(1, :), P_partial(2, :));
xlabel('Normalized frequency'); ylabel('Backscattered Power [dB]');
legend('Positive peak', 'Negative peak', 'box', 'off');
sentence = strcat('U_p=', num2str(U(1)), ' [m/s] ', ' U_n=', num2str(U(2)), ' [m/s]');
disp(sentence);
end