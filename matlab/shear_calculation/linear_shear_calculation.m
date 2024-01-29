function solution_map = linear_shear_calculation(input_map)
%% Inputs
% input_map - container holds c1, c2 and c0 values
%% Output
% solution_map - container hold two sets of solution according to linear
% shear model

solution_map = containers.Map;
global_params;
c0 = input_map('c_unperturbed');
c1 = input_map('c_negative_peak');
c2 = input_map('c_positive_peak');
k = g ./ (c0).^2;

solution_map('alpha1') = sqrt(-4.*g.*k+(c1-c2).^2.*k.^2);
solution_map('beta1') = 0.5 .* (c1 + c2 + sqrt(-4.*g + (c1 - c2).^2.*k)./sqrt(k));

solution_map('alpha2') = -sqrt(-4.*g.*k+(c1-c2).^2.*k.^2);
solution_map('beta2') = 0.5 .* (c1 + c2 - sqrt(-4.*g + (c1 - c2).^2.*k)./sqrt(k));

end

