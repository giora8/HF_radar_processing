%% get_degrees_files.m
function [deg_file_list, angle_list] = get_degrees_files(file_path, filename, closest_angle, num_of_angles)
%% Inputs
% file_path - directory of .deg files
% filename - .SORT filename of specific measurement (specific time)
% closest_angle - angle of the closest radial to the desired location
% num_of_angles - number of angles wants to be consider
%% Output
% deg_file_list - list of deg files wants to be consider
%
%--------- get all deg files related to specific .SORT file --------------%

    if contains(filename, '.SORT')
        filename = filename(1:end-5);
        file_list = dir(strcat(file_path, filename, '*.*'));  
    else
        %filename = filename(1:end-5);
        file_list = dir(strcat(file_path, filename, '*.*'));
    end

%------------- extract .deg files within wanted angle range --------------%

    deg_file_list = struct('name', '');
    angle_list = 0;
    for cur_file = 1 : length(file_list)

       cur_filename = file_list(cur_file).name;
       if strcmp(cur_filename(end-3:end), '.asc')
           id = strfind(cur_filename, '_');
           id = id(2);
           id_deg = strfind(cur_filename, 'deg');
           deg = str2double(cur_filename(id+1:id_deg-1));

           if deg <= closest_angle + num_of_angles && deg >= closest_angle - num_of_angles
               deg_file_list(end+1).name = cur_filename; %#ok<AGROW>
               angle_list(end+1) = deg; %#ok<AGROW>
           end

       end
    end
    angle_list = angle_list(2:end);
    deg_file_list = deg_file_list(2:end);
    
end