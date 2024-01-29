%% Calculate velocity values with optional averaging (average_every=3 e.c. 00:00-01:00, 01:00-02:00 etc.)

%basic_path = 'Z:\radials_spectrum\is1_R_3.5622_Ncells_1_ang_-3_5\';
basic_path = 'C:\Giora\TAU\MEPlab\HF_Radar\files\is1_R_3.5622_Ncells_1_ang_-3_5\';

average_every = 3;
H = 72 / average_every;
dt = 24 / H ;

files = dir(basic_path);
%files = files(24:34);
files = files(24:48);

c0_all = -10.*ones(H*length(files), 3);
U_all = -10.*ones(H*length(files), 3); % [negative_peak, positive_peak, resolution]
eval_metric_all = -10.*ones(H*length(files), 4); % [sigma squared neg, sigma squared pos, acc neg, acc pos]
scale_c0 = -10.*ones(H*length(files), 3);
for cur_day = 1 : length(files)

    id_zero = find(U_all == -10);
    id_zero = id_zero(1);
    
    cur_filename = strcat(basic_path, files(cur_day).name);
    [cur_U_all, sig_metric, acc_metric, cur_c0] = get_U(cur_filename, average_every, 'Cp', 'centroid', 0.05);
    
    c0_all(id_zero:id_zero+size(cur_U_all, 1)-1) = cur_c0;
    U_all(id_zero:id_zero+size(cur_U_all, 1)-1, 1) = cur_U_all(:, 1);
    U_all(id_zero:id_zero+size(cur_U_all, 1)-1, 2) = cur_U_all(:, 2);
    U_all(id_zero:id_zero+size(cur_U_all, 1)-1, 3) = cur_U_all(:, 3);
    
    scale_c0(id_zero:id_zero+size(cur_U_all, 1)-1, 1:2) = cur_U_all(:, 1:2) ./ cur_c0;
    
    eval_metric_all(id_zero:id_zero+size(cur_U_all, 1)-1, 1:2) = sig_metric;
    eval_metric_all(id_zero:id_zero+size(cur_U_all, 1)-1, 3:4) = acc_metric;
    
end

%% generate errorbars values (bigger between resolution and accuracy)
pos_acc = eval_metric_all(:, 4);
neg_acc = eval_metric_all(:, 3);

pos_err_plot = max(pos_acc,U_all(:, 3));
neg_err_plot = max(neg_acc,U_all(:, 3));

%% plot results

%U_all(abs(U_all)>2) = mean(U_all(:));
U_all(isnan(U_all)) = nanmean(U_all(:));
%currents_all = [U_all(:, 1)-c0_all(:, 1),  U_all(:, 2)+c0_all(:, 1)]; 
x_plot = 1:length(U_all(:, 1));
x_plot = x_plot .* dt;
ylim_val = ceil(max(abs(max(U_all(:, 1))), abs(min(U_all(:,1)))));

fig=figure; fig.Position = [10 10 1100 450];
hold on; scatter(x_plot, U_all(:, 1), 60);
hold on; scatter(x_plot, -U_all(:, 2), 60, 'x');
hold on; plot(x_plot, c0_all(:, 1), 'color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 2);
%hold on; errorbar(x_plot, U_all(:, 2), pos_err_plot, 'LineStyle','none');
%hold on; errorbar(x_plot, U_all(:, 1), neg_err_plot, 'LineStyle','none');
%ylim([-ylim_val/2, ylim_val/2]);
xline(max(x_plot)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
%yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:average_every:max(x_plot) max(x_plot)];
xlabel('Time [hr]'); ylabel('Celerity [m/s]');
%legend('Positive peak', 'Negative peak', 'C_0 celerity', 'box', 'off', 'FontSize', 10);
legend('Negative peak', 'Positive peak', 'C_0 value','box', 'off', 'FontSize', 10);
xlim([1 max(x_plot)]);

%% fft

Fs = 1/dt;
L = H*length(files);

Y_pos = fft(U_all(:, 2) - mean(U_all(:, 2)));
Y_neg = fft(U_all(:, 1)- mean(U_all(:, 1)));

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

pos_mean = mean(U_pos);
neg_mean = mean(U_neg);

P1_pos = fftshift(fft(U_pos-pos_mean));
P1_neg = fftshift(fft(U_neg-neg_mean));

close all;

%% defining frequencies ranges

f_upper = 0.15; % above this value its just noise [Hz]
f_tides = 0.035417;  % between this and f_upper is the tidal region [Hz]

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

figure(); scatter(x_plot, U_pos_filt+pos_mean)
hold on; scatter(x_plot, U_neg_filt+neg_mean, 'x');
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
scatter(x_plot, U_neg_filt+neg_mean);
hold on;scatter(x_plot, -(U_pos_filt+pos_mean), 'x');
hold on; plot(x_plot, c0_all(:, 1), 'color', [0.5 0.5 0.5], 'LineStyle', '--', 'LineWidth', 2);

%hold on; errorbar(x_plot, U_neg_filt+neg_mean, neg_err_plot, 'LineStyle','none');
%hold on; errorbar(x_plot, U_pos_filt+pos_mean, pos_err_plot, 'LineStyle','none');
hold on;
%ylim([-ylim_val/2, ylim_val/2]);
xline(24*length(files)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
%yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:3:24*length(files) 24*length(files)];
xlabel('Time [hr]'); ylabel('Current [m/s]');
legend('Negative peak', 'Positive peak', 'box', 'off');
xlim([1 24*length(files)]);

U_all_filt = [U_neg_filt U_pos_filt];
%% evaluate shear constants

U_pos_abs = U_pos_filt + pos_mean;
U_neg_abs = U_neg_filt + neg_mean;

[alpha, beta, m] = evaluate_shear('arbitrary', U_neg_abs, U_pos_abs, c0_all(:, 1));


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
errorbar(x_plot, U_pos_filt, pos_err_plot, 'LineStyle','none', 'Color', 'blue');
hold on; scatter(x_plot, U_neg_filt, 'x');
errorbar(x_plot, U_neg_filt, neg_err_plot, 'LineStyle','none', 'Color', 'red');
hold on;
ylim([-ylim_val/2, ylim_val/2]);
xline(24*length(files)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:3:24*length(files) 24*length(files)];
xlabel('Time [hr]'); ylabel('Velocity [m/s]');
legend('Positive peak', 'Negative peak', 'box', 'off');
xlim([1 24*length(files)]);