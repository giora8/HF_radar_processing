addpath(genpath('C:\Giora\TAU\MEPlab\HF_Radar\Codes\Matlab'));
%% set geographical locations

% azimuth of system 0 degree
AZ0 = 300;

% Ashkelon station location
loc_is1 = [34.545, 31.665]; %  (longitude, latitude)

% ADCPs locations
ADCP1 = [34.512833 31.681639]; %  (longitude, latitude)
ADCP2 = [34.532972 31.670556]; %  (longitude, latitude)
POI = [ADCP2 ; ADCP1];

FigH = coast_station_plot;
points_of_interest_plot(POI);

[arclen1, az1] = distance(loc_is1(2), loc_is1(1), ADCP1(2), ADCP1(1));
[arclen2, az2] = distance(loc_is1(2), loc_is1(1), ADCP2(2), ADCP2(1));

arclen1_km = deg2km(arclen1);
arclen2_km = deg2km(arclen2);

[latout1,lonout1] = reckon(loc_is1(2),loc_is1(1), arclen1, AZ0);
[latout2,lonout2] = reckon(loc_is1(2),loc_is1(1), arclen2, AZ0);

POI_cor = [lonout1 latout1 ; lonout2 latout2];
points_of_interest_plot(POI_cor, 'r');
%% clculate points and connect points that are on the same radii
r = 3.25 : 0.25 : 3.75;
r_arc = km2deg(r);
az_axis = 297:305;

lat_points = zeros(length(az_axis), length(r_arc));
lon_points = zeros(length(az_axis), length(r_arc));
for jj = 1 : length(r_arc)
    for ii = 1 : length(az_axis)
        [cur_lat, cur_lon] = reckon(loc_is1(2),loc_is1(1), r_arc(jj), az_axis(ii));
        lat_points(ii, jj) = cur_lat;
        lon_points(ii, jj) = cur_lon;
        cur_POI = [cur_lon, cur_lat];
        points_of_interest_plot(cur_POI, 'm', '.');
        if ii > 1
            hold on; line([cur_lon lon_points(ii-1, jj)], [cur_lat lat_points(ii-1, jj)], 'color', 'r')
        end
    end
end
%% add radials line
p0_lon = lon_points(1, 1);
p0_lat = lat_points(1, 1);

p1_lon = lon_points(:, end);
p1_lat = lat_points(:, end);

for ii = 1 : length(p1_lon)
    hold on; line([p0_lon p1_lon(ii)], [p0_lat p1_lat(ii)], 'color', 'r')
end
    
