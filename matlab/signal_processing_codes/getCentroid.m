%% getCentroid.m
function f_peak = getCentroid(f, P)
    
    P = P - min(P);
    denominator = trapz(f, P);
    numerator = trapz(f, f.*P);
%     mult_sum = 0 ;
%     for ii = 1 : length(f)
%         cur_mult = f(ii) .* P(ii) .* (f(2)-f(1));
%         mult_sum = mult_sum + cur_mult ;
%     end
    
    f_peak = numerator / denominator;   
    
end