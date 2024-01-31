function adcp_map = adcp_extractor(fname)
%% Inputs
% fname - burstv .mat filename including ADCP data
%% Output
% adcp_map - ADCP data including 2D velocity component, vertical axis
% values and ADCP operating sampling frequency
% 
adcp_map = containers.Map;
[u, v, z, t_matlab, Fs] = get_uvzt_from_ADCP(fname);
adcp_map('u') = u;
adcp_map('v') = v;
adcp_map('z') = z;
adcp_map('matlab_time') = t_matlab;
adcp_map('datetime') = datetime(t_matlab+7200, 'ConvertFrom', 'posixtime');
adcp_map('ADCP_sampling_rate') = Fs;
    
end

