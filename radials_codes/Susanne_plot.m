addpath(genpath('C:\Giora\TAU\MEPlab\HF_Radar\Codes\Matlab'));
load('C:\Giora\TAU\MEPlab\HF_Radar\files\mat_files\4D_2021082.mat');

Fs = 1 / (t(2)-t(1)) ; % Sampling frequency
L = length(t);
f = Fs*(-L/2:L/2-1)/L;
freq_norm = f ./ fbragg;


% P_avg = zeros(floor(size(P_ang_norm, 1)/3)-1, length(t));
% counter = 1;
% for ii = 1 : 3 : size(P_ang_norm, 1)-1
%     
%     P_avg(counter, :) = mean(P_ang_norm(ii:ii+2, :), 1);
%     counter = counter + 1;
%     
% end
% 
% P_avg_movmean = movmean(P_avg, 5, 2);

%%

% times_str = string({'01:00', '02:00', '03:00', '04:00'...
%     , '05:00', '06:00', '07:00', '08:00','09:00', '10:00'...
%     , '11:00', '12:00', '13:00', '14:00','15:00', '16:00'...
%     , '17:00', '18:00', '19:00', '20:00','21:00', '22:00'...
%     , '23:00', '24:00'});

    filenames = string({...
        '0000_is1', '0020_is1', '0040_is1',...
        '0100_is1', '0120_is1', '0140_is1',...
        '0200_is1', '0220_is1', '0240_is1',...
        '0300_is1', '0320_is1', '0340_is1',...
        '0400_is1', '0420_is1', '0440_is1',...
    	'0500_is1', '0520_is1', '0540_is1',...
        '0600_is1', '0620_is1', '0640_is1',...
        '0700_is1', '0720_is1', '0740_is1',...
    	'0800_is1', '0820_is1', '0840_is1',...
        '0900_is1', '0920_is1', '0940_is1',...
        '1000_is1', '1020_is1', '1040_is1',...
        '1100_is1', '1120_is1', '1140_is1',...
        '1200_is1', '1220_is1', '1240_is1',...
    	'1300_is1', '1320_is1', '1340_is1',...
        '1400_is1', '1420_is1', '1440_is1',...
        '1500_is1', '1520_is1', '1540_is1',...
        '1600_is1', '1620_is1', '1640_is1',...
        '1700_is1', '1720_is1', '1740_is1',...
        '1800_is1', '1820_is1', '1840_is1',...
    	'1900_is1', '1920_is1', '1940_is1',...
        '2000_is1', '2020_is1', '2040_is1',...
        '2100_is1', '2120_is1', '2140_is1',...
        '2200_is1', '2220_is1', '2240_is1',...
        '2300_is1', '2320_is1', '2340_is1'});

%%

mat_flag = 1 ;

if mat_flag == 1
    P_3d_0 = zeros(size(P_day, 1), size(P_day, 3), size(P_day, 2));
    P_3d_1 = zeros(size(P_day, 1), size(P_day, 3), size(P_day, 2));
    for ii = 1 : size(P_day, 1)

        for jj = 1 : size(P_day, 2)

            cur_spec = squeeze(P_day(ii, jj, :, :));

            for kk = 1 : size(cur_spec, 1)

                cur_1D = cur_spec(kk, :);
                [f_peaks, ~, ~] = find_ivonin_peaks(cur_1D, [0 1], freq_norm, 0, 'centroid');
                P_3d_0(ii, kk, jj) = f_peaks(1);
                P_3d_1(ii, kk, jj) = f_peaks(2);

            end

        end

    end

    mat_fname = strcat('C:\Users\giora\SynologyDrive\raw_spectrum\mat_files\P_3d_cent.mat');
    save(mat_fname, 'P_3d_0', 'P_3d_1');

else
    
    load('C:\Users\giora\SynologyDrive\raw_spectrum\mat_files\P_3d.mat');
    
end


%%
lamda_EM = 3e8 / 8.3e6 ;
lambda_bragg = lamda_EM / 2;

is_video = 0;
if is_video == 1
    obj = VideoWriter('current_animation_movemean3.avi');
    obj.Quality = 100;
    obj.FrameRate = 10;
    open(obj);
end

ids = length(freq_norm)/2-20: length(freq_norm)/2+20;
f_partial = freq_norm(ids);
P = P_day;
%U_all = zeros(size(P_avg_movmean,1), 2);
plot_mat = zeros(size(P, 3), size(P, 2));
figure();

for ii = 1 : size(P, 1)
    
    cur_P = squeeze(P(ii, :, :, :));
    
    for ang = 1 : size(cur_P, 1)
        
        cur_ang = squeeze(cur_P(ang, :, :));
        
        for rr = 4 : size(cur_ang, 1)
        
            [f_peaks, ~, ~] = find_ivonin_peaks(cur_ang(rr, :), [0 1], freq_norm, 0, 'max');
            plot_mat(rr, ang) = f_peaks(1);
            
        end
 
    end
    
    imagesc(plot_mat);
    xlabel('Angle [\circ]');
    ylabel('Range Cell');
    set(gca, 'xtick', [1:2:21], 'xticklabel', string([-10:2:10]))
    set(gca, 'ytick', [1:10], 'yticklabel', string([10:-1:0]))
    cur_str = char(filenames(ii));
    cur_str = char(cur_str(1:4));
    title(cur_str);
    %caxis([-0.005 0.005]);
    colorbar();
    pause(0.5);
    
end
