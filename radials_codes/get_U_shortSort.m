function [U_all, res, sig_metric, acc_metric, f_peaks_mat] = get_U_shortSort(filename, velocity_type, peak_detection_type)
    
    %% loading and initializing parameters
    
    g = 9.82; % [m\s]
    addpath(genpath('..\'));
    load(filename);
    
    lambda_bragg = g / (2 * pi * fbragg^2);
    Fs = 1 / (t(2) - t(1)) ; % Sampling frequency
    L = length(t);
    f = Fs*(-L/2:L/2-1)/L;
    freq_norm = f ./ fbragg;
    
    res = (f(2)-f(1)) * lambda_bragg;
    
    %% evaluation current for each 20 minute measurement
        
    U_all = zeros(size(P_shortSort, 1), 2);
    f_peaks_mat = zeros(size(P_shortSort, 1), 2);
    sig_metric = zeros(size(P_shortSort, 1), 2);
    acc_metric = zeros(size(P_shortSort, 1), 2);
    for ii = 1 : size(P_shortSort, 1)

        [f_peaks, sig, acc, f_ax, P_ax] = find_ivonin_peaks(P_shortSort(ii, :), [-1 1], freq_norm, 0, peak_detection_type);
        if strcmp(velocity_type, 'Cp')
            f_diff = f_peaks;
        else
            f_diff = [-1 1] - f_peaks;
        end
        f_diff = f_diff .* fbragg;

        U = lambda_bragg .* f_diff;
        
        U_all(ii, 1) = U(1);
        U_all(ii, 2) = U(2);
        
        sig_metric(ii, :) = sig .* fbragg .* lambda_bragg;
        acc_metric(ii, :) = acc .* fbragg .* lambda_bragg;
        
        f_peaks_mat(ii, :) = f_peaks;
        
        [~, id_neg_plot] = min((f_ax(1, :) - f_peaks_mat(ii, 1)).^2);
        [~, id_pos_plot] = min((f_ax(2, :) - f_peaks_mat(ii, 2)).^2);
        P_point1 = P_ax(1, id_neg_plot);
        P_point2 = P_ax(2, id_pos_plot);
        
%         fig=figure; fig.Position = [10 10 1000 500];
%         subplot(2, 4, [1 2 5 6]);
%         plot(f_ax(1, :), P_ax(1, :));
%         hold on; scatter(f_peaks(1, 1), P_point1, 'fill');
%         title(strcat(peak_detection_type, ' peak location: ' ,num2str(f_peaks(1, 1))));
%         xlabel('frequency [Hz]'); ylabel('Power [dB]');
%         
%         hold on; subplot(2, 4, [3 4 7 8]);
%         plot(f_ax(2, :), P_ax(2, :));
%         hold on; scatter(f_peaks(1, 2), P_point2, 'fill');
%         title(strcat(peak_detection_type, ' peak location: ' , num2str(f_peaks(1, 2))));
%         xlabel('frequency [Hz]'); ylabel('Power [dB]');
        
    end
    
    
end
