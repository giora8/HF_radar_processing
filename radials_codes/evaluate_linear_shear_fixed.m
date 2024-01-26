function [alpha, beta] = evaluate_linear_shear_fixed(c1, c2, c0)
    % c1: towards, c2: away, r1: onward ratio, r2: outward ratio, c0:
    % unperturbed value (positive)
    g = 9.81;
    k = g ./ (c0).^2;
    
    alpha1 = sqrt(-4.*g.*k+(c1-c2).^2.*k.^2);
    alpha2 = -sqrt(-4.*g.*k+(c1-c2).^2.*k.^2);
    
    beta1 = 0.5 .* (-c1-c2+sqrt((-4.*g+(c1-c2).^2.*k)./k));
    beta2 = 0.5 .* (-c1-c2-sqrt((-4.*g+(c1-c2).^2.*k)./k));
    
    alpha = [alpha1 alpha2];
    beta = [beta1 beta2];
    
end