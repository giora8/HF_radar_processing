%% get_U.m
function [U_avg, sig_avg, acc_avg, c0_bragg_avg] = get_U(filename, N_avg, velocity_type, peak_detection_type, varargin) 
%% Inputs
% filename - .mat file of the relevant measurement extracted by
% "create_P_day.m"
% N_avg - (int) averaging meeasurment every N_avg (1 for no averaging)
% velocity_type - 'Cp' to detect absolute velocity from the Doppler, else
% is the difference between Cp0 assuming first order solution
% peak_detection_type - usually centroid method, 'max' or 'WERA' also
% possible
% varargin - optional additional parameter to choose window around the peak
% for detection
%% Output
% U_avg - matrix of velocity for every time step for each peak
% sig_avg - matrix of variance of the velocity for every time step for each peak
% acc_avg - matrix of accuracy of the velocity for every time step for each peak
% c0_bragg_avg - matrix of undisturbed phase velocity of the bragg wave for
% each velocity
% 
%--------------loading and initializing parameters------------------------%
    
    g = 9.82; % [m\s]
    addpath(genpath('..\'));
    load(filename); %#ok<LOAD> % including: P_day, f_bragg_day, f0_day, t_day
    
%% evaluation current for each 20 minute measurement
    
    c0_bragg = zeros(size(P_day, 1), 1); %#ok<NODEF>
    U_all = zeros(size(P_day, 1), 3);
    sig_metric = zeros(size(P_day, 1), 2);
    acc_metric = zeros(size(P_day, 1), 2);
    
    for ii = 1 : size(P_day, 1)

        f_bragg = fbragg_day(ii);
        f0 = f0_day(ii);
        lambda_bragg = g / (2 * pi * f_bragg^2);
        
        t = t_day(ii, :); %#ok<NODEF>
        Fs = 1 / (t(2) - t(1)) ;
        L = length(t);
        f = Fs*(-L/2:L/2-1)/L;
        freq_norm = f ./ f_bragg;

        if strcmp(velocity_type, 'Cp')
            Ce = 3 * 10^8;
            
            if isempty(varargin)
                [f_peaks, sig, acc, ~, ~] = find_ivonin_peaks(P_day(ii, :), [-f_bragg f_bragg], f, 0, peak_detection_type);
            else
                window = varargin{1};
                [f_peaks, sig, acc, ~, ~] = find_ivonin_peaks(P_day(ii, :), [-f_bragg f_bragg], f, 0, peak_detection_type, window);
            end
            
            fb_neg = f_peaks(1) + f0;
            fb_pos = f_peaks(2) + f0;
            U(1) = Ce * (f0 - fb_neg) / (f0+fb_neg);
            U(2) = -Ce * (f0 - fb_pos) / (f0+fb_pos);
            res = Ce.*(f(2)-f(1))./(2*f0 + (f(2)-f(1)));
                    
        else
            
            if isempty(varargin)
                [f_peaks, sig, acc, ~, ~] = find_ivonin_peaks(P_day(ii, :), [-1 1], freq_norm, 0, peak_detection_type);
            else
                window = varargin{1};
                [f_peaks, sig, acc, ~, ~] = find_ivonin_peaks(P_day(ii, :), [-1 1], freq_norm, 0, peak_detection_type, window);
            end
            
            f_diff = [-1, 1] - f_peaks;
            f_diff = f_diff .* f_bragg;
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
            sig_metric(ii, :) = sig .* f_bragg .* lambda_bragg;
            acc_metric(ii, :) = acc .* f_bragg .* lambda_bragg;
        end

    end
    
%% averaging every N_avg measurements
    
    N_full = floor(size(P_day, 1) / N_avg);
    N_rest = mod(size(P_day, 1), N_avg);
    
    if N_full ~= size(P_day, 1)
        
        c0_bragg_avg = zeros(N_full, 1);
        U_avg = zeros(N_full, 3);
        sig_avg = zeros(N_full, 2);
        acc_avg = zeros(N_full, 2);
        counter = 1;
        for ii = 1 : N_avg : N_full*N_avg-1
            
            c0_bragg_avg(counter) = mean(c0_bragg(ii:ii+N_avg-1, :));
            U_avg(counter, :) = mean(U_all(ii:ii+N_avg-1, :), 1);
            sig_avg(counter, :) = mean(sig_metric(ii:ii+N_avg-1, :), 1);
            acc_avg(counter, :) = mean(acc_metric(ii:ii+N_avg-1, :), 1);
            counter = counter + 1;

        end

        if ~isempty(P_day(end-N_rest+1:end, :))
            c0_bragg_avg(end+1) = mean(c0_bragg_avg(end-N_rest+1:end));
            U_avg(end+1, :) = mean(U_all(end-N_rest+1:end, :), 1);
            sig_avg(end+1, :) = mean(sig_metric(end-N_rest+1:end, :), 1);
            acc_avg(end+1, :) = mean(acc_metric(end-N_rest+1:end, :), 1);
        end
        
    else
        c0_bragg_avg = c0_bragg;
        U_avg = U_all;
        sig_avg = sig_metric;
        acc_avg = acc_metric;
    end