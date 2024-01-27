%% plot_radial_range_patch.m
function plot_radial_range_patch(r, dr, angles, target_range, num_of_ranges, station)
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

%------ get sub-region indices of closest and farthest range cells -------%    
    
    [~, min_id] = min(id);
    [~, max_id] = max(id);

%-- get radius value (in angles over earth units) of closest range cells -%    
    
    r_plot = r(id);
    r_arc = km2deg(r_plot);
    
    for ii = 1 : length(r_arc)
        r_arcs(2*ii-1) = km2deg(r_plot(ii) - dr/2);
        r_arcs(2*ii) = km2deg(r_plot(ii) + dr/2);
    end
    
    half_angles = zeros(2*length(angles), 1);
    for ii = 1 :  length(angles)
        half_angles(2*ii-1) = angles(ii) - 0.5;
        half_angles(2*ii) = angles(ii) + 0.5;
    end

%------ calculate (long, lat) locations of edges measurement point -------%
%------------------- in the wanted sub-region ----------------------------%  
      

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
            
            sub_patch_points = [r_arcs(jj*2-1) half_angles(ii*2-1) ; r_arcs(jj*2-1) half_angles(ii*2) ; r_arcs(jj*2) half_angles(ii*2) ; r_arcs(jj*2) half_angles(ii*2-1)];
                        
            [patch_lat, patch_lon] = reckon(station(2),station(1), sub_patch_points(:, 1), sub_patch_points(:, 2));
            
            hold on; h=fill(patch_lon, patch_lat, [0.4940, 0.1840, 0.5560]);
            set(h,'facealpha',.4)

        end
    end

        
%     r_arc_edges = [r_arc(min_id) r_arc(max_id)];
%     y = 0;
%     x = 0;
%     for jj = 1 : length(r_arc_edges)
%         for ii = 1 : length(angles)
%             
%             [cur_y, cur_x] = reckon(station(2),station(1), r_arc_edges(jj), angles(ii));
%             y(end+1) = cur_y;
%             x(end+1) = cur_x;
% 
%         end
%         angles = fliplr(angles);
%     end
%     x = x(2:end);
%     y = y(2:end);

%--------------- update figure with the desired patch --------------------%  
    
%     hold on; h=fill(x, y, [0.4940, 0.1840, 0.5560]);
%     set(h,'facealpha',.4)

end