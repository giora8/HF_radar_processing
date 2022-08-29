function [neg, zero, pos, sig_neg, sig_zero, sig_pos] = extract_peaks_locs_for_internal_waves(P, f)
    
    neg = zeros(size(P, 1), 1);
    zero = zeros(size(P, 1), 1);
    pos = zeros(size(P, 1), 1);
    
    sig_neg = zeros(size(P, 1), 1);
    sig_zero = zeros(size(P, 1), 1);
    sig_pos = zeros(size(P, 1), 1);
    
    for pp = 1 : size(P, 1)
       
        cur_spec = P(pp, :);
        [f_peaks, sig, ~, ~, ~] = find_ivonin_peaks(cur_spec, [-0.29 0.29], f, 0, 'centroid');
        [f_peaks_zero, sig_zero, ~, ~, ~] = find_ivonin_peaks(cur_spec, [0 0], f, 0, 'centroid');
        
        neg(pp) = f_peaks(1);
        zero(pp) = f_peaks_zero(1);
        pos(pp) = f_peaks(2);
        
        sig_neg(pp) = sig(1);
        sig_zero(pp) = sig_zero(1);
        sig_pos(pp) = sig(2);
        
    end
    
    
end

