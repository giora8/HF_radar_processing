%% get_U_shortSort.m
function [U_all, res, sig_metric, acc_metric, c0_bragg] = get_U_shortSort(filename, velocity_type, peak_detection_type, varargin)
%% Inputs
% filename - .mat file of the relevant measurement extracted by
% "create_P_day.m"
% velocity_type - 'Cp' to detect absolute velocity from the Doppler, else
% is the difference between Cp0 assuming first order solution
% peak_detection_type - usually centroid method, 'max' or 'WERA' also
% possible
% varargin - optional additional parameter to choose window around the peak
% for detection
%% Output
% U_all - matrix of velocity for every time step for each peak
% res - matrix storing resolution values for each time step
% sig_avg - matrix of variance of the velocity for every time step for each peak
% acc_avg - matrix of accuracy of the velocity for every time step for each peak
% c0_bragg - matrix of undisturbed phase velocity of the bragg wave for
% each velocity
% 
%--------------loading and initializing parameters------------------------%
        
    g = 9.82; % [m\s]
    addpath(genpath('..\'));
    load(filename); %#ok<LOAD>
    
    lambda_bragg = g / (2 * pi * fbragg^2);
    Fs = 1 / (t(2) - t(1)) ; % Sampling frequency
    L = length(t);
    f = Fs*(-L/2:L/2-1)/L;
    freq_norm = f ./ fbragg;
    
    res = (f(2)-f(1)) * lambda_bragg;
    
%--------evaluation current for each 20 minute measurement----------------%
    
    c0_bragg = zeros(size(P_shortSort, 1), 1); %#ok<NODEF>
    U_all = zeros(size(P_shortSort, 1), 2);
    sig_metric = zeros(size(P_shortSort, 1), 2);
    acc_metric = zeros(size(P_shortSort, 1), 2);
    for ii = 1 : size(P_shortSort, 1)

        if strcmp(velocity_type, 'Cp')
            Ce = 3 * 10^8;
            
            if isempty(varargin)
                [f_peaks, sig, acc, ~, ~] = find_ivonin_peaks(P_shortSort(ii, :), [-fbragg fbragg], f, 0, peak_detection_type);
            else
                window = varargin{1};
                [f_peaks, sig, acc, ~, ~] = find_ivonin_peaks(P_shortSort(ii, :), [-fbragg fbragg], f, 0, peak_detection_type, window);
            end
            
            fb_neg = f_peaks(1) + f0;
            fb_pos = f_peaks(2) + f0;
            U(1) = Ce * (f0 - fb_neg) / (f0+fb_neg);
            U(2) = -Ce * (f0 - fb_pos) / (f0+fb_pos);
            res = Ce.*(f(2)-f(1))./(2*f0 + (f(2)-f(1)));
                    
        else
            
            if isempty(varargin)
                [f_peaks, sig, acc, ~, ~] = find_ivonin_peaks(P_shortSort(ii, :), [-1 1], freq_norm, 0, peak_detection_type);
            else
                window = varargin{1};
                [f_peaks, sig, acc, ~, ~] = find_ivonin_peaks(P_shortSort(ii, :), [-1 1], freq_norm, 0, peak_detection_type, window);
            end
            
            f_diff = [-1, 1] - f_peaks;
            f_diff = f_diff .* fbragg;
            U = lambda_bragg .* f_diff;
            res = (f(2)-f(1)) * lambda_bragg;
            
        end
        
        c0_bragg(ii) = sqrt((lambda_bragg*g)/(2*pi));
        U_all(ii, 1) = U(1);
        U_all(ii, 2) = U(2);
        U_all(ii, 3) = res;
        
        if strcmp(velocity_type, 'Cp')
            sig_metric(ii, :) = Ce.*sqrt(sig)./(2*f0 + sqrt(sig));
            acc_metric(ii, :) = Ce.*acc./(2*f0 + acc);
        else
            sig_metric(ii, :) = sig .* fbragg .* lambda_bragg;
            acc_metric(ii, :) = acc .* fbragg .* lambda_bragg;
        end
    end  
end
