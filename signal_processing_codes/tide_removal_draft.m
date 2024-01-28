t = 0 : 0.01: 10;
w = 2*pi;
A = 1; B = 1; C = 1; D = 1;

u = A.*cos(w.*t) + B.*sin(w.*t);
v = C.*cos(w.*t) + D.*sin(w.*t);

R_pos = 0.5 * ((A+D)^2 + (C-D)^2)^0.5 ;
R_neg = 0.5 * ((A-D)^2 + (C+B)^2)^0.5 ;

major_axis = R_pos + R_neg;
minor_axis = R_pos - R_neg;

eps_pos = atan((C-D) / (A+D));
eps_neg = atan((C+B) / (A-D));

theta = 0.5 * (eps_pos + eps_neg);
phi = 0.5 * (eps_pos - eps_neg);

sentence = strcat('|R^+|=', num2str(R_pos), ' |R^-|=', num2str(R_neg)...
                  , ' major axis=', num2str(major_axis), ' minor axis='...
                  , num2str(minor_axis), '\theta=', num2str(theta)...
                  , ' \phi=', num2str(phi));
disp(sentence);

u_pos = 0.5*(A+B).*exp(1i.*w.*t);
u_neg = 0.5*(A-B).*exp(-1i.*w.*t);

v_pos = 0.5*(C+D).*exp(1i.*w.*t);
v_neg = 0.5*(C-D).*exp(-1i.*w.*t);

figure(); plot(u_pos, v_pos);

