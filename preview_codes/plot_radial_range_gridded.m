%% plot_radial_range_gridded.m
function plot_radial_range_gridded(r, dr, angles, target_range, num_of_ranges, station)
%% Inputs
% r - range array from the radar
% angles - angles of the wanted radials
% target_range - distance from target to HF station
% num_of_ranges - number of closest range cells to consider
% station - location of HF station in (longitude, latitude)
%
%% Output
% function updates a figure with a patch over considered area around the
% target
%

%------------------ find indices of closest range cells ------------------%

    del = abs(r - target_range);
    [~, id] = sort(del);
    id = id(1:num_of_ranges);

%-- get radius value (in angles over earth units) of closest range cells -%    
    
    r_plot = r(id);
    r_arc = km2deg(r_plot);
    r_arcs = zeros(2*length(r_plot), 1);
    
    for ii = 1 : length(r_arc)
        r_arcs(2*ii-1) = km2deg(r_plot(ii) - dr/2);
        r_arcs(2*ii) = km2deg(r_plot(ii) + dr/2);
    end
    
    half_angles = zeros(length(angles)+1, 1);
    for ii = 1 : 2 : length(angles)
        half_angles(ii) = angles(ii) - 0.5;
        half_angles(ii+1) = angles(ii) + 0.5;
    end

%------ calculate (long, lat) locations of each measurement point --------%
%--------in the wanted sub-region and add lines between each one ---------%  

    lat_points = zeros(length(angles), length(r_arc));
    lon_points = zeros(length(angles), length(r_arc));
    for jj = 1 : length(r_arc)
        for ii = 1 : length(angles)
            
            [cur_lat, cur_lon] = reckon(station(2),station(1), r_arc(jj), angles(ii));
            lat_points(ii, jj) = cur_lat;
            lon_points(ii, jj) = cur_lon;
            cur_POI = [cur_lon, cur_lat];
            
            % add points %
            
            points_of_interest_plot(cur_POI, 'm', '.');
            
            % add patch %
            
            sub_patch_points = [r_arcs(jj*2-1) half_angles(ii) ; r_arcs(jj*2-1) half_angles(ii+1) ; r_arcs(jj*2) half_angles(ii+1) ; r_arcs(jj*2) half_angles(ii)];
                        
            [patch_lat, patch_lon] = reckon(station(2),station(1), sub_patch_points(:, 1), sub_patch_points(:, 2));
            
            line([patch_lon(1) patch_lon(2)], [patch_lat(1) patch_lat(2)], 'color', 'r' )
            line([patch_lon(2) patch_lon(3)], [patch_lat(2) patch_lat(3)], 'color', 'r' )
            line([patch_lon(3) patch_lon(4)], [patch_lat(3) patch_lat(4)], 'color', 'r')
            line([patch_lon(4) patch_lon(1)], [patch_lat(4) patch_lat(1)], 'color', 'r')
%             if ii > 1
%                 hold on;
%                 
%                 line([cur_lon lon_points(ii-1, jj)], [cur_lat lat_points(ii-1, jj)], 'color', 'r')
%             end
%             
%             if jj > 1
%                 hold on; hold on; line([cur_lon lon_points(ii, jj-1)], [cur_lat lat_points(ii, jj-1)], 'color', 'r')
%             end

        end
    end

end