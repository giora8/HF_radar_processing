%% Not ready to use!
function [alpha, beta, m] = evaluate_shear(prof_type, U_neg, U_pos, c0,varargin)
    
    g = 9.82;
    c1 = c0 + U_pos;
    c2 = c0 + U_neg;
    k = g ./ c0.^2;
    
    switch prof_type
        case 'exp'
    
            if isempty(varargin)
                alpha = 0.5 * (U_neg + U_pos);
                alpha = round(alpha, 2);
            else
                alpha = varargin{1};
            end

            beta1 = 0.5 .* (c1 + c2 - sqrt((4.*c0.^2 + (c1 - c2).^2) .* (c1 - c2).^2.*k.^2)./((c1 - c2).*k) - 2.*alpha);
            m1 = (2.*(c1 - c2).^2.*k.^2)./(-sqrt((4.*c0.^2 + (c1 - c2).^2).*(c1 - c2).^2.*k.^2) + 2.*(c1 - c2).*k.*(c2 - alpha));
            %m1 = (-2.*sqrt((4 .* c0.^2 + (c1 - c2).^2).*(c1 - c2).^2 .* k.^2) + 4.*(c1 - c2).*k.*(c1 - alpha))./(4.*c0.^2 - (3.*c1 - c2 - 2.*alpha).*(c1 + c2 - 2.*alpha));

            beta2 = 0.5 .* (c1 + c2 + sqrt((4.*c0.^2 + (c1 - c2).^2) .* (c1 - c2).^2.*k.^2)./((c1 - c2).*k) - 2.*alpha);
            m2 =(2.*(c1 - c2).^2.*k.^2)./(sqrt((4.*c0.^2 + (c1 - c2).^2).*(c1 - c2).^2.*k.^2) + 2.*(c1 - c2).*k.*(c2 - alpha));
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
            alpha1 = 0.5 * (U_neg - U_pos - sqrt(-4.*c0.^2 + U_neg.^2 + 2.*U_neg .* U_pos + U_pos.^2));
            beta = 1;
            m1 = -(sqrt(-4.*c0.^2 + U_neg.^2 + 2.*U_neg.*U_pos + U_pos.^2)./(2.*c0));
            
            alpha2 = 0.5 * (U_neg - U_pos + sqrt(-4.*c0.^2 + U_neg.^2 + 2.*U_neg .* U_pos + U_pos.^2));
            m2 = (sqrt(-4.*c0.^2 + U_neg.^2 + 2.*U_neg.*U_pos + U_pos.^2)./(2.*c0));
            
            ind_imag = find(abs(imag(alpha1))>1e-5);
            
            alpha1(ind_imag) = NaN;
            alpha2(ind_imag) = NaN;
            
            m1(ind_imag) = NaN;
            m2(ind_imag) = NaN;                 
            
            id1 = find(m1 >= 0);
            id2 = find(m2 >= 0);
            
            alpha = zeros(length(alpha1), 1);
            m = zeros(length(m1), 1); 
            
            alpha(id1) = alpha1(id1);
            m(id1) = m1(id1);

            alpha(id2) = alpha2(id2);
            m(id2) = m2(id2);
            
         case 'arbitrary2'
             
             alpha = 0.5 .* (U_neg + U_pos - c0.*sqrt((4.*c0.^2 + U_neg.^2 - 2.*U_neg.*U_pos + U_pos.^2)./c0.^2));
             beta = 1 ;
             m = (-U_neg + U_pos)./(2.*c0);

    end
    
end

