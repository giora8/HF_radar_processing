%% extract_peaks_locs_for_internal_waves.m
function [neg, zero, pos, sig_neg, sig_zero, sig_pos, acc_neg, acc_zero, acc_pos] = extract_peaks_locs_for_internal_waves(P, f)
%% Inputs
% P - power spectrum [dB] of full short sort file [R X freq]
% f - frequency axis [Hz] of the short sort file [ 1 X freq]
%% Output
% neg - negative peak values for each time step, angle and radial
% [1 X R]
% zero - zeroth peak values for each time step, angle and radial
% [1 X R]
% pos - positive peak values for each time step, angle and radial
% [1 X R]
% sig and acc files - positive, negative and zeroth estimation variance and
% accuracy [1 X R]
%
% -----------------initialize path and parameters-------------------------%    
    neg = zeros(size(P, 1), 1);
    zero = zeros(size(P, 1), 1);
    pos = zeros(size(P, 1), 1);
    
    sig_neg = zeros(size(P, 1), 1);
    sig_zero = zeros(size(P, 1), 1);
    sig_pos = zeros(size(P, 1), 1);
    
    acc_neg = zeros(size(P, 1), 1);
    acc_zero = zeros(size(P, 1), 1);
    acc_pos = zeros(size(P, 1), 1);
    
    for pp = 1 : size(P, 1)
       
        cur_spec = P(pp, :);
        [f_peaks, sig, acc, ~, ~] = find_first_order_peaks(cur_spec, [-0.29 0.29], f, 'centroid');
        [f_peaks_zero, sig_zero, acc_zero, ~, ~] = find_first_order_peaks(cur_spec, [0 0], f, 'centroid');
        
        neg(pp) = f_peaks(1);
        zero(pp) = f_peaks_zero(1);
        pos(pp) = f_peaks(2);
        
        sig_neg(pp) = sig(1);
        sig_zero(pp) = sig_zero(1);
        sig_pos(pp) = sig(2);
        
        acc_neg(pp) = acc(1);
        acc_zero(pp) = acc_zero(1);
        acc_pos(pp) = acc(2);
        
    end
    
    
end

