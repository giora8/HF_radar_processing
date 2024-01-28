function filtered_timeseries = filter_timeseries(config, dt, timeseries)
%% Inputs
% config - system and run configuration
% timeseries to filter using Fourier transform
%% Output
% filtered_timeseries - noised reduction timeseries using naive
% rectangular filter
% 
%%--------------------------apply fft-------------------------------------%

f = dt2baseband_frequency_axis(dt, length(timeseries));
P = fftshift(fft(timeseries-mean(timeseries)));

% remove noise using naive rectangular filter
f_upper = config.shear_calculation_configuration.f_upper;

noise_freq_indices_negative_part = find(f<=-f_upper);
noise_freq_indices_positive_part = find(f>=f_upper);
noise_freq_indices = [noise_freq_indices_negative_part noise_freq_indices_positive_part];

P(noise_freq_indices) = 0;

filtered_timeseries = ifft(ifftshift(P));

end

