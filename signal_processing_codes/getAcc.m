%% getAcc.m
function [sig, acc] = getAcc(freq, snr, Vr_wera)
%% Inputs
% freq - normalized frequency axis of a window around highest peak
% snr - signal to noise ratio [dB]
% Vr_wera - centroid frequency wieghted using the snr
%% Output
% sig: variance of the radial velocity
% acc: accuracy measure for the radial velocity
%
    K = length(freq);
    snr_lin = db2pow(snr);
    
    Vr_wera = mean(Vr_wera.^2);
    sum_snr = sum(snr_lin);
    
    cumSig = 0;
    for ii =1 : K
        cumSig = cumSig + freq(ii).^2 * snr_lin(ii);  
    end
    
    sig = cumSig / sum_snr - Vr_wera;
    acc = sqrt(sig/K);

end

