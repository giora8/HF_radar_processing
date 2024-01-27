function SORT2matrix(config, wera_day)
%% Inputs
% config - system and run configuration
% wera_day - YYYYDDD format (example: '2021083')
%% Save
% P_day - spectrum of all range in the .asc file
% t_day - matrix of all time axes for each measurement of the day
% fbragg_day - vector containing the bragg frequency for each measurement
% f0_day - vector containing the transmitted frequency for each measurement
% the function save all variables under a filename YYYYDDD at the run
% dedicated folder
%
%%
HF_station_to_run = config.extraction_configuration.HF_station;
HF_station_to_run_name = config.sys_config.(HF_station_to_run).name;
HF_station_coord = config.sys_config.(HF_station_to_run).coordinate';
HF_station_az = config.sys_config.(HF_station_to_run).boresight_angle_azimuth;
target_coord = config.extraction_configuration.point_of_interest';

N_angs = config.extraction_configuration.number_of_angles_each_side;
N_range_cells = config.extraction_configuration.number_of_range_cells;

year_day = char(wera_day);
day = year_day(5:end);
year = year_day(1:4);
sort_file_path = fullfile(config.sys_config.(HF_station_to_run).SORT_path, year, day);

timestamps = create_station_timestamps_array(HF_station_to_run_name);
filenames = strcat(wera_day, timestamps);
target_path = fullfile(config.sys_config.SORT_ascii_path, wera_day);

[R, ANG] = get_station_angle_radi(HF_station_coord, target_coord, HF_station_az);

fname_sort_path = char(fullfile(sort_file_path, strcat(filenames(1), '.SORT')));
[~,t,~,~,~] = read_WERA_sort_partial(fname_sort_path);

P_day = zeros(length(filenames), length(t));  % [# of measurement a day X time_dim]
t_day = zeros(length(filenames), length(t));
fbragg_day = zeros(length(filenames), 1);
f0_day = zeros(length(filenames), 1);

for ii = 1 : length(filenames)
    [deg_file_list, ~] = get_degrees_files(target_path, filenames(ii), ANG, N_angs);
    
    % get the radial axis for current measurement
    
    fname_sort_path = char(fullfile(sort_file_path, strcat(filenames(ii), '.SORT')));
    [WERA,t,r,~,~] = read_WERA_sort_partial(fname_sort_path);
    fbragg = WERA.fbragg;
    f0 = WERA.FREQ*10^6;
    
    % averaging over angles %
    P_ang = zeros(length(deg_file_list), length(t)); % [N_ang X time_dim]
    f = waitbar(0, sprintf('Starting measurement: %d out of %d', ii, length(filenames)));
    for jj = 1 : length(deg_file_list)
        
        cur_filename = fullfile(target_path, deg_file_list(jj).name);
        P_ang(jj, :) = get_range_spec(cur_filename, r, R, N_range_cells, 'avg');
        waitbar(jj/length(deg_file_list), f, sprintf('Angle progress: %d %% (%d/%d)', floor(jj/length(deg_file_list)*100), ii, length(filenames)));
    end
    close(f);
    P_day(ii, :) = mean(P_ang, 1);  % Average over all angles
    t_day(ii, :) = t;
    fbragg_day(ii) = fbragg;
    f0_day(ii) = f0;
    
end

new_dirname = strcat(HF_station_to_run_name, '_R_', num2str(R), '_Ncells_', num2str(N_range_cells), '_ang_', num2str(ANG-N_angs), '_', num2str(ANG+N_angs));
targetPath = fullfile(target_path, new_dirname);
if ~exist(targetPath, 'dir')
   mkdir(targetPath)
end

end
