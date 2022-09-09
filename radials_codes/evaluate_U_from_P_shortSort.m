%% Calculate current values from short Sort files (below the 20 minutes avg)

basic_path = 'Z:\radials_spectrum_shortSort\short_1024_shift_1024_range_100\is1\R_20.9184_Ncells_1_ang_22_22\';

average_every = 1;

T_chirp = 0.26; % chirp duration [seconds]
T_meas = 17.75; % duration of the full measurements [minutes]
short_samples = 1024; % must be equal to the hsort value of the path

num_splits = round(T_meas / (T_chirp * short_samples / 60));
H = num_splits / average_every;
dt = T_chirp * short_samples / 60;

files = dir(basic_path);
files = files(3:5);

U_all = -10.*ones(H*length(files), 2);  % [negative_peak, positive_peak]
res_all = zeros(H*length(files), 1);
eval_metric_all = -10.*ones(H*length(files), 4);
for cur_split = 1 : length(files)
    
    id_zero = find(U_all == -10);
    id_zero = id_zero(1);
    
    cur_filename = strcat(basic_path, files(cur_split).name);
    [cur_U_all, res, sig, acc, f_peaks] = get_U_shortSort(cur_filename, 'Cp', 'centroid');
    
    U_all(id_zero:id_zero+size(cur_U_all, 1)-1, 1) = cur_U_all(:, 1);
    U_all(id_zero:id_zero+size(cur_U_all, 1)-1, 2) = cur_U_all(:, 2);
    res_all(id_zero:id_zero+size(cur_U_all, 1)-1, 1) = res;
    
    eval_metric_all(id_zero:id_zero+size(cur_U_all, 1)-1, 1:2) = sig;
    eval_metric_all(id_zero:id_zero+size(cur_U_all, 1)-1, 3:4) = acc;
    
end

%% plot results

U_all(isnan(U_all)) = nanmean(U_all(:));
x_plot = 1:length(U_all);
x_plot = x_plot .* dt;
ylim_val = ceil(max(abs(max(U_all(:, 1))), abs(min(U_all(:,1)))));

fig=figure; fig.Position = [10 10 1100 450];
hold on; scatter(x_plot, U_all(:, 2));
scatter(x_plot, U_all(:, 1), 'x');
hold on; errorbar(x_plot, U_all(:, 2), res_all, 'LineStyle','none');
hold on; errorbar(x_plot, U_all(:, 1), res_all, 'LineStyle','none');
hold on;
%ylim([-ylim_val/2, ylim_val/2]); % optional for NOT Cp value
xline(max(x_plot)/2,'color', [0.5 0.5 0.5], 'linewidth', 1);
yline(0,'color', [0.5 0.5 0.5], 'linewidth', 1);
vals = [1:average_every:max(x_plot) max(x_plot)];
xlabel('Time [min]'); ylabel('Velocity [m/s]');
legend('Positive peak', 'Negative peak', 'box', 'off');
xlim([1 max(x_plot)]);