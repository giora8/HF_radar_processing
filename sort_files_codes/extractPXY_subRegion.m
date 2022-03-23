%% extractPXY_subRegion.m
function [range_coords, ids_2d_range] = extractPXY_subRegion(lon_lat, ids_exist, border_vals)
%% Inputs
% lon_lat - coordinates of measurements locations (longitude, latitude)
% ids_exist - indices of coordinates of measurements locations (longitude, latitude)
% border_vals - values of minimum and maximum longitude and latitude
% (longitude, latitude)
% 
%% Output
%  range_coords - coordinates of the sub region
%  ids_2d_range - indices of coordinates of the sub region
%
%-------------------------extract values of sub region---------------------

    lon_border_min = min(border_vals(:, 1));
    lon_border_max = max(border_vals(:, 1));

    lat_border_min = min(border_vals(:, 2));
    lat_border_max = max(border_vals(:, 2));

%--------extract the measured (lon, lat) inside the desired range----------

    ids_range_lon = find(lon_lat(:,1)>=lon_border_min & lon_lat(:,1) < lon_border_max);
    ids_range_lat = find(lon_lat(:,2)>=lat_border_min & lon_lat(:,2) < lat_border_max);

    ids_range = find(ismember(ids_range_lon, ids_range_lat)); % 1d array indices of longitude & latitude inside desired range
    range_coords = lon_lat(ids_range_lon(ids_range), :); % coordinates values of desired range
    ids_2d_range = ids_exist(ids_range_lon(ids_range), :); % coordinates' indices values of desired range

end
