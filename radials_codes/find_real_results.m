function [correct_value_c1, correct_value_c2, alphas, betas1, betas2] = find_real_results(g, k, c1, c2, delta)
    
    analytic_sol_alpha = @(c1, c2) sqrt(k).* sqrt(-4.*g + (c1 - c2).^2.*k);
    beta1 = @(c1, c2) 0.5 .* (c1 + c2 - sqrt(-4.*g + (c1 - c2).^2.*k)./sqrt(k));
    beta2 = @(c1, c2) 0.5 .* (c1 + c2 + sqrt(-4.*g + (c1 - c2).^2.*k)./sqrt(k));
    
    correct_value_c1 = zeros(1, 1);
    correct_value_c2 = zeros(1, 1);
    alphas = zeros(1, 1);
    betas1 = zeros(1, 1);
    betas2 = zeros(1, 1);
    for v1 = -delta : 0.001 : delta
        for v2 = -delta : 0.001 : delta
            alpha = analytic_sol_alpha(c1-v1, c2-v2);
            if imag(alpha) == 0
                
                correct_value_c1(end+1) = c1-v1;
                correct_value_c2(end+1) = c2-v2;
                alphas(end+1) = alpha;
                betas1(end+1) = beta1(c1-v1, c2-v2);
                betas2(end+1) = beta2(c1-v1, c2-v2);
            end
        end
    end
    alphas = alphas(2:end);
    betas1 = betas1(2:end);
    betas2 = betas2(2:end);
end

