%%
addpath(genpath('C:\Giora\TAU\MEPlab\HF_Radar\Codes\Matlab'));

%% loading and extracting model results

load('C:\Giora\TAU\MEPlab\HF_Radar\files\ECMWF_model\UV_wind_2020_116_137.mat');

ADCP_deep = [34.512833 31.681639]; %  ADCP1 (lon, lat)
model_points = [ones(length(lon), 1)*lon(1) lat' ; ones(length(lon), 1)*lon(2) lat';...
                ones(length(lon), 1)*lon(3) lat';ones(length(lon), 1)*lon(4) lat';...
                ones(length(lon), 1)*lon(5) lat']; % (lon, lat)

%% plot the measuremnt points

coast_station_plot;
points_of_interest_plot(model_points);
points_of_interest_plot(ADCP_deep, 'r');

%% extracting some of the points/ averaging

indices = [2, 3];
u_point = u_wind(:, indices(1), indices(2));
v_point = v_wind(:, indices(1), indices(2));

%u_point = mean(u_wind(:, 2:3, 2:3), [2 3]);
%v_point = mean(v_wind(:, 2:3, 2:3), [2 3]);

%% projection to the radial

r_hat_angle = deg2rad(330);  % angle of radial vector in comparison to x axis (and not north!)
angle_velocity = atan2(v_point, u_point);
%figure(); plot(rad2deg(angle_velocity));
V = sqrt(u_point.^2 + v_point.^2);
relative_angle = -angle_velocity + r_hat_angle;
R = abs(cos(relative_angle));
V_proj = V .* cos(relative_angle);

%% clean wind from noise

dt = 1 ;
N = length(V);

Nyquist = 1 / (2*dt);
df = 1 / (N*dt);
f = -Nyquist : df : Nyquist - df;

V_freq = fftshift(fft(V));
V_proj_freq = fftshift(fft(V_proj));

f_noise = 0.12;
ind_noise_pos = find( f >= f_noise);
ind_noise_pos = ind_noise_pos(1);
ind_noise_neg = find( f <= -f_noise);
ind_noise_neg = ind_noise_neg(end);

V_freq(1 : ind_noise_neg) = 0;
V_freq(ind_noise_pos : end) = 0;

V_proj_freq(1 : ind_noise_neg) = 0;
V_proj_freq(ind_noise_pos : end) = 0;

V = ifft(ifftshift(V_freq));
V_proj = ifft(ifftshift(V_proj_freq));
%% compare with current HF measurement

load('C:\Giora\TAU\MEPlab\HF_Radar\files\ECMWF_model\U_current_2020_116_137.mat');
U_diff = U_all_tide_filt(:, 2) - U_all_tide_filt(:, 1);
figure();

yyaxis right
plot(x_plot, U_diff);
xlabel('Time [hr]'); ylabel('Current Velocity diff [m/s]');

yyaxis left
%plot(R);
plot(x_plot, V, 'k--');
hold on;
plot(x_plot, V_proj, 'b--');
xlabel('Time [hr]'); ylabel('Wind Velocity [m/s]');
xlim([1 length(u_wind)]);

legend('V', 'V_{proj}', 'U_{neg}-U_{pos}', 'box', 'off');

%% compare with current magnitude from HF measurement

load('C:\Giora\TAU\MEPlab\HF_Radar\files\ECMWF_model\U_current_2020_116_137.mat');
U_mag = abs(U_all_tide_filt(:, 2));
figure();

yyaxis right
plot(x_plot, U_mag);
xlabel('Time [hr]'); ylabel('Current Velocity diff [m/s]');

yyaxis left
%plot(R);
plot(x_plot, V, 'k--');
hold on;
plot(x_plot, V_proj, 'b--');
xlabel('Time [hr]'); ylabel('Wind Velocity [m/s]');
xlim([1 length(u_wind)]);

legend('V', 'V_{proj}', '|U|', 'box', 'off');
title('positive peak');

%% cross correlation calculation

[c, lags] = xcorr(V, U_diff, 'normalized', 50);
figure(); stem(lags, c);

[c, lags] = xcorr(V_proj, U_diff, 'normalized', 50);
figure(); stem(lags, c);

[c, lags] = xcorr(V_proj, U_mag, 'normalized', 15);
figure(); stem(lags, c);
title('positive peak');

[R, P] = corrcoef([V_proj(3:end); 0; 0; 0], [U_mag(1:end-2); 0 ; 0 ; 0])