% (longitude, latitude) of target locations and Ashkelon station
ADCP_shallow = [34.532972 31.670556];
ADCP_deep = [34.512833 31.681639];
HF_station = [34.545 31.665];

N_range_cells = 1;
N_angs = 4;
%% relevant .SORT file

folder_path = 'Z:\data\is1\2021087\raw\';
filename = '20210870000_is1.SORT';
sort_filename = strcat(folder_path, filename);
[WERA,t,r,~,~] = read_WERA_sort(sort_filename);
f_bragg = WERA.fbragg;
dr = r(2) - r(1);
%% generate frequency axis

Fs = 1 / (t(2)-t(1)) ; % Sampling frequency
L = length(t);
f = Fs*(-L/2:L/2-1)/L;

%% get closest radial angle and distance between station and target

folder_path_deg_files = 'Z:\raw_spectrum\2021087\';
[R, ANG] = get_station_angle_radi(HF_station, ADCP_deep);
[deg_file_list, angle_list] = get_degrees_files(folder_path_deg_files, filename(1:end-5), ANG, N_angs);
angle_list = sort(angle_list);

%loc_P_mat = gen_radial_P_cell(deg_file_list, r, angle_list, folder_path);

%% plot patch on a map

AZ0 = 300;
azimuth_to_plot = angle_list + 300;
FigH1 = coast_station_plot;
points_of_interest_plot(ADCP_deep);
plot_radial_range_patch(r, dr, azimuth_to_plot, R, N_range_cells, HF_station)

FigH2 = coast_station_plot;
points_of_interest_plot(ADCP_deep);
plot_radial_range_gridded(r, dr, azimuth_to_plot, R, N_range_cells, HF_station)


%% calculate spectrum from each radial

first_harmonic = [ 1 -1 ];
second_harminic = [sqrt(2) -sqrt(2)];
corner_wave = [2^(3/4) -2^(3/4)];

freq_norm = f ./ f_bragg ;
undisturbed_vals = [first_harmonic ; second_harminic ; corner_wave];

P_ang = zeros(length(deg_file_list), length(t));
f_peaks = zeros(length(deg_file_list), 3, 2);
for ii = 1 : length(deg_file_list)
    cur_filename = strcat(folder_path, deg_file_list(ii).name);
    
    id1 = strfind(cur_filename, '_');
    id2 = strfind(cur_filename, 'deg');
    deg = str2double(cur_filename(id1(end)+1: id2-1));
    id_put = find(ismember(angle_list, deg));
    P_temp = get_range_spec(cur_filename, r, R, N_range_cells, 'discrete');
    P_ang(id_put, :) = movmean(P_temp, 1);
end
f1 = 0.6;
f2 = 1.8;
id1 = find(freq_norm > f1);
id1 = id1(1);
id2 = find(freq_norm < f2);
id2 = id2(end);


figure(); imagesc(freq_norm(id1:id2), angle_list, P_ang(:, id1:id2)); set(gca, 'Ydir', 'Normal');
ylabel('Angle [\circ]');
xlabel('Doppler frequency [F_B]')

[~, max_id] = max(P_ang, [], 2);
f_pos = freq_norm(max_id);
f_pos = f_pos(find(f_pos));
angle_list_plot_pos = angle_list(find(f_pos));
hold on; plot(f_pos, angle_list_plot_pos, 'color', [0 0 0], 'linewidth', 2);

id_half = find(freq_norm < -0.5);
id_half = id_half(end);

[~, min_id] = max(P_ang(:, 1:id_half), [], 2);
f_neg = freq_norm(min_id);
f_neg = f_neg(find(f_neg));
angle_list_plot_neg = angle_list(find(f_neg));
hold on; plot(f_neg, angle_list_plot_neg, 'color', [0 0 0], 'linewidth', 1);

% f1_2 = -1.8;
% id1_2 = find(freq_norm > f1_2);
P_1 = P_ang(17, id1:id2);
figure(); plot(freq_norm(id1:id2), P_1);
xlabel('Doppler frequency [F_B]')
ylabel('Power [dB]');
title('Cross section at 1\circ');

%%

df_pos = abs(1-f_pos);
df_neg = abs(-1-f_neg);
figure(); scatter(angle_list_plot_pos, df_pos, 'o', 'fill');
hold on; scatter(angle_list_plot_neg, df_neg, 'o', 'fill');
xlabel('Angle [\circ]'); ylabel('\Deltaf [F_B]');
legend('Positive', 'Negative', 'box', 'off'); grid on;
std_pos = std(df_pos);
std_neg = std(df_neg);
st_title = strcat('std positive peak: ', num2str(std_pos), ' [F_B]', ...
    ' std negative peak: ', num2str(std_neg), ' [F_B]');
title(st_title);

%% frequency axis

freq_norm = f ./ f_bragg ;

first_harmonic = [ 1 -1 ];
second_harminic = [sqrt(2) -sqrt(2)];
corner_wave = [2^(3/4) -2^(3/4)];

figure(2);
plot(freq_norm, mean(P, 1));
hold on;
xline(first_harmonic(1),'--k'); xline(first_harmonic(2),'--k');
xline(second_harminic(1),'--k'); xline(second_harminic(2),'--k');
xline(corner_wave(1),'--k'); xline(corner_wave(2),'--k');

xlabel('Normalized Frequency [f_B]');
ylabel('Backscattered Power [dB]');
xlim([min(freq_norm) max(freq_norm)]);

undisturbed_vals = [first_harmonic ; second_harminic ; corner_wave];
[f_peaks, ~, ~] = find_ivonin_peaks(P, undisturbed_vals, freq_norm, 1, 'max');

f_diff = f_peaks - undisturbed_vals;
f_diff = f_diff .* f_bragg;
lamda_EM = 3e8 / 8.3e6 ;
lambda_bragg = lamda_EM / 2;

U = lambda_bragg .* f_diff;

figure(2); hold on;
        
[~, min_id1] = min(abs(f - f_peaks(1, 1)));
[~, min_id2] = min(abs(f - f_peaks(1, 2)));
[~, max_id] = max(P);

f_txt1 = f(min_id1);
f_txt2 = f(min_id2);
P_txt = P(max_id) + 2;

U_1_p = num2str(U(1, 1));
U_1_P = U_1_p(1:6);
U_1_n = num2str(U(1, 2));
U_1_n = U_1_n(1:6);

text(f_txt1, P_txt, strcat('U_{1_p}=', U_1_P, 'm/s'));
text(f_txt2, P_txt, strcat('U_{1_n}=', U_1_n, 'm/s'));

df = f_peaks(1, :) - undisturbed_vals(1, :);
df_p = num2str(df(1)*f_bragg);
df_p = df_p(1:6);
df_n = num2str(df(2)*f_bragg);
df_n = df_n(1:6);

title(strcat('\Deltaf_n = ', df_n, ' [Hz]  \Deltaf_p = ', df_p, ' [Hz]'));
