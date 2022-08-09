% (longitude, latitude) of target locations and Ashkelon station
ADCP_shallow = [34.532972 31.670556];
ADCP_deep = [34.512833 31.681639];
HF_station = [34.545 31.665];

N_range_cells = 10;
N_angs = 2;

%% relevant .SORT file

folder_path = 'C:\Giora\TAU\MEPlab\HF_Radar\files\radials_ascii\';
filename = '20210821440_is1.SORT';
sort_filename = strcat(folder_path, filename);
[WERA,t,r,~,~] = read_WERA_sort(sort_filename);
f_bragg = WERA.fbragg;

%% generate frequency axis

Fs = 1 / (t(2)-t(1)) ; % Sampling frequency
L = length(t);
f = Fs*(-L/2:L/2-1)/L;

%% get closest radial angle and distance between station and target
filename = '20210820340_is1';
folder_path = 'C:\Giora\TAU\MEPlab\deg_files\';

[R, ANG] = get_station_angle_radi(HF_station, ADCP_deep);
[deg_file_list, angle_list] = get_degrees_files(folder_path, filename(1:end-5), ANG, N_angs);
angle_list = sort(angle_list);

%%

first_harmonic = [ 1 -1 ];
second_harminic = [sqrt(2) -sqrt(2)];
corner_wave = [2^(3/4) -2^(3/4)];

freq_norm = f ./ f_bragg ;
N1 = 100;
P = zeros(length(deg_file_list), N1, length(t));
f_peaks = zeros(length(deg_file_list), 3, 2);
for ii = 1 : length(deg_file_list)
    cur_filename = strcat(folder_path, deg_file_list(ii).name);
    P_temp = fliplr(open_ascii_radial_spectrum(cur_filename));
    P(ii, :, :) = P_temp(1:N1, :);
    
    %id1 = strfind(cur_filename, '_');
    %id2 = strfind(cur_filename, 'deg');
    %deg = str2double(cur_filename(id1(end)+1: id2-1));
    %id_put = find(ismember(angle_list, deg));
    %P(ii, :, :) = get_range_spec(cur_filename, r, R, N_range_cells, 'discrete');

end
P = squeeze(mean(P, 1));
figure(); imagesc(freq_norm, N1, P);
set(gca, 'YDir', 'Normal');
xlabel('Normalized Frequency [f_B]');
ylabel('Range cell');

[~, max_id] = max(P(:, 2364:end) , [], 2);
f_partial = freq_norm(2364:end);
f_pos = f_partial(max_id);
idx = round((f_pos - 1)/0.0032);
idx(idx>10)=NaN;
figure(); plot([1:N1], idx);
xlabel('Range cell');
ylabel('Indices distance from Bragg frequency');