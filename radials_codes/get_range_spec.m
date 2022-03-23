%% get_degrees_files.m
function P_out = get_range_spec(deg_file, r, target_range, num_of_ranges, output_type)
%% Inputs
% deg_file - radial specturm file [ranges X frequency]
% r - range array from the radar
% target_range - range [km] of the target from the station
% num_of_ranges - number of closest range cells to consider
% output_type - 'discrete' for P in every range. 'avg' - for avereged power
% over wanted range cells
%% Output
% P_out - output spectrum over the range cell considered
% fixed_r - radials without negative values if appear in the original radials
%
%------------------------- read .asc file --------------------------------%

    P = open_ascii_radial_spectrum(deg_file);
    
%----------------- remove negative radials if appear ----------------------%

    if size(P, 1) ~= length(r)
        diff_r = length(r) - size(P, 1);
        r = r(diff_r+1:end);
    end

%--------------- find indices of closest range cells ---------------------%
    
    del = abs(r - target_range);
    [~, id] = sort(del);
    id = id(1:num_of_ranges);

%------------ generates desired specturm (avg or discrete) ---------------%    
 
    if contains(output_type, 'discrete')
        P_out = P(id, :);
    else
        P_out = mean(P(id, :), 1);
    end

end