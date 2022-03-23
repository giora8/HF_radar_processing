%% Calculate current values when averaging (average_every=3 e.c. 00:00-01:00, 01:00-02:00 etc.)
average_every = 3;
H = 72 / average_every;
dt = 24 / H ;
basic_path = 'Z:\radials_spectrum\is1_R_3.5622_ang_-3_5\';
files = dir(basic_path);
%files = files(12);
%files = files(3:23);
%files = files(25:26);
%files = files(24:34);
files = files(24:35);
%files = files(36);
%files = files(13:23);
U_all = -10.*ones(H*length(files), 2);  % [negative_peak, positive_peak]
for cur_day = 1 : length(files)

    id_zero = find(U_all == -10);
    id_zero = id_zero(1);
    
    cur_filename = strcat(basic_path, files(cur_day).name);
    cur_U_all = get_U(cur_filename, average_every, 1, '', 'centroid');
    
    U_all(id_zero:id_zero+size(cur_U_all, 1)-1, 1) = cur_U_all(:, 1);
    U_all(id_zero:id_zero+size(cur_U_all, 1)-1, 2) = cur_U_all(:, 2);
    
end

%% plot results

U_all(abs(U_all)>2) = mean(U_all(:));
U_all(isnan(U_all)) = nanmean(U_all(:));
x_plot = 1:length(U_all);
x_plot = x_plot .* dt;
ylim_val = ceil(max(abs(max(U_all(:, 1))), abs(min(U_all(:,1)))));

%%

fig=figure; fig.Position = [10 10 1100 450];
hold on; scatter(x_plot, U_all(:, 2));
hold on;
scatter(x_plot, U_all(:, 1), 'x');
hold on;
ylim([-ylim_val/2, ylim_val/2]);
xline(max(x_plot)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:average_every:max(x_plot) max(x_plot)];
xlabel('Time [hr]'); ylabel('Velocity [m/s]');
legend('Positive peak', 'Negative peak', 'box', 'off');
xlim([1 max(x_plot)]);

%% fft

Fs = 1/dt;
L = H*length(files);

Y_pos = fft(U_all(:, 2));
Y_neg = fft(U_all(:, 1));

P2_pos = abs(Y_pos/L);
P1_pos = P2_pos(1:L/2+1);
P1_pos(2:end-1) = 2*P1_pos(2:end-1);

P2_neg = abs(Y_neg/L);
P2_neg = P2_neg(1:L/2+1);
P2_neg(2:end-1) = 2*P2_neg(2:end-1);

f = Fs*(0:(L/2))/L;
figure(); plot(f,P1_pos) ;
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]'); title('Positive peak');
figure(); plot(f,P2_neg) ;
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]'); title('Negative peak');

%% NEW METHOD - shift zero frequency to center, than ifft is possible

U_pos = U_all(:, 2);
U_neg = U_all(:, 1);
N = length(U_pos);

Nyquist = 1 / (2*dt);
df = 1 / (N*dt);
f = -Nyquist : df : Nyquist - df;

P1_pos = fftshift(fft(U_pos));
P1_neg = fftshift(fft(U_neg));

close all;
%% defining frequencies ranges

f_upper = 0.15; % above this value its just noise
f_tides = 0.035417;  % between this and f_upper is the tidal region

noise_freq_indices1 = find(f<=-f_upper);
noise_freq_indices2 = find(f>=f_upper);
noise_freq_indices = [noise_freq_indices1 noise_freq_indices2];

tide_freq_indices1 = find(f<=-f_tides & f>-f_upper);
tide_freq_indices2 = find(f>=f_tides & f<f_upper);
tide_freq_indices = [tide_freq_indices1 tide_freq_indices2];

low_freq_indices = find(abs(f)<=f_tides);

noise_tides_indices = [noise_freq_indices tide_freq_indices];
low_tides_indices = [low_freq_indices tide_freq_indices];
%% filtering out low frequencies
figure(); plot(f, abs(P1_pos));

P1_pos_noise_red = P1_pos;
P1_pos_noise_red(low_tides_indices) = 0;
figure(); plot(f, abs(P1_pos_noise_red));
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');
title('Positive peak');

P1_neg_noise_red = P1_neg;
P1_neg_noise_red(low_tides_indices) = 0;
figure(); plot(f, abs(P1_neg_noise_red));
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');
title('Negative peak');

U_pos_filt = ifft(ifftshift(P1_pos_noise_red));
U_neg_filt = ifft(ifftshift(P1_neg_noise_red));

figure(); scatter(x_plot, U_pos_filt)
hold on; scatter(x_plot, U_neg_filt, 'x');
hold on;
ylim([-ylim_val/2, ylim_val/2]);
xline(24*length(files)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:3:24*length(files) 24*length(files)];
xlabel('Time [hr]'); ylabel('Velocity [m/s]');
legend('Positive peak', 'Negative peak', 'box', 'off');
xlim([1 24*length(files)]);
%% noise reduction by filtering higher frequencies
figure(); plot(f, abs(P1_pos));

P1_pos_noise_red = P1_pos;
P1_pos_noise_red(noise_freq_indices) = 0;
figure(); plot(f, abs(P1_pos_noise_red));
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');
title('Positive peak');

P1_neg_noise_red = P1_neg;
P1_neg_noise_red(noise_freq_indices) = 0;
figure(); plot(f, abs(P1_neg_noise_red));
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');
title('Negative peak');

U_pos_filt = ifft(ifftshift(P1_pos_noise_red));
U_neg_filt = ifft(ifftshift(P1_neg_noise_red));

fig=figure; fig.Position = [10 10 1100 450];
scatter(x_plot, U_pos_filt)
hold on; scatter(x_plot, U_neg_filt, 'x');
hold on;
ylim([-ylim_val/2, ylim_val/2]);
xline(24*length(files)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:3:24*length(files) 24*length(files)];
xlabel('Time [hr]'); ylabel('Velocity [m/s]');
legend('Positive peak', 'Negative peak', 'box', 'off');
xlim([1 24*length(files)]);
U_all_filt = [U_neg_filt U_pos_filt];
%% Filter the very low frequency

P1_pos_low_red = P1_pos_noise_red;
P1_pos_low_red(low_freq_indices) = 0;
figure(); plot(f, abs(P1_pos_low_red));
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');
title('Positive peak');

P1_neg_low_red = P1_neg_noise_red;
P1_neg_low_red(low_freq_indices) = 0;
figure(); plot(f, abs(P1_neg_low_red));
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');
title('Negative peak');

U_pos_filt = ifft(ifftshift(P1_pos_low_red));
U_neg_filt = ifft(ifftshift(P1_neg_low_red));

figure(); scatter(x_plot, U_pos_filt)
hold on; scatter(x_plot, U_neg_filt, 'x');
hold on;
ylim([-ylim_val/2, ylim_val/2]);
xline(24*length(files)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:3:24*length(files) 24*length(files)];
xlabel('Time [hr]'); ylabel('Velocity [m/s]');
legend('Positive peak', 'Negative peak', 'box', 'off');
xlim([1 24*length(files)]);
%% Filter tides & noise frequency

P1_pos_tide_red = P1_pos_noise_red;
P1_pos_tide_red(noise_tides_indices) = 0;
figure(); plot(f, abs(P1_pos_tide_red));
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');
title('Positive peak');

P1_neg_tide_red = P1_neg_noise_red;
P1_neg_tide_red(noise_tides_indices) = 0;
figure(); plot(f, abs(P1_neg_tide_red));
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');
title('Negative peak');

U_pos_filt = ifft(ifftshift(P1_pos_tide_red));
U_neg_filt = ifft(ifftshift(P1_neg_tide_red));

err = 0.013.*ones(1, length(x_plot));
fig=figure; fig.Position = [10 10 1100 450];
scatter(x_plot, U_pos_filt); hold on;
errorbar(x_plot, U_pos_filt, err, 'LineStyle','none', 'Color', 'blue');
hold on; scatter(x_plot, U_neg_filt, 'x');
errorbar(x_plot, U_neg_filt, err, 'LineStyle','none', 'Color', 'red');
hold on;
ylim([-ylim_val/2, ylim_val/2]);
xline(24*length(files)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:3:24*length(files) 24*length(files)];
xlabel('Time [hr]'); ylabel('Velocity [m/s]');
legend('Positive peak', 'Negative peak', 'box', 'off');
xlim([1 24*length(files)]);
%% saving U's to plot against model prediction in a different script
U_all_tide_filt = [U_neg_filt U_pos_filt];
U_all_raw = U_all;
save('C:\Giora\TAU\MEPlab\HF_Radar\files\ECMWF_model\U_current_2020_116_137.mat','U_all_raw', 'U_all_filt','U_all_tide_filt', 'x_plot')

%% Fourier analysis on the difference between velocities
U_diff = U_all(:, 2)-U_all(:, 1);
figure(); scatter(x_plot, U_diff);
ylim([-ylim_val/2, ylim_val/2]);
xline(24*length(files)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:3:24*length(files) 24*length(files)];
xlabel('Time [hr]'); ylabel('Velocity [m/s]');
legend('U_{neg}-U_{pos}', 'box', 'off');
xlim([1 24*length(files)]);
P1_diff = fftshift(fft(U_diff));
figure(); plot(f, abs(P1_diff));
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');

%% reducing noise
figure(); plot(f, abs(P1_diff));

P1_noise_red = P1_diff;
P1_noise_red(noise_freq_indices) = 0;
figure(); plot(f, abs(P1_noise_red));
xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');
title('U_{neg}-U_{pos}');

U_diff_filt = ifft(ifftshift(P1_noise_red));

figure(); scatter(x_plot, U_diff_filt)
hold on;
ylim([-ylim_val/2, ylim_val/2]);
xline(24*length(files)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:3:24*length(files) 24*length(files)];
xlabel('Time [hr]'); ylabel('Velocity [m/s]');
legend('U_{neg}-U_{pos}', 'box', 'off');
xlim([1 24*length(files)]);
