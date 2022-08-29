function f = create_frequency_axis(t)
        
    Fs = 1 / (t(2) - t(1));
    L = length(t);
    f = Fs*(-L/2:L/2-1)/L;
   
end

