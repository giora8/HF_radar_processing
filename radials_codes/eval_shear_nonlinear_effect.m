%% load HF processed data
average_every = 3;
H = 72 / average_every;
dt = 24 / H;
processed_path = 'Z:\radials_spectrum\is1_R_3.5622_Ncells_1_ang_-3_5\';
mat_files = dir(processed_path); 
mat_files = mat_files(24:46);  % relevant dates with ADCP
wave_data = load('C:\Giora\TAU\MEPlab\HF_Radar\files\non_linear_sol_teodor\WaveData.mat');

%% initializing variables
c0 = -10 .* ones(H*length(mat_files), 1);
C = -10 .* ones(H*length(mat_files), 2);

%% calculating HF estimation

for cur_day = 1 : length(mat_files)
    id_zero = find(C == -10);
    id_zero = id_zero(1);
    
    cur_filename = strcat(processed_path, mat_files(cur_day).name);
    [cur_C, ~, ~, cur_c0] = get_U(cur_filename, average_every, 'Cp', 'centroid', 0.15);
    
    c0(id_zero:id_zero+size(cur_C, 1)-1) = cur_c0;
    C(id_zero:id_zero+size(cur_C, 1)-1, 1) = cur_C(:, 1);
    C(id_zero:id_zero+size(cur_C, 1)-1, 2) = cur_C(:, 2);
    
end

%% plot raw timeseries

t_plot = 1:length(C);
t_plot = t_plot .* dt;
ylim_val = ceil(max(abs(max(C(:, 1))), abs(min(C(:,1)))));

fig=figure; fig.Position = [10 10 1100 450];
scatter(t_plot, C(:, 1), 'x');
hold on;
scatter(t_plot, -C(:, 2), 'o');

vals = [1:3:24*length(mat_files) 24*length(mat_files)];
xlabel('Time [hr]'); ylabel('Celerity [m/s]');
legend('towards', 'away', 'box', 'off');
xlim([1 24*length(mat_files)]);

%% operate rectangular filter
mean_C = mean(C);

C_away = C(:, 2) - mean_C(2);
C_towards = C(:, 1) - mean_C(1);
N = length(C_away);

Nyquist = 1 / (2*dt);
df = 1 / (N*dt);
f = -Nyquist : df : Nyquist - df;

P1_away = fftshift(fft(C_away));
P1_towards = fftshift(fft(C_towards));

f_upper = 0.15; % above this value its just noise
noise_freq_indices1 = find(f<=-f_upper);
noise_freq_indices2 = find(f>=f_upper);
noise_freq_indices = [noise_freq_indices1 noise_freq_indices2];

P1_away_noise_reduced = P1_away;
P1_away_noise_reduced(noise_freq_indices) = 0;

P1_towards_noise_reduced = P1_towards;
P1_towards_noise_reduced(noise_freq_indices) = 0;

C_away_filt = ifft(ifftshift(P1_away_noise_reduced)) + mean_C(2);
C_towards_filt = ifft(ifftshift(P1_towards_noise_reduced)) + mean_C(1);

%% plot filtered timeseries
fig=figure; fig.Position = [10 10 1100 450];
scatter(t_plot, C_towards_filt, 'x');
hold on;
scatter(t_plot, -C_away_filt, 'o');

vals = [1:3:24*length(mat_files) 24*length(mat_files)];
xlabel('Time [hr]'); ylabel('Celerity [m/s]');
legend('towards', 'away', 'box', 'off');
xlim([1 24*length(mat_files)]);

%% match non-linear ratio to HF measurement

[R_backward, R_onward] = merge_HF_to_nonlinear_ratios(wave_data);


%% evaluate linear shear constant

[alpha_lin, beta_lin] = evaluate_linear_shear_fixed(C_towards_filt, C_away_filt, c0);

%% evaluate linear shear constant using non-linear correction

[alpha, beta] = evaluate_linear_shear_noninear_effect(C_towards_filt, C_away_filt, R_onward, R_backward, c0);

%% get Hs of this period

load('C:\Giora\TAU\MEPlab\HF_Radar\files\non_linear_sol_teodor\Hs.mat');
Hs = average_Hs_to_HF(Hs, time);

%% get wind data
avg_wind = average_wind_to_HF('C:\Giora\TAU\MEPlab\HF_Radar\files\wind_data.mat');

%% prepare to ADCP

U_all_filt = real(beta);
x_plot = t_plot;