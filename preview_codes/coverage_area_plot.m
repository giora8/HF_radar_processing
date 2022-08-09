%% coverage_area_plot.m
function coords = coverage_area_plot(U, lon, lat)
%% Inputs
%  U   = values of measurement for each (latitude, longitude) - 2D matrix,
%  probably size of 160 X 200
%  lon = longitude values of the full map 
%  lat = latitude values of the full map 
% 
%% Output
%  current axes is updated with the range of measurement (without values)
%  coords: coordinates (longitude, latitude) of points with measurements
%  values
%
% -------------------------------------------------------------------------   
    inds = find(~isnan(U));
    [lon_inds, lat_inds] = ind2sub(size(U), inds);
    
    coords = [lon(lon_inds)' lat(lat_inds)'];

    hold on; scatter(coords(:, 1), coords(:, 2), '.');

end
