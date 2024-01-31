%% get_basic_data_from_ADCP.m
function [u, v, z, t_matlab, Fs] = get_uvzt_from_ADCP(mat_filename)
%% Inputs
% mat_filename - path to .mat file of ocean viewer output (NOT from
% deployment)
%% Output
% u - [size(z) sizr(t_matlab)] east-west velocity
% v - [size(z) sizr(t_matlab)] south-north velocity
% z - vertical axis
% t - matlab time of the entire ADCP measurement
% Fs - sampling frequency of the ADCP
%
%------------------ names of all day measurements ------------------------%   
    try
        load(mat_filename);
        
        % cells unformation

        N_cells = Config.Instrument_burst_nCells;
        blanking_distance = Config.Instrument_burst_blankingDistance;  % [m]
        cell_size = Config.Instrument_burst_cellSize;  % [m]

        % matlab time

        t_matlab = Burst_Data.TimeMatlab;

        % sampling frequency

        Fs = 1 / seconds(diff(datetime([datestr(t_matlab(1));datestr(t_matlab(2))]))); % [1/s]

        % instrument pressure

        P = Burst_Data.Pressure;  % [dbar]

        % velocities [m/s]

        u = Burst_Data.BinMapVelEast;
        v = Burst_Data.BinMapVelNorth;

        % vertical axis

        P_bar = 0.1 .*P ;  % [bar]
        bar_seaWater_constant = 9.931170631574;  % bar to sea water colum depth converter
        P_meter = P_bar .* bar_seaWater_constant;

        mean_sensor_depth = mean(P_meter);

        bottom = mean_sensor_depth + blanking_distance;
        z = -double(bottom)+0.1 : double(cell_size) : -bottom+double(N_cells*cell_size);
 
    catch
        
        disp('File name not exist');
    
    end

    

    
end

