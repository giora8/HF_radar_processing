function [U_avg, sig_avg, acc_avg] = get_U(filename, N_avg, running_mean, velocity_type, peak_detection_type)
    
    %% loading and initializing parameters
    
    g = 9.82; % [m\s]
    addpath(genpath('..\'));
    load(filename);
    
    %% standartizied - NOT INCLUDED %

%     max_vals = max(P_day, [], 2);
%     min_vals = min(P_day, [], 2);
% 
%     P_ang_norm = (P_day - min_vals) ./ (max_vals - min_vals);
%     P_day = P_ang_norm;
    
    %% evaluation current for each 20 minute measurement
        
    U_all = zeros(size(P_day, 1), 3);
    sig_metric = zeros(size(P_day, 1), 2);
    acc_metric = zeros(size(P_day, 1), 2);
    for ii = 1 : size(P_day, 1)

        f_bragg = fbragg_day(ii);
        lambda_bragg = g / (2 * pi * f_bragg^2);
        
        t = t_day(ii, :);
        Fs = 1 / (t(2) - t(1)) ; % Sampling frequency
        L = length(t);
        f = Fs*(-L/2:L/2-1)/L;
        freq_norm = f ./ f_bragg;
        
        res = (f(2)-f(1)) * lambda_bragg;
        
        [f_peaks, sig, acc, f_ax, P_ax] = find_ivonin_peaks(P_day(ii, :), [-1 1], freq_norm, 0, peak_detection_type);
        if strcmp(velocity_type, 'Cp')
            f_diff = f_peaks;
        else
            f_diff = f_peaks - [-1 1];
        end
        f_diff = f_diff .* f_bragg;

        U = lambda_bragg .* f_diff;
        
        U_all(ii, 1) = U(1);
        U_all(ii, 2) = U(2);
        U_all(ii, 3) = res;
        
        sig_metric(ii, :) = sig .* f_bragg .* lambda_bragg;
        acc_metric(ii, :) = acc .* f_bragg .* lambda_bragg;
        
        [~, id_neg_plot] = min((f_ax(1, :) - f_peaks(1, 1)).^2);
        [~, id_pos_plot] = min((f_ax(2, :) - f_peaks(1, 2)).^2);
        P_point1 = P_ax(1, id_neg_plot);
        P_point2 = P_ax(2, id_pos_plot);
        
%         if ii== 9
%             fig=figure; fig.Position = [10 10 1000 500];
%         else
%             hold on;
%         end
%         hold on;
%         subplot(2, 4, [1 2 5 6]);
%         plot(f_ax(1, :), P_ax(1, :)); col = get(gca, 'ColorOrder'); col_id = get(gca, 'ColorOrderIndex')-1;
%         hold on; scatter(f_peaks(1, 1), P_point1, [], col(col_id, :), 'fill'); hold on; xline(-1, 'k--');
%         title(strcat(peak_detection_type, ' peak location: ' ,num2str(f_peaks(1, 1))));
%         xlabel('frequency [f_B]'); ylabel('Power [dB]');
%         
%         hold on; subplot(2, 4, [3 4 7 8]);
%         plot(f_ax(2, :), P_ax(2, :)); col = get(gca, 'ColorOrder'); col_id = get(gca, 'ColorOrderIndex')-1;
%         hold on; scatter(f_peaks(1, 2), P_point2, [], col(col_id, :), 'fill'); xline(1, 'k--');
%         title(strcat(peak_detection_type, ' peak location: ' , num2str(f_peaks(1, 2))));
%         xlabel('frequency [f_B]'); ylabel('Power [dB]');

    end
    
    %% averaging every N_avg measurements
    
    N_full = floor(size(P_day, 1) / N_avg);
    N_rest = mod(size(P_day, 1), N_avg);
    
    if N_full ~= size(P_day, 1)
    
        U_avg = zeros(N_full, 3);
        sig_avg = zeros(N_full, 2);
        acc_avg = zeros(N_full, 2);
        counter = 1;
        for ii = 1 : N_avg : N_full*N_avg-1

            U_avg(counter, :) = mean(U_all(ii:ii+N_avg-1, :), 1);
            sig_avg(counter, :) = mean(sig_metric(ii:ii+N_avg-1, :), 1);
            acc_avg(counter, :) = mean(acc_metric(ii:ii+N_avg-1, :), 1);
            counter = counter + 1;

        end

        if ~isempty(P_day(end-N_rest+1:end, :))
            U_avg(end+1, :) = mean(U_all(end-N_rest+1:end, :), 1);
            sig_avg(end+1, :) = mean(sig_metric(end-N_rest+1:end, :), 1);
            acc_avg(end+1, :) = mean(acc_metric(end-N_rest+1:end, :), 1);
        end
        
    else
        U_avg = U_all;
        sig_avg = sig_metric;
        acc_avg = acc_metric;
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

    
