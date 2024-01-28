function f = time2frequency_axis(t)
%% Inputs
% t - time axis [sec]
%% Output
% f - Fourier transform of the time axis   
    Fs = 1 / (t(2) - t(1)) ;
    L = length(t);
    f = Fs*(-L/2:L/2-1)/L;
end

