%% create_4D_P.m
function P_day = create_4D_P(wera_day)
%% Inputs
% wera_day - YYYYDDD format (example: 2021083)
%% Output
% P - spectrum of all range in the .asc file
%
%------------------ names of all day measurements ------------------------%

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
    
    filenames = strcat(wera_day, filenames);


%------------------- generating P  matrix (2D array) ---------------------%

sort_folder_path = 'C:\Users\giora\SynologyDrive\raw_spectrum\2021082\20210820000_is1.SORT';
[WERA,t,r,~,~] = read_WERA_sort(sort_folder_path);
fbragg = WERA.fbragg;

%ADCP_shallow = [34.532972 31.670556];
ADCP_deep = [34.512833 31.681639];
HF_station = [34.545 31.665];

trans = -10:10;

N_range_cells = 10;
N_angs = 10;
deg_folder_path = 'C:\Users\giora\SynologyDrive\raw_spectrum\2021082\';
P_day = zeros(length(filenames), 2*N_angs+1, N_range_cells, length(t));

    for ii = 1 : length(filenames)
        [deg_file_list, angle_order] = get_degrees_files(deg_folder_path, filenames(ii), 0, N_angs);
        
        for jj = 1 : length(deg_file_list)
            id_ang = find(ismember(trans, angle_order(jj)));
            cur_filename = strcat(deg_folder_path, deg_file_list(jj).name);
            P_day(ii, id_ang, :, :) = get_range_spec(cur_filename, r, 0, N_range_cells, 'discrete');
        
        end
    end
mat_fname = strcat('C:\Giora\TAU\MEPlab\HF_Radar\files\mat_files\4D_', wera_day, '.mat');
save(mat_fname, 'P_day', 'r', 't', 'fbragg');
    
end

