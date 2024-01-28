function day_map = get_phase_velocity_and_noise(config, fname)
%% Inputs
% config - system and run configuration
% fname - mat file to load from data extraction piepeline
%% Output
% day_map - container map including c1 and c2 from two Bragg peaks,
% resolution and noie estimation and the unperturbed phase velocity
% 
%%--------------------initializing parameters-----------------------------%
load(fname); %#ok<LOAD> % including: P_day, f_bragg_day, f0_day, t_day

c_unperturbed = zeros(size(P_day, 1), 1);  %#ok<NODEF>
c_negative_peak = zeros(size(P_day, 1), 1);
c_positive_peak = zeros(size(P_day, 1), 1);
velocity_resolution = zeros(size(P_day, 1), 1);
sig_metric= zeros(size(P_day, 1), 2);
acc_metric= zeros(size(P_day, 1), 2);

peak_detection_type = config.shear_calculation_configuration.peak_detection_method;
NFFT = size(P_day, 2);
window_size = NFFT / config.shear_calculation_configuration.window_size_factor;

%% evaluating c1, c2 and accuracy for each 20-minutes measurements

    for ii = 1 : size(P_day, 1)

        cur_f0 = f0_day(ii);
        cur_t = t_day(ii, :);  %#ok<NODEF>
        f = time2freqency_axis(cur_t);

        [f_peaks, sig, acc, ~, ~] = find_first_order_peaks(P_day(ii, :), [-f_bragg f_bragg], f, 0, peak_detection_type, window_size);

        fb_neg = f_peaks(1) + f0;
        fb_pos = f_peaks(2) + f0;
        fb_unperturbed = f_bragg + f0;
        
        % conver frequency to velocity according to Doppler formula
        c_negative_peak(ii) = Ce * (cur_f0 - fb_neg) / (f0+fb_neg);
        c_positive_peak(ii) = Ce * (cur_f0 - fb_pos) / (f0+fb_pos);
        c_unperturbed(ii) = -Ce * (f0 - fb_unperturbed) / (f0+fb_unperturbed);
        velocity_resolution(ii) = Ce.*(f(2)-f(1))./(2*cur_f0 + (f(2)-f(1)));

        % evaluating variance and accuracy
        sig_metric(ii, :) = Ce.*sqrt(sig)./(2*cur_f0 + sqrt(sig));
        acc_metric(ii, :) = Ce.*acc./(2*cur_f0 + acc);
    
    end
   day_map = containers.Map;
   day_map('c_negative_peak') = c_negative_peak;
   day_map('c_positive_peak') = c_positive_peak;
   day_map('c_unperturbed') = c_unperturbed;
   day_map('velocity_resolution') = velocity_resolution;
   day_map('variance') = sig_metric;
   day_map('accuracy') = acc_metric;
end

