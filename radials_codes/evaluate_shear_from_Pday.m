%% Not ready to use!

%% Calculate current values when averaging (average_every=3 e.c. 00:00-01:00, 01:00-02:00 etc.)
average_every = 3;
H = 72 / average_every;
dt = 24 / H ;
basic_path = 'Z:\radials_spectrum\is1_R_3.5622_Ncells_1_ang_-3_5\';
%basic_path = 'Z:\radials_spectrum\is1_R_20.9184_Ncells_1_ang_22_22\';
%basic_path = 'Z:\radials_spectrum\is1_R_3.5622_Ncells_3_ang_1_1\';
files = dir(basic_path);
files = files(3:16);
c0_all = -10.*ones(H*length(files), 1);
U_all = -10.*ones(H*length(files), 3); % [negative_peak, positive_peak, resolution]
eval_metric_all = -10.*ones(H*length(files), 4); % [sigma squared neg, sigma squared pos, acc neg, acc pos]
for cur_day = 1 : length(files)

    id_zero = find(U_all == -10);
    id_zero = id_zero(1);
    
    cur_filename = strcat(basic_path, files(cur_day).name);
    [cur_U_all, sig_metric, acc_metric, cur_c0] = get_U(cur_filename, average_every, 'Cp', 'centroid', 0.1);
    
    c0_all(id_zero:id_zero+size(cur_U_all, 1)-1) = cur_c0;
    U_all(id_zero:id_zero+size(cur_U_all, 1)-1, 1) = cur_U_all(:, 1);
    U_all(id_zero:id_zero+size(cur_U_all, 1)-1, 2) = cur_U_all(:, 2);
    U_all(id_zero:id_zero+size(cur_U_all, 1)-1, 3) = cur_U_all(:, 3);
    
    eval_metric_all(id_zero:id_zero+size(cur_U_all, 1)-1, 1:2) = sig_metric;
    eval_metric_all(id_zero:id_zero+size(cur_U_all, 1)-1, 3:4) = acc_metric;
    
end

%% generate errorbars values (bigger between resolution and accuracy)
pos_acc = eval_metric_all(:, 4);
neg_acc = eval_metric_all(:, 3);

pos_err_plot = max(pos_acc,U_all(:, 3));
neg_err_plot = max(neg_acc,U_all(:, 3));

%% plot results

x_plot = 1:length(U_all);
x_plot = x_plot .* dt;
ylim_val = ceil(max(abs(max(U_all(:, 1))), abs(min(U_all(:,1)))));
mean_U_all = mean(U_all);

%% NEW METHOD - shift zero frequency to center, than ifft is possible

U_pos = U_all(:, 2)-mean_U_all(2);
U_neg = U_all(:, 1)-mean_U_all(1);
N = length(U_pos);

Nyquist = 1 / (2*dt);
df = 1 / (N*dt);
f = -Nyquist : df : Nyquist - df;

P1_pos = fftshift(fft(U_pos));
P1_neg = fftshift(fft(U_neg));

close all;
%% defining frequencies ranges

f_upper = 0.15; % above this value its just noise
f_tides = 0.035417-0*df;  % between this and f_upper is the tidal region
%f_tides = 0.038194;  % between this and f_upper is the tidal region
noise_freq_indices1 = find(f<=-f_upper);
noise_freq_indices2 = find(f>=f_upper);
noise_freq_indices = [noise_freq_indices1 noise_freq_indices2];

tide_freq_indices1 = find(f<=-f_tides & f>-f_upper);
tide_freq_indices2 = find(f>=f_tides & f<f_upper);
tide_freq_indices = [tide_freq_indices1 tide_freq_indices2];

low_freq_indices = find(abs(f)<=f_tides);

noise_tides_indices = [noise_freq_indices tide_freq_indices];
low_tides_indices = [low_freq_indices tide_freq_indices];
%% noise reduction by filtering higher frequencies
%figure(); plot(f, abs(P1_pos));

P1_pos_noise_red = P1_pos;
P1_pos_noise_red(noise_freq_indices) = 0;
% figure(); plot(f, abs(P1_pos_noise_red));
% xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');
% title('Positive peak');

P1_neg_noise_red = P1_neg;
P1_neg_noise_red(noise_freq_indices) = 0;
% figure(); plot(f, abs(P1_neg_noise_red));
% xlabel('Frequency [1/hr]'); ylabel('Power [A.U]');
% title('Negative peak');

U_pos_filt = ifft(ifftshift(P1_pos_noise_red)) + mean_U_all(2);
U_neg_filt = ifft(ifftshift(P1_neg_noise_red)) + mean_U_all(1);

fig=figure; fig.Position = [10 10 1100 450];
scatter(x_plot, U_pos_filt)
hold on; scatter(x_plot, U_neg_filt, 'x');
hold on; errorbar(x_plot, U_pos_filt, pos_err_plot, 'LineStyle','none');
hold on; errorbar(x_plot, U_neg_filt, neg_err_plot, 'LineStyle','none');
hold on;
%ylim([-ylim_val/2, ylim_val/2]);
xline(24*length(files)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:3:24*length(files) 24*length(files)];
xlabel('Time [hr]'); ylabel('Velocity [m/s]');
legend('Positive peak', 'Negative peak', 'box', 'off');
xlim([1 24*length(files)]);

U_all_filt = [U_neg_filt U_pos_filt];

%% arbitrary profile
U_pos = U_all(:, 2) - mean_U_all(2);
U_neg = U_all(:, 1) - mean_U_all(1);
alphas = -0.2.*zeros(length(U_neg), 1);
[alpha, beta, m] = evaluate_shear('exp', U_neg_filt, U_pos_filt, c0_all);
figure(); scatter(x_plot, m);
title('m');

z = 0 : -0.001 : -3;
z = z';

UU = zeros(length(z), length(beta));
for ii = 1 : length(beta)
    
    cur_alpha = alpha(ii);
    cur_beta = beta(ii);
    cur_m = m(ii);
    
    UU(:, ii) = cur_alpha + cur_beta.*exp(cur_m.*z);
    
end


%%

alphas = -0.2.*zeros(length(U_neg), 1);
[alpha, beta, m] = evaluate_shear('exp', U_neg_filt, U_pos_filt, c0_all);
figure(); scatter(x_plot, m);
title('m');

z = 0 : -0.001 : -3;
z = z';

UU = zeros(length(z), length(beta));
for ii = 1 : length(beta)
    
    cur_alpha = alpha(ii);
    cur_beta = beta(ii);
    cur_m = m(ii);
    
    UU(:, ii) = cur_alpha + cur_beta.*exp(cur_m.*z);
    
end

%% linear profile

[alpha, beta, ~] = evaluate_shear('lin', U_neg_filt, U_pos_filt, c0_all);

z = 0 : -0.001 : -3;
z = z';

UU = zeros(length(z), length(beta));
for ii = 1 : length(beta)
    
    cur_alpha = alpha(ii);
    cur_beta = beta(ii);
    
    UU(:, ii) = cur_beta + cur_alpha.*z;
    
end

%% 

fig=figure; fig.Position = [100 100 800 600];
subplot(13, 9, 1:54);
hold on; scatter(x_plot, U_pos_filt, 'o');
hold on; scatter(x_plot, U_neg_filt, 'x');
hold on; y_locs = max(U_all_filt(:, 1), U_all_filt(:, 2));
p1 = [x_plot(1) y_locs(1) + 0.15];                     
p2 = [x_plot(1) y_locs(1)+0.01];                         
dp = p2-p1;
h_q = quiver(p1(1),p1(2),dp(1),dp(2), 1, 'color', [0 0 0], 'linewidth', 2);
hold on;
hold on; errorbar(x_plot, U_pos_filt, pos_err_plot, 'LineStyle','none', 'color', [0,0.447,0.741]);
hold on; errorbar(x_plot, U_neg_filt, neg_err_plot, 'LineStyle','none', 'color', [0.85,0.325,0.098]);
hold on;
ylim([-ylim_val/2, ylim_val/2]);
xline(24*length(files)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:3:24*length(files) 24*length(files)];
xlabel('Time [hr]'); ylabel('Velocity [m/s]');
xlim([1 24*length(files)]);
legend('Positive peak', 'Negative peak', 'current point','box', 'off', 'AutoUpdate','off');

save_video_flag = 1;
if save_video_flag == 1
    myVideo = VideoWriter('profiles2'); %open video file
    myVideo.FrameRate = 5;
    open(myVideo)
end

counter = 2;
for ii = 2 : size(UU, 2)

    subplot(13, 9, 73:117 );
    plot(UU(:, ii), z);
    xlabel('U [m/s]');
    ylabel('z [m]');
    title('U(z) = \alpha + \beta e^{mz}');
    yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
    xline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
    xlim([-0.3 0.3]); ylim([-3 0]);
    st1 = strcat('\alpha = ', string(alpha(ii)));
    st2 = strcat('\beta = ', string(beta(ii)));
    st3 = strcat('m = ', string(m(ii)));
    legend(st1, st2, st3, 'box', 'off', 'fontsize', 12);
    
    subplot(13, 9, 1:54);
    p1 = [x_plot(counter) y_locs(counter) + 0.15];                     
    p2 = [x_plot(counter) y_locs(counter)+0.01];                         
    dp = p2-p1;
    delete(h_q);
    h_q = quiver(p1(1),p1(2),dp(1),dp(2), 1, 'color', [0 0 0], 'linewidth', 2);
    counter = counter + 1;
    if save_video_flag == 1
        frame = getframe(gcf); %get frame
        writeVideo(myVideo, frame);
    end
    pause(0.08);
end

if save_video_flag == 1
    close(myVideo)
end





