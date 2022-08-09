%% params

ADCP_shallow = [34.532972 31.670556];
ADCP_deep = [34.512833 31.681639];
HF_station = [34.545 31.665];

N_range_cells = 1;
N_angs = 6;

%% r and t axes

folder_path = 'C:\Giora\TAU\MEPlab\HF_Radar\files\radials_ascii\';
filename = '20210821440_is1.SORT';
sort_filename = strcat(folder_path, filename);
[WERA,t,r,~,~] = read_WERA_sort(sort_filename);
f_bragg = WERA.fbragg;
dr = r(2)-r(1);

Fs = 1 / (t(2)-t(1)) ; % Sampling frequency
L = length(t);
f = Fs*(-L/2:L/2-1)/L;

freq_norm = f ./ f_bragg;

%%

filenames = string({'20210820000_is1', '20210820020_is1', '20210820040_is1', '20210820100_is1'...
    , '20210820120_is1', '20210820200_is1', '20210820220_is1', '20210820240_is1'...
    ,'20210820300_is1','20210820320_is1', '20210820340_is1', '20210820400_is1', '20210820420_is1'...
    , '20210820440_is1', '20210820500_is1', '20210820520_is1', '20210820540_is1', '20210820600_is1'...
    , '20210820620_is1', '20210820640_is1', '20210820700_is1', '20210820720_is1', '20210820740_is1'...
     '20210820800_is1', '20210820820_is1',  '20210820840_is1', '20210820900_is1', '20210820920_is1'...
     , '20210820940_is1', '20210821000_is1', '20210821020_is1', '20210821040_is1'...
     , '20210821100_is1', '20210821120_is1', '20210821140_is1', '20210821200_is1', '20210821220_is1'...
     ,'20210821240_is1', '20210821300_is1', '20210821320_is1', '20210821340_is1'...
     , '20210821400_is1', '20210821420_is1', '20210821440_is1', '20210821500_is1', '20210821520_is1'...
     , '20210821540_is1', '20210821600_is1', '20210821620_is1', '20210821640_is1', '20210821700_is1'...
     , '20210821720_is1', '20210821740_is1', '20210821800_is1', '20210821820_is1', '20210821840_is1'...
     , '20210821900_is1', '20210821920_is1', '20210821940_is1', '20210822000_is1', '20210822020_is1'...
     , '20210822040_is1', '20210822100_is1', '20210822120_is1', '20210822140_is1', '20210822200_is1'...
     , '20210822220_is1', '20210822240_is1', '20210822300_is1', '20210822320_is1', '20210822340_is1'});

[R, ANG] = get_station_angle_radi(HF_station, ADCP_deep);

%%

lamda_EM = 3e8 / 8.3e6 ;
folder_path = 'C:\Giora\TAU\MEPlab\HF_Radar\files\deg_files\';
P_ang = zeros(length(filenames), length(t));
figure();
xline(1,'--k');
xlim([0.85 1.15]);
xlabel('Normalized Frequency [f_B]');
ylabel('Backscattered Power [dB]');

obj = VideoWriter('current_animation_movemean555.avi');
obj.Quality = 100;
obj.FrameRate = 10;
open(obj);
U_all = zeros(length(filenames), 1);
U_all_mean = zeros(length(filenames), 1);
for ii = 1 : length(filenames)
    [deg_file_list, angle_list] = get_degrees_files(folder_path, filenames(ii), ANG, N_angs);
    for jj = 1 : length(deg_file_list)
        cur_filename = strcat(folder_path, deg_file_list(jj).name);
               
        P_temp = get_range_spec(cur_filename, r, R, N_range_cells, 'avg');
        P_ang(ii, :) = P_ang(ii, :) + mean(P_temp, 1);
    end
    hold on; plot(freq_norm, P_ang(ii, :));
    [f_peaks, ~, ~] = find_ivonin_peaks(P_ang(ii, :), [1 -1], freq_norm, 0, 'max');
    f_diff = f_peaks - [1 -1];
    f_diff = f_diff .* f_bragg;
    
    f_diff_mean = f_peaks_mean - [1 -1];
    f_diff_mean = f_diff_mean .* f_bragg;
    
    lambda_bragg = lamda_EM / 2;
    U = lambda_bragg .* f_diff;
    U_string = num2str(U(1));
    U_string = U_string(1:5);
    
    U_mean = lambda_bragg .* f_diff_mean;
    
    cur_time = char(filenames(ii));
    cur_time = strcat(cur_time(8:9), ':', cur_time(10:11));
    title(strcat('Time: ', cur_time ,'  Current Velocity: ', U_string, ' m/s'));
    pause(0.05);
    f = getframe(gcf);
    writeVideo(obj, f);
    
    U_all(ii, 1) = U(1);
    U_all_mean(ii, 1) = U_mean(1);
    
end
%obj.close();
hold on; plot(freq_norm, mean(P_ang, 1));
x_plot = 1:length(U_all);
max(abs(max(U_all)), abs(min(U_all)))
figure(); hold on; scatter(x_plot, U_all);
scatter(x_plot, U_all_mean);

