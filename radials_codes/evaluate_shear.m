%% Not ready to use!
function [alpha, beta, m] = evaluate_shear(prof_type, U_neg, U_pos, c0,varargin)
    
    g = 9.81;
    %c1 = c0 + U_pos;
    %c2 = c0 + U_neg;
    c1=U_pos;
    c2=U_neg;
    %k = g ./ c0.^2;
    k = c0(:,1);
    
    switch prof_type
        case 'analytic'
            for ii = 1 : length(c1)
                [correct_value_c1, correct_value_c2, alphas, betas1, betas2] = find_real_results(g, k(ii), c1(ii), c2(ii), 0.017);
                if length(alphas) > 0
                    alpha1(ii) = mean(alphas);
                    alpha2(ii) = -mean(alphas);
                    
                    beta1(ii) = mean(betas1);
                    beta2(ii) = mean(betas2);
                else
                    alpha1(ii) = NaN;
                    alpha2(ii) = NaN;
                    beta1(ii) = NaN;
                    beta2(ii) = NaN;
                end
            end

%             alpha1 = -sqrt(k).* sqrt(-4.*g + (c1 - c2).^2.*k);
%             alpha2 = sqrt(k).* sqrt(-4.*g + (c1 - c2).^2.*k);
%             
             beta1 = 0.5 .* (c1 + c2 - sqrt(-4.*g + (c1 - c2).^2.*k)./sqrt(k));
%             beta2 = 0.5 .* (c1 + c2 + sqrt(-4.*g + (c1 - c2).^2.*k)./sqrt(k));
            alpha = [alpha1' alpha2'];
            beta = [beta1' beta2'];
            m=1;
        case 'exp_elingson'
            sqrt_term = (c1-c2).^2.*(c1-2.*c_0+c2).*(2.*c_0+c1+c2).*k.^2;
            beta1 = ((c1-c2).^2.*k+sqrt(sqrt_term))/(2.*(c1-c2).*k);
            beta2 = -((c1-c2).^2.*k+sqrt(sqrt_term))/(2.*(c1-c2).*k);
            
            m1 = -(2.*(8.*c0.^2.*k-2.*(c1+c2).^2.*k + sqrt(sqrt_term)))/(16.*c0.^2-(3.*c1+c2).*(c1+3.*c2));
            m2 = (2.*(8.*c0.^2.*k-2.*(c1+c2).^2.*k + sqrt(sqrt_term)))/(16.*c0.^2-(3.*c1+c2).*(c1+3.*c2));
        case 'exp'
    
            if isempty(varargin)
                alpha = 0.5 * (U_neg + U_pos);
                alpha = round(alpha, 2);
            else
                alpha = varargin{1};
            end

            beta1 = 0.5 .* (c1 + c2 - sqrt((4.*c0.^2 - (c1 - c2).^2) .* (c1 - c2).^2.*k.^2)./((c1 - c2).*k) - 2.*alpha);
            m1 = (2.*(c1 - c2).^2.*k.^2)./(-sqrt((4.*c0.^2 - (c1 - c2).^2).*(c1 - c2).^2.*k.^2) + 2.*(c1 - c2).*k.*(c2 - alpha));
            %m1 = (-2.*sqrt((4 .* c0.^2 + (c1 - c2).^2).*(c1 - c2).^2 .* k.^2) + 4.*(c1 - c2).*k.*(c1 - alpha))./(4.*c0.^2 - (3.*c1 - c2 - 2.*alpha).*(c1 + c2 - 2.*alpha));

            beta2 = 0.5 .* (c1 + c2 + sqrt((4.*c0.^2 - (c1 - c2).^2) .* (c1 - c2).^2.*k.^2)./((c1 - c2).*k) - 2.*alpha);
            m2 =(2.*(c1 - c2).^2.*k.^2)./(sqrt((4.*c0.^2 - (c1 - c2).^2).*(c1 - c2).^2.*k.^2) + 2.*(c1 - c2).*k.*(c2 - alpha));
            %m2 = (2.*sqrt((4 .* c0.^2 + (c1 - c2).^2).*(c1 - c2).^2 .* k.^2) + 4.*(c1 - c2).*k.*(c1 - alpha))./(4.*c0.^2 - (3.*c1 - c2 - 2.*alpha).*(c1 + c2 - 2.*alpha));

            id1 = find(abs(beta1) < abs(beta2));
            id2 = find(abs(beta1) > abs(beta2));

            beta = zeros(length(beta1), 1);
            m = zeros(length(m1), 1);

            beta(id1) = beta1(id1);
            beta(id2) = beta2(id2);

            m(id1) = m1(id1);
            m(id2) = m2(id2);  
            
        case 'lin'
            alpha = (c1-c2).*k;
            beta = 0.5 .* (c1 - c0.*sqrt(4 + (c1 - c2).^2./c0.^2) + c2);
            m=zeros(length(beta), 1);
            
        case 'arbitrary'
            alpha1 = 0.5 * (c2 + c1 - sqrt(-4.*g + (c1 - c2).^2 .* k)./sqrt(k));
            m1 = -(sqrt(-4.*g + (c1-c2).^2).*k./(2.*sqrt(g)));
            beta = 1;
            alpha2 = 0.5 * (c2 + c1 + sqrt(-4.*g + (c1-c2).^2 .* k)./sqrt(k));
            m2 = sqrt(-4.*g + (c1 - c2).^2).*k./(2.*sqrt(g));
            
            alpha = [alpha1 alpha2];
            beta = [m1 m2];
            m=1;
%             ind_imag = find(abs(imag(alpha1))>1e-5);
%             
%             alpha1(ind_imag) = NaN;
%             alpha2(ind_imag) = NaN;
%             
%             m1(ind_imag) = NaN;
%             m2(ind_imag) = NaN;                 
%             
%             id1 = find(m1 >= 0);
%             id2 = find(m2 >= 0);
%             
%             alpha = zeros(length(alpha1), 1);
%             m = zeros(length(m1), 1); 
%             
%             alpha(id1) = alpha1(id1);
%             m(id1) = m1(id1);
% 
%             alpha(id2) = alpha2(id2);
%             m(id2) = m2(id2);
            
         case 'arbitrary2'
             
             alpha = 0.5 .* (U_neg + U_pos - c0.*sqrt((4.*c0.^2 + U_neg.^2 - 2.*U_neg.*U_pos + U_pos.^2)./c0.^2));
             beta = 1 ;
             m = (-U_neg + U_pos)./(2.*c0);

    end
    
end

