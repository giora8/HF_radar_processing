%% measurement_area_plot.m
function measurement_area_plot(U, lon, lat)
%% Inputs
%  U   = values of measurement for each (latitude, longitude) - 2D matrix,
%  probably size of 160 X 200
%  lon = longitude values of the full map 
%  lat = latitude values of the full map 
% 
%% Output
%  current axes is updated with the range of measurement - with values
%
% -------------------------------------------------------------------------   
    inds = find(~isnan(U));
    [lon_inds, lat_inds] = ind2sub(size(U), inds);
    
    coords = [lon(lon_inds)' lat(lat_inds)'];
    
    U_vals = zeros(length(lon_inds), 1);
    for ii = 1 :length(lon_inds)
        U_vals(ii) = U(lon_inds(ii), lat_inds(ii));
    end
    
    U_vals = U_vals * 100 ; % convert m/s to cm/s
    
    hold on; scatter(coords(:, 1), coords(:, 2),[], U_vals, '.');
    c = colorbar;
    c.Label.String = 'Velocity [cm/s]';

end