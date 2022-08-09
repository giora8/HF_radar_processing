
addpath('C:\Giora\TAU\MEPlab\HF_Radar\Codes\Matlab\voulgaris_readWERA_files');

%% set buoys locations %%
buoy1 = [34.512833 31.681639]; %  (longitude, latitude)
buoy2 = [34.532972 31.670556]; %  (longitude, latitude)
locations = [buoy1 ; buoy2];
%% set range around the buoys %%

lon_max = max(buoy1(1), buoy2(1));
lon_min = min(buoy1(1), buoy2(1));

lat_max = max(buoy1(2), buoy2(2));
lat_min = min(buoy1(2), buoy2(2));

max_factor_lon = 1.002;
min_factor_lon = 0.999;

max_factor_lat = 1.001;
min_factor_lat = 0.999;

lon_border_max = max_factor_lon * lon_max;
lon_border_min = min_factor_lon * lon_min;

lat_border_max = max_factor_lat * lat_max;
lat_border_min = min_factor_lat * lat_min;

%% find existing (lat, lon) coordinates from .spec file

%----------------loading coordinates and .spec files-----------------------

load('C:\Giora\TAU\MEPlab\HF Radar\files\check_duplicates_files\rad_vel.mat');  % coordinates

basic_path = 'C:\Giora\TAU\MEPlab\HF Radar\files\';
filename_spec = '20210830620_is1.spec';
[~,~,~,~,~,freq,fbragg,PXY] = read_WERA_spec(strcat(basic_path, filename_spec), 'UTM');

%----------------extract non empty coordinates' indices--------------------

ids_non_empty=find(~cellfun('isempty',PXY));
[ii, jj] = ind2sub(size(PXY), ids_non_empty);
ids_exist = [ii jj];

%-----------values of non empty longitude and latitude---------------------

lon_exist = lon(ii)'; 
lat_exist = lat(jj)'; 
lon_lat_exist = [lon_exist lat_exist];

%--extract the measured (lon, lat) inside the desired range around buoys---

ids_range_lon = find(lon_lat_exist(:,1)>=lon_border_min & lon_lat_exist(:,1) < lon_border_max);
ids_range_lat = find(lon_lat_exist(:,2)>=lat_border_min & lon_lat_exist(:,2) < lat_border_max);

ids_range = find(ismember(ids_range_lon, ids_range_lat)); % 1d array indices of longitude & latitude inside desired range
range_coords = lon_lat_exist(ids_range_lon(ids_range), :); % coordinates values of desired range
ids_2d_range = ids_exist(ids_range_lon(ids_range), :); % coordinates' indices values of desired range

%% averaging spectrum over desired region

longitude_indices = ids_2d_range(:, 1);
latitude_indices = ids_2d_range(:, 2);

%------------generate average spectrum over desired region-----------------

P = PXY{longitude_indices(1), latitude_indices(1)}';

for cur_cell = 2 : length(longitude_indices)
    P = (P + PXY{longitude_indices(cur_cell), latitude_indices(cur_cell)}') ./ 2;
end

%-----------plot coverage area and average Doppler spectrum----------------

figure(); plot(f, P);
xlabel('Doppler shift [Hz]');
ylabel('avg. Backscattered Power over region [dB]');
[~] = coast_station_plot;
points_of_interest_plot(locations);
hold on;
scatter(lon_exist, lat_exist, '.');
hold on;
scatter(lon(longitude_indices), lat(latitude_indices), '.');

%% spectrum of closest HF measurement point

%----------find closest coordinates for each of the ADCPs------------------

[arclen1, ~] = distance(range_coords(:, 2), range_coords(:, 1), buoy1(2), buoy1(1));
[~, closest_id1] = min(arclen1);
id_coord1 = [longitude_indices(closest_id1) latitude_indices(closest_id1)];
[arclen2, ~] = distance(range_coords(:, 2), range_coords(:, 1), buoy2(2), buoy2(1));
[~, closest_id2] = min(arclen2);
id_coord2 = [longitude_indices(closest_id2) latitude_indices(closest_id2)];
closest_plot = [range_coords(closest_id1, :) ; range_coords(closest_id2, :)]; 

%--------get the measured spectrum for each of the coordinates-------------

P_buoy1 = PXY{id_coord1(1), id_coord1(2)};
P_buoy2 = PXY{id_coord2(1), id_coord2(2)};

%------plot coverage area and Doppler spectrum for each closest point------

fig = coast_station_plot;
points_of_interest_plot(locations);
hold on; scatter(lon(longitude_indices), lat(latitude_indices), '.');
hold on; scatter(closest_plot(:, 1), closest_plot(:, 2), 55, 'x');

figure(); plot(freq, P_buoy1);
xlabel('Doppler shift [Hz]');
ylabel('avg. Backscattered Power over region [dB]');
title('Doppler spectrum near 30_m ADCP');

figure(); plot(freq, P_buoy2);
xlabel('Doppler shift [Hz]');
ylabel('avg. Backscattered Power over region [dB]');
title('Doppler spectrum near 15_m ADCP');