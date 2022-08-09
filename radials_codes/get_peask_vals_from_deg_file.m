function f_peaks = get_peask_vals_from_deg_file(folder_path, degs_fnames, t)
%% Inputs
% station_location - (long, lat) of HF radar station
% target_location - (long, lat) of desired location within HF radar coverage area
%% Output
% 
% 
%
    
    P_ang = zeros(length(degs_fnames), length(t));
    for ii = 1 : length(degs_fnames)
        cur_filename = strcat(folder_path, degs_fnames(ii).name);
        P_ang(ii, :) = get_range_spec(cur_filename, r, R, N_range_cells, 'avg');
    end
    
    P = mean(P_ang, 1);
    
    first_harmonic = [ 1 -1 ];
    second_harminic = [sqrt(2) -sqrt(2)];
    corner_wave = [2^(3/4) -2^(3/4)];
    
    undisturbed_vals = [first_harmonic ; second_harminic ; corner_wave];
    [f_peaks, ~, ~] = find_ivonin_peaks(P, undisturbed_vals, freq_norm, 1, 'max');


end

