function f = dt2baseband_frequency_axis(dt, N)
%% Inputs
% dt - time resolution [sec]
% N - number of measurements
%% Output
% f - baseband frequency axis

Nyquist = 1 / (2*dt);
df = 1 / (N*dt);
f = -Nyquist : df : Nyquist - df;

end