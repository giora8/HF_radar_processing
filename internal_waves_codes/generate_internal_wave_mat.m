%% generate_internal_wave_mat.m
function [neg_mat, zero_mat, pos_mat, sig_neg_mat, sig_zero_mat, sig_pos_mat, Rs, t, alphas] = generate_internal_wave_mat(R, ANG, cell_size, step_size, ST, YYYYDDD)
%% Inputs
% R - (int) number of radial cells to extract (from 1 to R)
% ANG - (int) number of azimuthal angles to extract (from -ANG to +ANG)
% cell_size - (int) number of samples (power of 2)
% step_size - (int) number of samples between consecutive cells (power of
% 2)
% ST - (string) station name. is1 - Ashkelon, is2 - Ashdod
% YYYYDDD - year and day of the measurement
%% Output
% neg_mat - negative peak values for each time step, angle and radial
% [time X 2*ANG+1 X R]
% zero_mat - zeroth peak values for each time step, angle and radial
% [time X 2*ANG+1 X R]
% neg_mat - positive peak values for each time step, angle and radial
% [time X 2*ANG+1 X R]
%
% -----------------initialize path and parameters-------------------------%
        
    T_chirp = 0.26;
    
    base_sort_path = strcat('Z:\data\', ST, '\shortSORT\short_', string(cell_size), '_shift_', string(step_size), '_range_100\', YYYYDDD, '\shortSORT_');
    base_shortSort_path = strcat('Z:\radials_spectrum_shortSort\short_', string(cell_size), '_shift_', string(step_size), '_range_100\');
    
    station_path = strcat(base_shortSort_path, ST, '\');
    station_date_path = strcat(station_path, YYYYDDD, '\');
    
% -----------------read all degree files from the folder------------------%
    
    deg_file_list = dir(station_date_path);
    deg_file_list = deg_file_list(3:end);
    
% -------------------initialize results matrices--------------------------%
    
    neg_mat = zeros(length(deg_file_list), 2*ANG+1, R);
    zero_mat = zeros(length(deg_file_list), 2*ANG+1, R);
    pos_mat = zeros(length(deg_file_list), 2*ANG+1, R);
    
    sig_neg_mat = zeros(length(deg_file_list), 2*ANG+1, R);
    sig_zero_mat = zeros(length(deg_file_list), 2*ANG+1, R);
    sig_pos_mat = zeros(length(deg_file_list), 2*ANG+1, R);
    
    Rs = zeros(1, R);
    
%-----------fine peak location for every time, angle and distance---------%
    
    ind_time = 1;
    new_sort_flag = 1;
    for ii = 1 : length(deg_file_list)
        
        cur_fname = deg_file_list(ii).name;
        ang_num = extract_ang_number(cur_fname);
        
        if ang_num >= -ANG && ang_num <= ANG
        
            ind_ANG = ANG + ang_num + 1;

%------------------find time index according to filename------------------%

            if ii > 1
                st1 = cur_fname(1:13);
                st2 = deg_file_list(ii-1).name;
                st2 = st2(1:13);
                if ~strcmp(st1, st2)
                    ind_time = ind_time + 1;
                    new_sort_flag = 1;
                else
                    new_sort_flag = 0;
                end
            end

%-----------extract radial and frequency axis for every sort--------------%

            if new_sort_flag == 1

                time = str2double(cur_fname(10));
                shortSort_val = int2str(floor(time/2)*2);
                shortSort_val = strcat(cur_fname(8:9), shortSort_val, '0'); 

                sort_folder = strcat(base_sort_path, shortSort_val);
                sort_fname = strcat(sort_folder, '\', cur_fname(1:17), '.SORT');
                [~,t,r,~,~] = read_WERA_sort_partial(char(sort_fname));

                f = create_frequency_axis(t);
                if r(1) < 0
                    Rs(end+1, :) = r(2:R+1);
                else
                    Rs(end+1, :) = r(1:R);
                end
                new_sort_flag = 0;
            end

%----------evaluate peak location for every distance up to R--------------%

            deg_file = strcat(deg_file_list(ii).folder, '\', cur_fname);
            P_out = get_range_spec(deg_file, r, 0, R, 'discrete');
            [neg, zero, pos, sig_neg, sig_zero, sig_pos] = extract_peaks_locs_for_internal_waves(P_out, f);

%-------------------plug values inside output matrices--------------------%        

            neg_mat(ind_time, ind_ANG, :) = neg;
            zero_mat(ind_time, ind_ANG, :) = zero;
            pos_mat(ind_time, ind_ANG, :) = pos;

            sig_neg_mat(ind_time, ind_ANG, :) = sig_neg;
            sig_zero_mat(ind_time, ind_ANG, :) = sig_zero;
            sig_pos_mat(ind_time, ind_ANG, :) = sig_pos;
        end
    end

%----------------------extracting non-zero values-------------------------%            
    
    neg_mat = neg_mat(1:ind_time, :, :);
    zero_mat = zero_mat(1:ind_time, :, :);
    pos_mat = pos_mat(1:ind_time, :, :);
    
    sig_neg_mat = sig_neg_mat(1:ind_time, :, :);
    sig_zero_mat = sig_zero_mat(1:ind_time, :, :);
    sig_pos_mat = sig_pos_mat(1:ind_time, :, :);
    
    Rs = Rs(2:end, :);
    dt = T_chirp * cell_size;
    t = 0 : dt : (ind_time-1)*dt;
    alphas = -ANG : 1 : ANG;
    
end

