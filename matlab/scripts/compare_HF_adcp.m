%% set environment
addpath(genpath('../../'))
config = jsondecode(fileread('run_config.json'));
%% extract shear from HF radar

agg_map = phase_velocity_aggregator(config);
avg_map = phase_velocity_averagor(config, agg_map);
smooth_map = phase_velocity_smoothor(config, avg_map);
solution_map = linear_shear_calculation(smooth_map);

a1 = solution_map('alpha1');
b1 = solution_map('beta1');

a2 = solution_map('alpha2');
b2 = solution_map('beta2');
datetime_HF_str = avg_map('datetime');
datetime_HF = str2datetime(datetime_HF_str);


%% extract measurements from ADCP

agg_map_adcp = adcp_aggregator(config);
cut_map_adcp = adcp_cutter(config, agg_map_adcp);
avg_map_adcp = adcp_averagor(config, cut_map_adcp);
projected_map_adcp = adcp_projection(config, avg_map_adcp);
projected_map_adcp_with_alpha_hat = adcp_gradientor(config, projected_map_adcp);
Vr_adcp = projected_map_adcp('Vr');
alpha_hat = projected_map_adcp_with_alpha_hat('alpha_hat');
datetime_adcp_str = projected_map_adcp('datetime');
datetime_adcp = str2datetime(datetime_adcp_str);

%% extract Hs from ADCP

Hs_map = get_Hs_data(config);
cut_map_Hs= adcp_cutter(config, Hs_map);
avg_map_Hs = adcp_averagor(config, cut_map_Hs);
datetime_Hs_str = avg_map_Hs('datetime');
datetime_Hs = str2datetime(datetime_Hs_str);
Hs = str2double(avg_map_Hs('Hs'));

%% extract measurments from ims

ims_map = get_ims_data(config);
cut_map_ims = adcp_cutter(config, ims_map);
avg_map_ims = adcp_averagor(config, cut_map_ims);
projected_map_ims = adcp_projection(config, avg_map_ims);
Vr_ims = projected_map_ims('Vr');
datetime_ims_str = projected_map_ims('datetime')';
datetime_ims = str2datetime(datetime_ims_str);

%% period of real results of alpha

date1 = datetime('2021-03-23 17:00:00');
date2 = datetime('2021-03-25 03:00:00');

date3 = datetime('2021-04-02 03:00:00');
date4 = datetime('2021-04-02 17:00:00');

date5 = datetime('2021-04-09 23:00:00');
date6 = datetime('2021-04-11 13:00:00');

start_time = date1;
end_time = date2;

indices_alpha = datetime_HF >= start_time & datetime_HF <= end_time;
indices_adcp = datetime_adcp >= start_time & datetime_adcp <= end_time;
indices_ims = datetime_ims >= start_time & datetime_ims <= end_time;
indices_Hs = datetime_Hs >= start_time & datetime_Hs <= end_time;

%% plot peak evaluation and accuracy

negative_peak = smooth_map('c_negative_peak') - smooth_map('c_unperturbed');
errorbar_negative = avg_map('accuracy_negative_peak');

positive_peak = smooth_map('c_positive_peak') + smooth_map('c_unperturbed');
errorbar_positive = avg_map('accuracy_positive_peak');

fig=figure; fig.Position = [10 10 1100 700];
subplot(2, 1, 1);
errorbar(datetime_HF, negative_peak, errorbar_negative);
hold on;
errorbar(datetime_HF, positive_peak, errorbar_positive);
 ylabel('constant current estimation [m/s]', 'FontSize', 12)
xlim([min(datetime_HF), max(datetime_HF)])
legend({'c_{negative peak} - c_0', 'c_{positive peak} - c_0'}, 'Box', 'off', 'Location','best', 'FontSize', 12);
set(gca, 'FontSize', 12);

subplot(2, 1, 2);
errorbar(datetime_HF(indices_alpha), negative_peak(indices_alpha), errorbar_negative(indices_alpha));
hold on;
errorbar(datetime_HF(indices_alpha), positive_peak(indices_alpha), errorbar_positive(indices_alpha));

xlim([start_time-hours(1), end_time+hours(1)])
legend({'c_{negative peak} - c_0', 'c_{positive peak} - c_0'}, 'Box', 'off', 'Location','best', 'FontSize', 12);
xlabel('date', 'FontSize', 12); ylabel('constant current estimation [m/s]', 'FontSize', 12)
set(gca, 'FontSize', 12);

%% add real alpha periods
xline(date1, 'black--', 'LineWidth', 2)
xline(date2, 'black--', 'LineWidth', 2)

xline(date3, 'black--', 'LineWidth', 2)
xline(date4, 'black--', 'LineWidth', 2)

xline(date5, 'black--', 'LineWidth', 2)
xline(date6, 'black--', 'LineWidth', 2)

xlim([min(datetime_HF), max(datetime_HF)])
legend({'c_{negative peak} - c_0', 'c_{positive peak} - c_0', 'real \alpha periods'}, 'Box', 'off', 'Location','best', 'FontSize', 12);
xlabel('date', 'FontSize', 12); ylabel('constant current estimation [m/s]', 'FontSize', 12)
set(gca, 'FontSize', 12);

%% plot timeseries - wind

fig=figure; fig.Position = [10 10 1100 450];
plot(datetime_ims, Vr_ims);

xline(date1, 'black--', 'LineWidth', 2)
xline(date2, 'black--', 'LineWidth', 2)

xline(date3, 'black--', 'LineWidth', 2)
xline(date4, 'black--', 'LineWidth', 2)

xline(date5, 'black--', 'LineWidth', 2)
xline(date6, 'black--', 'LineWidth', 2)

legend({'Wind', 'real \alpha periods'}, 'Box', 'off', 'Location','best', 'FontSize', 12);
xlabel('date', 'FontSize', 12); ylabel('Wind along radial [m/s]', 'FontSize', 12)
set(gca, 'FontSize', 12);

%% plot timeseries - Hs
fig=figure; fig.Position = [10 10 1100 450];
plot(datetime_Hs, Hs);

xline(date1, 'black--', 'LineWidth', 2)
xline(date2, 'black--', 'LineWidth', 2)

xline(date3, 'black--', 'LineWidth', 2)
xline(date4, 'black--', 'LineWidth', 2)

xline(date5, 'black--', 'LineWidth', 2)
xline(date6, 'black--', 'LineWidth', 2)

xlabel('date');
ylabel('H_s [m]');

%% wind & shear timeseries
fig=figure; fig.Position = [10 10 1100 450];
yyaxis left; plot(datetime_ims, abs(Vr_ims));
ylabel('|Wind| [m/s]', 'FontSize', 12)
yyaxis right; plot(datetime_HF(indices_alpha), abs(a2(indices_alpha)), 'LineStyle', '-', 'Marker', 'o')
xlabel('date', 'FontSize', 12);
ylabel('|\alpha| [1/s]', 'FontSize', 12);
xlim([start_time-hours(18), end_time+hours(18)]);
legend({'Wind', 'Shear parameter'}, 'Box', 'off', 'FontSize', 12, 'Location', 'best')
set(gca, 'FontSize', 12);

%% alpha_hat & shear timeseries
fig=figure; fig.Position = [10 10 1100 450];
yyaxis left; plot(datetime_adcp, abs(alpha_hat));
ylabel('$|\hat{\alpha}|$ [1/s]', 'Interpreter', 'latex', 'FontSize', 12)
yyaxis right; plot(datetime_HF(indices_alpha), abs(a2(indices_alpha)), 'LineStyle', '-', 'Marker', 'o')
xlabel('date', 'FontSize', 12);
ylabel('|\alpha| [1/s]', 'FontSize', 12);
xlim([start_time-hours(18), end_time+hours(18)]);
legend({'$\hat{\alpha}$', 'Shear parameter'}, 'Interpreter', 'latex', 'Box', 'off', 'FontSize', 12, 'Location', 'best')
set(gca, 'FontSize', 12);

%% Hs & shear timeseries
fig=figure; fig.Position = [10 10 1100 450];
yyaxis left; plot(datetime_Hs, Hs);
ylabel('Hs [m]')
yyaxis right; plot(datetime_HF(indices_alpha), abs(a2(indices_alpha)), 'LineStyle', '-', 'Marker', 'o')
ylabel('|\alpha| [1/s]');
xlim([start_time-hours(18), end_time+hours(18)]);
legend({'Hs', 'Shear parameter'}, 'Box', 'off', 'FontSize', 12, 'Location', 'best')
set(gca, 'FontSize', 12);

%% ADCP & shear timeseries
fig=figure; fig.Position = [10 10 1100 450];
yyaxis left; plot(datetime_adcp, abs(Vr_adcp(end, :)));
ylabel('Current [m/s]')
yyaxis right; plot(datetime_HF(indices_alpha), abs(a2(indices_alpha)), 'LineStyle', '-', 'Marker', 'o');
ylabel('|\alpha| [1/s]');
xlim([start_time-hours(18), end_time+hours(72)]);
legend({'Current at z=-6 m', 'Shear parameter'}, 'Box', 'off', 'FontSize', 12, 'Location', 'best')
set(gca, 'FontSize', 12);

%% ADCP current profiles
Vr_adcp_period = Vr_adcp(:, indices_adcp);
z = projected_map_adcp('z');
mean_profile = mean(Vr_adcp_period, 2);
std_profile = std(Vr_adcp_period, [], 2);
fig=figure; fig.Position = [10 10 600 450];
errorbar(mean_profile, z, std_profile', 'Horizontal');
ylim([min(z), 0]);
hold on;
plot([0 0], ylim, 'Color', [0.5, 0.5, 0.5, 0.5], 'LineWidth', 1);  % [0.5, 0.5, 0.5] is gray, and 0.5 is the transparency
legend({'current'}, 'Box', 'off', 'FontSize', 12, 'Location', 'best')
xlabel('Current [m/s]', 'FontSize', 12);
ylabel('Depth [m]', 'FontSize', 12);
set(gca, 'FontSize', 12);

%% shear-wind-adcp relation
fig=figure; fig.Position = [10 10 1100 450];
indices_adcp = datetime_adcp >= start_time & datetime_adcp <= end_time;
indices_ims = datetime_ims >= start_time & datetime_ims <= end_time;
indices_alpha = datetime_HF >= start_time & datetime_HF <= end_time;

scatter(datetime_adcp, Vr_adcp(end, :), 50, 'Marker', 'x'); ylabel('Vr adcp [m/s]');
hold on;
scatter(datetime_ims(indices_ims), Vr_ims(indices_ims), 150, real(a2(indices_alpha)'), 'filled'); ylabel('Vr current [m]');
xlim([start_time-hour(1), end_time+hour(1)]);
legend({'Vr at z=0', 'Vr  at z=-6 m'}, 'Box', 'off', 'FontSize', 12, 'Location', 'best')
xlabel('date', 'FontSize', 12); ylabel('Current [m/s]', 'FontSize', 12)
c = colorbar;
c.Label.String = '\alpha [1/sec]';
c.Label.FontSize = 12;