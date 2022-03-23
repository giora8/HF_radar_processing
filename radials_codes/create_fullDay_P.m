%% open_ascii_radial_spectrum.m
function P_day = create_fullDay_P(wera_day, destination_coord, HF_station_id, N_range_cells, N_angs, sort_file_path)
%% Inputs
% wera_day - YYYYDDD format (example: '2021083')
%% Output
% P - spectrum of all range in the .asc file
%
%------------------ names of all day measurements ------------------------%

    filenames = string({...
        strcat('0000_', HF_station_id), strcat('0020_', HF_station_id),...
        strcat('0040_', HF_station_id), strcat('0100_', HF_station_id),...
        strcat('0120_', HF_station_id), strcat('0140_', HF_station_id),...
        strcat('0200_', HF_station_id), strcat('0220_', HF_station_id),...
        strcat('0240_', HF_station_id), strcat('0300_', HF_station_id),...
        strcat('0320_', HF_station_id), strcat('0340_', HF_station_id),...
        strcat('0400_', HF_station_id), strcat('0420_', HF_station_id),...
        strcat('0440_', HF_station_id), strcat('0500_', HF_station_id),...
        strcat('0520_', HF_station_id), strcat('0540_', HF_station_id),...
        strcat('0600_', HF_station_id), strcat('0620_', HF_station_id),...
        strcat('0640_', HF_station_id), strcat('0700_', HF_station_id),...
        strcat('0720_', HF_station_id), strcat('0740_', HF_station_id),...
        strcat('0800_', HF_station_id), strcat('0820_', HF_station_id),...
        strcat('0840_', HF_station_id), strcat('0900_', HF_station_id),...
        strcat('0920_', HF_station_id), strcat('0940_', HF_station_id),...
        strcat('1000_', HF_station_id), strcat('1020_', HF_station_id),...
        strcat('1040_', HF_station_id), strcat('1100_', HF_station_id),...
        strcat('1120_', HF_station_id), strcat('1140_', HF_station_id),...
        strcat('1200_', HF_station_id), strcat('1220_', HF_station_id),...
        strcat('1240_', HF_station_id), strcat('1300_', HF_station_id),...
        strcat('1320_', HF_station_id), strcat('1340_', HF_station_id),...
        strcat('1400_', HF_station_id), strcat('1420_', HF_station_id),...
        strcat('1440_', HF_station_id), strcat('1500_', HF_station_id),...
        strcat('1520_', HF_station_id), strcat('1540_', HF_station_id),...
        strcat('1600_', HF_station_id), strcat('1620_', HF_station_id),...
        strcat('1640_', HF_station_id), strcat('1700_', HF_station_id),...
        strcat('1720_', HF_station_id), strcat('1740_', HF_station_id),...
        strcat('1800_', HF_station_id), strcat('1820_', HF_station_id),...
        strcat('1840_', HF_station_id), strcat('1900_', HF_station_id),...
        strcat('1920_', HF_station_id), strcat('1940_', HF_station_id),...
        strcat('2000_', HF_station_id), strcat('2020_', HF_station_id),...
        strcat('2040_', HF_station_id), strcat('2100_', HF_station_id),...
        strcat('2120_', HF_station_id), strcat('2140_', HF_station_id),...
        strcat('2200_', HF_station_id), strcat('2220_', HF_station_id),...
        strcat('2240_', HF_station_id), strcat('2300_', HF_station_id),...
        strcat('2320_', HF_station_id), strcat('2340_', HF_station_id),...
        });
    
    filenames = strcat(wera_day, filenames);

%----%

basic_path = 'Z:\radials_spectrum\';
day_path = strcat(basic_path, wera_day, '\');

if strcmp(HF_station_id, 'is1')
    HF_station = [34.545 31.665]; % (longitude, latitude) - ASHKELON
else
    HF_station = [34.63583 31.83055]; % (longitude, latitude) - ASHDOD
end

%------------------- generating P  matrix (2D array) ---------------------%

[R, ANG] = get_station_angle_radi(HF_station, destination_coord);
year_day = char(wera_day);
day = year_day(5:end);
year = year_day(1:4);
sort_file_path = strcat(sort_file_path, year, '\',day, '\');
fname_sort_path = char(strcat(sort_file_path, filenames(1), '.SORT'));
[~,t,~,~,~] = read_WERA_sort_partial(fname_sort_path);

deg_folder_path = strcat(basic_path, wera_day, '\');
P_day = zeros(length(filenames), length(t));  % [# of measurement a day X time_dim]
t_day = zeros(length(filenames), length(t));
fbragg_day = zeros(length(filenames), 1);

    for ii = 1 : length(filenames)
        [deg_file_list, ~] = get_degrees_files(deg_folder_path, filenames(ii), ANG, N_angs);
        
        % get the radial axis for current measurement
        
        fname_sort_path = char(strcat(sort_file_path, filenames(ii), '.SORT'));
        [WERA,t,r,~,~] = read_WERA_sort_partial(fname_sort_path);
        fbragg = WERA.fbragg;
        
        % averaging over angles %
        P_ang = zeros(length(deg_file_list), length(t)); % [N_ang X time_dim]
        f = waitbar(0, sprintf('Starting measurement: %d out of %d', ii, length(filenames)));
        for jj = 1 : length(deg_file_list)
            
            cur_filename = strcat(deg_folder_path, deg_file_list(jj).name);
            P_ang(jj, :) = get_range_spec(cur_filename, r, R, N_range_cells, 'avg');
            waitbar(jj/length(deg_file_list), f, sprintf('Angle progress: %d %% (%d/%d)', floor(jj/length(deg_file_list)*100), ii, length(filenames)));
        end
        close(f);
        P_day(ii, :) = mean(P_ang, 1);  % Average over all angles
        t_day(ii, :) = t;
        fbragg_day(ii) = fbragg;
        
    end

new_dirname = strcat(HF_station_id, '_R_', num2str(R), '_ang_', num2str(ANG-N_angs), '_', num2str(ANG+N_angs));
targetPath = strcat(basic_path, new_dirname);
if ~exist(targetPath, 'dir')
   mkdir(targetPath)
end

mat_fname = strcat(targetPath, '\', wera_day, '.mat');
save(mat_fname, 'P_day', 't_day', 'fbragg_day');
    
end

