function days_map = generate_internal_wave_container(input_map, day)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

days_map = containers.Map;

N_meas_per_sort = round(input_map('total_SORT_time') / (input_map('chirp_duration') * input_time('cell_size') / 60));

base_sort_path = fullfile(input_map('shortSORT_run_root'), day, strcat('\shortSORT_'));
base_shortSort_path = input_map('target_output_root');

station_path = fullfile(base_shortSort_path, input_map('station_id'));
station_date_path = fullfile(station_path, day);

start_time = input_map('start_time');
end_time = input_map('end_time');

hour_start = str2double(start_time(1:2));
min_start = str2double(start_time(3:4));

hour_end = str2double(end_time(1:2));
min_end = str2double(end_time(3:4)) + 19;

N1 = 3*(hour_end - hour_start);
N2 = min_start / 20;
N3 = (min_end+1) / 20;

N_time_steps = N_meas_per_sort * (N1 - N2 + N3);
    
%------------------read all degree files from the folder------------------%

deg_file_list = dir(station_date_path);
deg_file_list = deg_file_list(3:end);

%--------------------initialize results matrices--------------------------%
    
    neg_mat = zeros(N_time_steps, 2*ANG+1, R);
    zero_mat = zeros(N_time_steps, 2*ANG+1, R);
    pos_mat = zeros(N_time_steps, 2*ANG+1, R);
    
    sig_neg_mat = zeros(N_time_steps, 2*ANG+1, R);
    sig_zero_mat = zeros(N_time_steps, 2*ANG+1, R);
    sig_pos_mat = zeros(N_time_steps, 2*ANG+1, R);
    
    acc_neg_mat = zeros(N_time_steps, 2*ANG+1, R);
    acc_zero_mat = zeros(N_time_steps, 2*ANG+1, R);
    acc_pos_mat = zeros(N_time_steps, 2*ANG+1, R);
    
    Rs = zeros(1, R);
    FREQS = zeros(1, 1);
    
%-----------fine peak location for every time, angle and distance---------%
    if strcmp(start_time, '0000')
        ind_time = 1;
    else
        ind_time = 0;
    end
    new_sort_flag = 1;
    for ii = 1 : length(deg_file_list)
        
        cur_fname = deg_file_list(ii).name;
        ang_num = extract_ang_number(cur_fname);
        
        cur_hour = str2double(cur_fname(8:9));
        cur_min = str2double(cur_fname(10:11));
        
        if cur_hour >= hour_start && cur_min >= min_start
            if cur_hour <= hour_end && cur_min <= min_end
        
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
                        [WERA,t,r,~,~] = read_WERA_sort_partial(char(sort_fname));

                        f = create_frequency_axis(t);
                        if r(1) < 0
                            Rs(end+1, :) = r(2:R+1);
                        else
                            Rs(end+1, :) = r(1:R);
                        end
                        FREQS(1, end+1) = WERA.FREQ .* 10^6;
                        new_sort_flag = 0;
                    end

%----------evaluate peak location for every distance up to R--------------%

                    deg_file = strcat(deg_file_list(ii).folder, '\', cur_fname);
                    P_out = get_range_spec(deg_file, r, 0, R, 'discrete');
                    [neg, zero, pos, sig_neg, sig_zero, sig_pos, ~, ~, ~]...
                        = extract_peaks_locs_for_internal_waves(P_out, f);

%-------------------plug values inside output matrices--------------------%        

                    neg_mat(ind_time, ind_ANG, :) = neg;
                    zero_mat(ind_time, ind_ANG, :) = zero;
                    pos_mat(ind_time, ind_ANG, :) = pos;

                    sig_neg_mat(ind_time, ind_ANG, :) = sig_neg;
                    sig_zero_mat(ind_time, ind_ANG, :) = sig_zero;
                    sig_pos_mat(ind_time, ind_ANG, :) = sig_pos;
                end
            end
        end
    end
   

%----------------------extracting non-zero values-------------------------%            
    
    neg_mat = neg_mat(1:ind_time, :, :);
    zero_mat = zero_mat(1:ind_time, :, :);
    pos_mat = pos_mat(1:ind_time, :, :);
    
    sig_neg_mat = sig_neg_mat(1:ind_time, :, :);
    sig_zero_mat = sig_zero_mat(1:ind_time, :, :);
    sig_pos_mat = sig_pos_mat(1:ind_time, :, :);
    
    acc_neg_mat = acc_neg_mat(1:ind_time, :, :);
    acc_zero_mat = acc_zero_mat(1:ind_time, :, :);
    acc_pos_mat = acc_pos_mat(1:ind_time, :, :);
    
    Rs = Rs(2:end, :);
    FREQS = FREQS(2:end);
    dt = T_chirp * cell_size;
    t = 0 : dt : (ind_time-1)*dt;
    alphas = -ANG : 1 : ANG;

    day_map("neg_mat") = neg_mat;
    day_map("zero_mat") = zero_mat;
    day_map("pos_mat") = pos_mat;

    day_map("sig_neg_mat") = sig_neg_mat;
    day_map("sig_zero_mat") = sig_zero_mat;
    day_map("sig_pos_mat") = sig_pos_mat;
    
    day_map("acc_neg_mat") = acc_neg_mat;
    day_map("acc_zero_mat") = acc_zero_mat;
    day_map("acc_pos_mat") = acc_pos_mat;
    
    day_map("Rs") = Rs;
    day_map("t") = t;
    day_map("azimuth") = alphas;
    day_map("FREQS") = FREQS;

end