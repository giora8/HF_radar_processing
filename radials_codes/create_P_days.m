addpath(genpath('..\'));

%% generate full day mat file

days = string({'2021090'});
%days = string({'2022039'});

%ADCP_shallow = [34.532972 31.670556];
ADCP_deep = [34.512833 31.681639];  % coordinate of interest
in_front_ASH = [34.58777539086895 31.854180076569225];
%in_situ = [34.4092 31.8135];
HF_station = 'is1'; %is1: Ashkelon, is2: Ashdod

N_range_cells = 1;  % number of range cell to average
N_angs = 4;  % number of angles to average (2*N_ang + 1)

sort_file_path = strcat('Z:\data\', HF_station, '\raw\');  % is1: Ashkelon, is2: Ashdod

for ii = 1 : length(days)
    sprintf('Starting day: %d out of %d', ii, length(days))
    create_fullDay_P(days(ii), ADCP_deep, HF_station, N_range_cells, N_angs, sort_file_path);
end
