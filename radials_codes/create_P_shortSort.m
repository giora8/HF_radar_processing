addpath(genpath('..\'));

%% generate short sort mat file

days = string({'2022039'});
short_params = "short_1024_shift_1024_range_100";
HF_station = 'is1'; %is1: Ashkelon, is2: Ashdod

hhmms = string({...
               '0000', '0020', '0040', '0100', '0120', '0140', '0200',...
               '0220', '0240', '0300', '0320', '0340', '0400', '0420',...
               '0440', '0500', '0520', '0540', '0600', '0620', '0640',...
               '0700', '0720', '0740', '0800', '0820', '0840', '0900',...
               '0920', '0940', '1000', '1020', '1040', '1100', '1120',...
               '1140', '1200', '1220', '1240', '1300', '1320', '1340',...
               '1400', '1420', '1440', '1500', '1520', '1540', '1600',...
               '1620', '1640', '1700', '1720', '1740', '1800', '1820',...
               '1840', '1900', '1920', '1940', '2000', '2020', '2040',...
               '2100', '2120', '2140', '2200', '2220', '2240', '2300',...
               '2320', '2340'});

%splits = hhmms(31:40);
splits = hhmms(31:33);

% coordinate of interest
%ADCP_shallow = [34.532972 31.670556];
%ADCP_deep = [34.512833 31.681639];
in_front_ASH = [34.58777539086895 31.854180076569225];
in_situ = [34.4092 31.8135];  % 8/2/22 Vector, ADCP, Drone measurements

N_range_cells = 1;  % number of range cell to average
N_angs = 0;  % number of angles to average (2*N_ang + 1)

for ii = 1 : length(days)
    sprintf('Starting day: %d out of %d', ii, length(days))
    day = days(ii);
    for jj = 1 : length(splits)
        sprintf('Starting split: %d out of %d', jj, length(splits))
        split_num = str2double(splits(jj));
        create_ShortSort_P(day, short_params, split_num, in_front_ASH, HF_station, N_range_cells, N_angs);
    end
end