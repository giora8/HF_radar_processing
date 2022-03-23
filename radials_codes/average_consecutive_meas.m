addpath(genpath('C:\Giora\TAU\MEPlab\HF_Radar\Codes\Matlab'));
%% params

ADCP_shallow = [34.532972 31.670556];
ADCP_deep = [34.512833 31.681639];
HF_station = [34.545 31.665];

N_range_cells = 1;
N_angs = 5;

[R, ANG] = get_station_angle_radi(HF_station, ADCP_deep);
%% r and t axes

filenames = string({'20210820000_is1', '20210820020_is1', '20210820040_is1', '20210820100_is1'...
    , '20210820120_is1', '20210820200_is1', '20210820220_is1', '20210820240_is1'...
    ,'20210820300_is1','20210820320_is1', '20210820340_is1', '20210820400_is1', '20210820420_is1'...
    , '20210820440_is1', '20210820500_is1', '20210820520_is1', '20210820540_is1', '20210820600_is1'...
    , '20210820620_is1', '20210820640_is1', '20210820700_is1', '20210820720_is1', '20210820740_is1'...
     '20210820800_is1', '20210820820_is1',  '20210820840_is1', '20210820900_is1', '20210820920_is1'...
     ,'20210820940_is1', '20210821000_is1', '20210821020_is1', '20210821040_is1'...
     , '20210821100_is1', '20210821120_is1', '20210821140_is1', '20210821200_is1', '20210821220_is1'...
     ,'20210821240_is1', '20210821300_is1', '20210821320_is1', '20210821340_is1'...
     , '20210821400_is1', '20210821420_is1', '20210821440_is1', '20210821500_is1', '20210821520_is1'...
     , '20210821540_is1', '20210821600_is1', '20210821620_is1', '20210821640_is1', '20210821700_is1'...
     , '20210821720_is1', '20210821740_is1', '20210821800_is1', '20210821820_is1', '20210821840_is1'...
     , '20210821900_is1', '20210821920_is1', '20210821940_is1', '20210822000_is1', '20210822020_is1'...
     , '20210822040_is1', '20210822100_is1', '20210822120_is1', '20210822140_is1', '20210822200_is1'...
     , '20210822220_is1', '20210822240_is1', '20210822300_is1', '20210822320_is1', '20210822340_is1'});

folder_path = 'C:\Giora\TAU\MEPlab\HF_Radar\files\radials_ascii\';
filename = '20210821440_is1.SORT';
sort_filename = strcat(folder_path, filename);
[WERA,t,r,~,~] = read_WERA_sort(sort_filename);
f_bragg = WERA.fbragg;

Fs = 1 / (t(2)-t(1)) ; % Sampling frequency
L = length(t);
f = Fs*(-L/2:L/2-1)/L;

freq_norm = f ./ f_bragg;

%% average consecutive measurements
deg_path = 'C:\Giora\TAU\MEPlab\HF_Radar\files\deg_files\';
P_ang = zeros(length(filenames), length(t));

[~, id] = min(abs(freq_norm-1));
sub_id = id-90:1:id+90;
f_partial = freq_norm(sub_id);
%figure();
for ii = 1 : length(filenames)

    [deg_file_list, angle_list] = get_degrees_files(deg_path, filenames(ii), ANG, N_angs);
    P_to_avg = zeros(length(length(deg_file_list)), length(t));
    for jj = 1 : length(deg_file_list)
        
        cur_filename = strcat(deg_path, deg_file_list(jj).name);        
        P_to_avg(jj, :) = get_range_spec(cur_filename, r, R, N_range_cells, 'avg');
        
    end
    P_ang(ii, :) = mean(P_to_avg, 1);
    %P_ang(ii, :) = (P_ang(ii, :)-min(P_ang(ii, :))) ./ (max(P_ang(ii, :)) - min(P_ang(ii, :)));
    %plot(f_partial, P_ang(ii, sub_id));
    %hold on;
end
save('C:\Giora\TAU\MEPlab\HF_Radar\files\deg_files\mat_files\2021_083.mat','P_ang');

%ylim([0 1.05]);
%P_avg = mean(P_ang, 1);
 %%
 
[~, id] = min(abs(freq_norm-1));
sub_id = b-90:1:b+90;
f_partial = freq_norm(sub_id);
P_avg_partial = P_avg(sub_id);

figure(); plot(f_partial, P_ang(1, sub_id));
hold on; plot(f_partial, P_avg_partial);

jerk_avg = gradient(P_avg(sub_id));
jerk_1 = gradient(P_ang(1, sub_id));
jerk_2 = gradient(P_ang(2, sub_id));
jerk_3 = gradient(P_ang(3, sub_id));
jerk_4 = gradient(P_ang(4, sub_id));
std(jerk_1)
std(jerk_2)
std(jerk_3)
std(jerk_4)
std(jerk_avg)

%%

P_ang_mean = movmean(P_ang, 5, 2);
P_avg_movmean = mean(P_ang_mean, 1);

P_avg_movmean_partial = P_avg_movmean(sub_id);

figure(); plot(f_partial, P_ang_mean(2, sub_id));
hold on; plot(f_partial, P_avg_movmean_partial);

jerk_avg = gradient(P_avg_movmean(sub_id));
jerk_1 = gradient(P_ang_mean(1, sub_id));
jerk_2 = gradient(P_ang_mean(2, sub_id));
jerk_3 = gradient(P_ang_mean(3, sub_id));
jerk_4 = gradient(P_ang_mean(4, sub_id));
std(jerk_1)
std(jerk_2)
std(jerk_3)
std(jerk_4)
std(jerk_avg)

figure(); plot(f_partial, jerk_1, f_partial, jerk_avg);