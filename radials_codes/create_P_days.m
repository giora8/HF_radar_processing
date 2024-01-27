addpath(genpath('..\'));

%% get data extraction params from config

fid = fopen('config.conf', 'r');
config = textscan(fid, '%s %s', 'Delimiter', '=', 'CommentStyle', '%');

%% generate full day mat file

Synology_path = config{2}{strcmp(config{1}, 'synology_path')};
days = string({'2021094','2021095','2021096','2021097','2021098','2021099','2021100','2021101','2021105', '2021106'});

%% point of interest

% ADCP implemented in front of
%Ashkelon May-June 2021
%ADCP_shallow = [34.532972 31.670556];
ADCP_deep = [34.512833 31.681639];  

%in_front_ASH = [34.58777539086895 31.854180076569225];
%in_situ = [34.4092 31.8135]; % Vector experiment February 8th 2022

%%

HF_station = 'is1'; %is1: Ashkelon, is2: Ashdod
N_range_cells = 1;  % number of range cell to average
N_angs = 4;  % number of angles to average (2*N_ang + 1)

sort_file_path = strcat(Synology_path, '\data\', HF_station, '\raw\');  % is1: Ashkelon, is2: Ashdod

for ii = 1 : length(days)
    sprintf('Starting day: %d out of %d', ii, length(days))
    create_fullDay_P(Synology_path, days(ii), ADCP_deep, HF_station, N_range_cells, N_angs, sort_file_path);
end
