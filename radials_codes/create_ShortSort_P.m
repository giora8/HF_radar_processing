%% create_ShortSort_P.m
function P_shortSort = create_ShortSort_P(syn_path, wera_day, params_path, hhmm, destination_coord, HF_station_id, N_range_cells, N_angs)
%% Inputs
% syn_path - Synology drive path ('Z:')
% wera_day - YYYYDDD format (example: '2021083')
% params_path - (str) path to relevant folder of relevant short sort
% parameters
% hhmm - (str) time in format of hhmm
% destination_coord - [longitude latitude] coordinates of the target
% HF_station_id - (string) station name 'is1' or 'is2'
% N_range_cells - (int) number of distances to average
% N_angs - (int) number of angles to average
%% Output
% P_shortSort - spectrum of all range in the .asc file
%

    id_bar = strfind(params_path, '_');
    params_path = char(params_path);
    size_t = str2double(params_path(id_bar(1)+1: id_bar(2)-1));
        
    if strcmp(HF_station_id, 'is1')
        HF_station = [34.545 31.665]; % (longitude, latitude) - ASHKELON
    else
        HF_station = [34.63583 31.83055]; % (longitude, latitude) - ASHDOD
    end
    
    basic_path = strcat(syn_path, '\radials_spectrum_shortSort\');
    day_path = strcat(basic_path, params_path, '\', HF_station_id, '\', wera_day, '\');
    
    [R, ANG] = get_station_angle_radi(HF_station, destination_coord);
    year_day = char(wera_day);
    day = year_day(5:end);
    year = year_day(1:4);
    
    % extract information from basic SORT file
    if length(char(string(hhmm))) == 3
        hhmm_char = strcat('0', string(hhmm));
    else
        hhmm_char = string(hhmm);
    end
    sort_path = char(strcat(syn_path, '\data\', HF_station_id, '\raw\', year, '\', day, '\', wera_day, hhmm_char, '_', HF_station_id, '.SORT'));
    [WERA,~,~,~,~] = read_WERA_sort_partial(sort_path);
    fbragg = WERA.fbragg;
    f0 = WERA.FREQ*10^6;
    
    hhmm_char = char(hhmm_char);
    partial_char = hhmm_char(1:3);
    
    deg_folder_path = strcat(day_path, wera_day, partial_char);
    filenames1 = dir(strcat(deg_folder_path, '*.*'));
    
    hhmm = hhmm + 10;
    if length(char(string(hhmm))) == 3
        hhmm_char = strcat('0', string(hhmm));
    else
        hhmm_char = string(hhmm);
    end
    
    hhmm_char = char(hhmm_char);
    partial_char = hhmm_char(1:3);
    
    deg_folder_path = strcat(day_path, wera_day, partial_char);
    filenames2 = dir(strcat(deg_folder_path, '*.*'));
    
    file_list = [filenames1 ; filenames2];
    file_list_names = {file_list.name};
    file_list_names_unique = extractBetween(file_list_names, 1, 13);
    file_list_names_unique = unique(file_list_names_unique);
    
    P_shortSort = zeros(length(file_list_names_unique), size_t);   
    for ii = 1 : length(file_list_names_unique)
        
        first_name = strcat(file_list_names_unique{ii}, '_', HF_station_id) ;
        sort_path = char(strcat('Z:\data\', HF_station_id, '\shortSORT\', params_path, '\', wera_day, '\shortSORT_', char(string(hhmm-10)), '\', first_name, '.SORT'));
        if ii == 1
            [~,t,r,~,~] = read_WERA_sort_partial(sort_path);
        end
        
        [deg_file_list, ~] = get_degrees_files(day_path, first_name, ANG, N_angs);
        P_ang = zeros(length(deg_file_list), size_t);
        for jj = 1 : length(deg_file_list)       
            cur_filename = strcat(day_path, deg_file_list(jj).name);
            P_ang(jj, :) = get_range_spec(cur_filename, r, R, N_range_cells, 'avg');
        end
        P_shortSort(ii, :) = mean(P_ang, 1);  % Average over all angles
        
    end
    
    new_dirname = strcat('\', HF_station_id, '\R_', num2str(R),'_Ncells_', num2str(N_range_cells), '_ang_', num2str(ANG-N_angs), '_', num2str(ANG+N_angs));
    targetPath = strcat(basic_path, params_path, new_dirname);
    if ~exist(targetPath, 'dir')
       mkdir(targetPath)
    end

    mat_fname = strcat(targetPath, '\', wera_day, char(string(hhmm-10)), '.mat');
    save(mat_fname, 'P_shortSort', 't', 'fbragg', 'f0');

end

