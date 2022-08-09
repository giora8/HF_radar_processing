try
    load('C:\Giora\TAU\MEPlab\HF_Radar\files\check_duplicates_files\rad_vel.mat');  % get: is1_rad, is2_rad, lon, lat

%% points of interest inside radar coverage area
    p1 = [34.512833 31.681639]; %  ADCP1 (longitude, latitude)
    p2 = [34.532972 31.670556]; %  ADCP2 (longitude, latitude)
    p3 = [34.543483 31.9066]; %  Ashdod buoy (longitude, latitude)
    locs = [p1 ; p2 ; p3];

%% plot session - values of radial current from israel_1
    FigH = coast_station_plot;  % plot the shoreline and the stations
    points_of_interest_plot(locs);  % add exampled points of interests to the map
    measurement_area_plot(is2_rad, lon, lat);  % add is1 radial velocity to the map

%% plot session - coverage area israel_2
    %FigH = coast_station_plot;  % plot the shoreline and the stations
    hold on; coverage_area_plot(is2_rad, lon, lat);  % add is1 radial velocity to the map
catch
    disp('Missing measurement data - exist in: /Public/Projects/HF team/Codes/Matlab/imported_data_bases/rad_vel.mat');
end