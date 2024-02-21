function out_map = adcp_exp_fit(HF_map, adcp_map, ini_idx, fin_idx, beta)
%% Inputs
% HF_map - container of the HF measurements on a radial
% adcp_map - container of the ADCP measurements on a radial
% ini_idx
% fin_idx
%% Output
% out_map - adcp measurements including fit profile for specified period
% 
out_map = adcp_map;
fun = @(params, x) params(1) * exp(params(2) * x);

z = [adcp_map('z') ; 0];
high_res_depth = 0:-0.01:z(1);
[~, ind] = min(abs(high_res_depth + 0.15));
Vr = adcp_map('Vr');
alpha_hat_uppermost = zeros(1, size(Vr, 2));
for ii = 1 : size(Vr, 2)
    if ii >= ini_idx && ii <= fin_idx
        cur_Vr = [Vr(:, ii); beta(ii)];
        initial_guess = [beta(ii), 1];
        params_fit = lsqcurvefit(fun, initial_guess, z(38:end), double(cur_Vr(38:end)));
        fitted_curve = params_fit(1) * exp(params_fit(2) * high_res_depth);
        gradient_Vr = gradient(fitted_curve, high_res_depth);
        alpha_hat_uppermost(ii) = mean(gradient_Vr(1:ind));
    else
        alpha_hat_uppermost(ii) = 0;
    end
end
out_map('alpha_hat_upper') = alpha_hat_uppermost;
end