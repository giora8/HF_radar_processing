function adcp_map = adcp_extractor(fname)
%% Inputs
% fname - burstv .mat filename including ADCP data
%% Output
% adcp_map - ADCP data including 2D velocity component, vertical axis
% values and ADCP operating sampling frequency
% 
adcp_map = containers.Map;
[u, v, z, t_matlab, Fs] = get_uvzt_from_ADCP(fname);
id_start = 1;
min_depth = find(u(:, size(u,2)/2)==0, 1);
adcp_map('u') = u(1: min_depth-1, id_start: end);
adcp_map('v') = v(1: min_depth-1, id_start: end);
adcp_map('z') = z(1, 1:min_depth-1)';
adcp_map('matlab_time') = t_matlab(id_start:end);
adcp_map('datetime') = datetime(t_matlab(id_start:end) , 'ConvertFrom', 'datenum');
adcp_map('ADCP_sampling_rate') = Fs;
    
end

