%% get_noise_value.m
function noise = get_noise_value(P)
%% Inputs
% P - backscattered Doppler spectra of size 1 X NFFT [dB]
%% Output
% noise: noise level evaluated between first order peaks to zeroth peak
% [dB]
%
    
    % extract noise windows from spectrum
    
    NFFT = length(P);
%     P_left = P(NFFT/2-50-200:NFFT/2-50);
%     P_right = P(NFFT/2+50:NFFT/2+50+200);
    
    P_left = P(1:NFFT/4);
    P_right = P(NFFT-NFFT/4:end);
    
    %P_left = P(NFFT/2-50-100:NFFT/2-50);
    %P_right = P(NFFT/2+50:NFFT/2+50+100);
    
    % averaging over the linear magnitude
    
    P_left_mag = db2pow(P_left);
    P_right_mag = db2pow(P_right);
    P_noise_mag = [P_left_mag P_right_mag];
    noise_mag = mean(P_noise_mag);
    
    % convert back to dB
    
    noise = pow2db(noise_mag);

end

