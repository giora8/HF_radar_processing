function output_map = adcp_gradientor(config, input_map, surface_current_HF)
%% Inputs
% config - system and run configuration
% input_map - container map including ADCP measurements
%% Output
% output_map - same container_map with additional field of shear paremeter
% value from uppermost layer of adcp (defined in config)
% 
fun = @(params, x) params(1) * exp(params(2) * x);
output_map = input_map;
z = input_map('z');
z_with_surface = [z ; 0];
high_res_z = 0:-0.01:z(1);

Vr = input_map('Vr');
alpha_hat = zeros(1, size(Vr, 2));
alpha_hat_uppermost = zeros(1, size(Vr, 2));
max_depth = config.ADCP.gradient_calculation.max_depth;
max_depth_fit = config.ADCP.gradient_calculation.max_depth_fit;
[~, ind] = min(abs(z + max_depth));
[~, ind_fit] = min(abs(high_res_z + max_depth_fit));
for ii = 1 : size(Vr, 2)
    cur_profile = Vr(:, ii);
    gradient_Vr = gradient(cur_profile, z);
    alpha_hat(ii) = mean(gradient_Vr(ind:end));

    % fit to exponential profile
    Vr_with_surface = [Vr(:, ii); surface_current_HF(ii)];
    initial_guess = [surface_current_HF(ii), 1];
    params_fit = lsqcurvefit(fun, initial_guess, z_with_surface(38:end), double(Vr_with_surface));
    fitted_curve = params_fit(1) * exp(params_fit(2) * high_res_z);
    gradient_Vr_fit = gradient(fitted_curve, high_res_z);
    alpha_hat_uppermost(ii) = mean(gradient_Vr_fit(1:ind_fit));
end
output_map('alpha_hat') = alpha_hat;
output_map('alpha_hat_upperlayer_fit') = alpha_hat_uppermost;
end
