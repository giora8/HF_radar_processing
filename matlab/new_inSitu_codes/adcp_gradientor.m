function output_map = adcp_gradientor(config, input_map)
%% Inputs
% config - system and run configuration
% input_map - container map including ADCP measurements
%% Output
% output_map - same container_map with additional field of shear paremeter
% value from uppermost layer of adcp (defined in config)
% 
output_map = input_map;
z = input_map('z');
Vr = input_map('Vr');
alpha_hat = zeros(1, size(Vr, 2));
max_depth = config.ADCP.gradient_calculation.max_depth;
[~, ind] = min(abs(z + max_depth));
for ii = 1 : size(Vr, 2)
    cur_profile = Vr(:, ii);
    gradient_Vr = gradient(cur_profile, z);
    alpha_hat(ii) = mean(gradient_Vr(ind:end));
end
output_map('alpha_hat') = alpha_hat;
end

