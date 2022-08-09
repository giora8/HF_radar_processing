%% getWERACurrent.m
function [f, snr] = getWERACurrent(freq_window, P_window, noise)
%% Inputs
% freq_window - normalized frequency axis of a window around highest peak
% P_window - power of a window around highest peak [dB]
% noise - average noise value [dB]
%% Output
% f: centroid frequency weighted by the snr
% snr: signal to noise ratio [dB]
%
    % convert variables to linear
    
    noise_lin = db2pow(noise);
    P_lin = db2pow(P_window);
    
    % evaluate snr vector
    
    snr = P_lin / noise_lin;
    sum_snr = sum(snr);
    
    % calculate weighted main frequency
    
    cumVr = 0;
    for ii = 1 : length(freq_window)
       
        cumVr = cumVr + freq_window(ii) * snr(ii);

    end
    
    snr = pow2db(snr);
    f = cumVr / sum_snr;
    
end

