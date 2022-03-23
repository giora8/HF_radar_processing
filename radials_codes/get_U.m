function U_avg = get_U(filename, N_avg, running_mean, velocity_type, peak_detection_type)
    
    %% loading and initializing parameters
    
    g = 9.81; % [m\s]
    addpath(genpath('..\'));
    load(filename);
    
    %% standartizied - NOT INCLUDED %

%     max_vals = max(P_day, [], 2);
%     min_vals = min(P_day, [], 2);
% 
%     P_ang_norm = (P_day - min_vals) ./ (max_vals - min_vals);
%     P_day = P_ang_norm;
    
    %% evaluation current for each 20 minute measurement
        
    U_all = zeros(size(P_day, 1), 2);
    for ii = 1 : size(P_day, 1)
        
        f_bragg = fbragg_day(ii);
        lambda_bragg = g / (2 * pi * f_bragg^2);
        
        t = t_day(ii, :);
        Fs = 1 / (t(2) - t(1)) ; % Sampling frequency
        L = length(t);
        f = Fs*(-L/2:L/2-1)/L;
        freq_norm = f ./ f_bragg;
        
        [f_peaks, ~, ~] = find_ivonin_peaks(P_day(ii, :), [-1 1], freq_norm, 0, peak_detection_type);
        if strcmp(velocity_type, 'Cp')
            f_diff = f_peaks;
        else
            f_diff = f_peaks - [-1 1];
        end
        f_diff = f_diff .* f_bragg;

        U = lambda_bragg .* f_diff;
        
        U_all(ii, 1) = U(1);
        U_all(ii, 2) = U(2);

    end
    
    %% averaging every N_avg measurements
    
    N_full = floor(size(P_day, 1) / N_avg);
    N_rest = mod(size(P_day, 1), N_avg);
    
    U_avg = zeros(N_full, 2);
    counter = 1;
    for ii = 1 : N_avg : N_full*N_avg-1

        U_avg(counter, :) = mean(U_all(ii:ii+N_avg-1, :), 1);
        counter = counter + 1;

    end
    
    if ~isempty(P_day(end-N_rest+1:end, :))
        U_avg(end+1, :) = mean(U_all(end-N_rest+1:end, :), 1);
    end
    
    %%  Previous version - less accurate
    % standartizied - NOT INCLUDED %

    %max_vals = max(P_day, [], 2);
    %min_vals = min(P_day, [], 2);

    %P_ang_norm = (P_day - min_vals) ./ (max_vals - min_vals);
    %P_ang_norm = P_day;
    
    % averaging over consecutive measurements %
    
%     N_full = floor(size(P_ang_norm, 1) / N_avg);
%     N_rest = mod(size(P_ang_norm, 1), N_avg);
%     
%     P_avg = zeros(N_full, length(t));
%     counter = 1;
%     for ii = 1 : N_avg : N_full*N_avg-1
% 
%         P_avg(counter, :) = mean(P_ang_norm(ii:ii+N_avg-1, :), 1);
%         counter = counter + 1;
% 
%     end
%     
%     if ~isempty(P_ang_norm(end-N_rest+1:end, :))
%         P_avg(end+1, :) = mean(P_ang_norm(end-N_rest+1:end, :), 1);
%     end
%     
%     P_avg_movmean = movmean(P_avg, running_mean, 2);  % smoothing curve if running_mean>1
    
    %%

    %lamda_EM = 3e8 / 8.3e6 ;
    %lambda_bragg = lamda_EM / 2;

%     U_all = zeros(size(P_avg_movmean,1), 2);
%     for ii = 1 : size(P_avg_movmean, 1)
% 
%         [f_peaks, ~, ~] = find_ivonin_peaks(P_avg_movmean(ii, :), [-1 1], freq_norm, 0, peak_detection_type);
%         if strcmp(velocity_type, 'Cp')
%             f_diff = f_peaks;
%         else
%             f_diff = f_peaks - [-1 1];
%         end
%         f_diff = f_diff .* fbragg;
% 
%         U = lambda_bragg .* f_diff;
%         
%         U_all(ii, 1) = U(1);
%         U_all(ii, 2) = U(2);
% 
%     end

    
