function [alpha, beta] = evaluate_linear_shear_noninear_effect(c1, c2, r1, r2, c0)
    % c1: towards, c2: away, r1: onward ratio, r2: outward ratio, c0:
    % unperturbed value (positive)
    g = 9.81;
    k = g ./ (c0).^2;
    SC1 = r1.^2;
    SC2 = r2.^2;
    
    alpha1 = sqrt(((c1-c2).^2.*k-g.*SC1).^2 - 2.*g.*((c1-c2).^2.*k+g.*SC1).*SC2 + g.^2.*SC2.^2) ./ sqrt((c1-c2).^2);
    alpha2 = -sqrt(((c1-c2).^2.*k-g.*SC1).^2 - 2.*g.*((c1-c2).^2.*k+g.*SC1).*SC2 + g.^2.*SC2.^2) ./ sqrt((c1-c2).^2);
    
    beta1 = -c2 - sqrt(((c1-c2).^2.*k+g.*(-SC1+SC2)).^2) ./ sqrt(4.*k.^2.*(c1-c2).^2) - sqrt(((c1-c2).^2.*k-g.*SC1).^2 - 2.*g.*((c1-c2).^2.*k+g.*SC1).*SC2+g.^2.*SC2.^2) ./ sqrt(4.*k.^2.*(c1-c2).^2);
    beta2 = -c2 - sqrt(((c1-c2).^2.*k+g.*(-SC1+SC2)).^2) ./ sqrt(4.*k.^2.*(c1-c2).^2) + sqrt(((c1-c2).^2.*k-g.*SC1).^2 - 2.*g.*((c1-c2).^2.*k+g.*SC1).*SC2+g.^2.*SC2.^2) ./ sqrt(4.*k.^2.*(c1-c2).^2);
    
    alpha = [alpha1 alpha2];
    beta = [beta1 beta2];
    
end

