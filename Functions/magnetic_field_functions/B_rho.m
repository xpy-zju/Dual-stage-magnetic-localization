function B = B_rho(rho,z,M,R,L)
% calculate Brho in the form of elliptic integrals
% requires the elfun18 package to be installed.
% L is 1/2 height of the cylinder
% R is the radius of the cylinder

% if nargin < 5
%     L = 62.4/2;
%     R = 68/2;
% end
% if nargin <3
%     M = 9.366138787219805e+8;
% 
% end
if rho == 0
    B = 0;
else
mu0 = 4*pi*1e-7;
K = mu0*M*R/pi;
xip = z+L;
xin = z-L;
ap = 1/sqrt(xip^2+(rho+R)^2);
an = 1/sqrt(xin^2+(rho+R)^2);

kp = sqrt((xip^2+(rho-R)^2)/(xip^2+(rho+R)^2));
kn = sqrt((xin^2+(rho-R)^2)/(xin^2+(rho+R)^2));
P1p = P1(kp);
P1n = P1(kn);
B = K*(ap*P1p-an*P1n);
end
end

function p1 = P1(k)
kc = sqrt(1-k^2);
epkc = EllipticK(kc);
epec = EllipticE(kc);
p1 = epkc-2/kc^2*(epkc-epec);

%p1 = EllipticK(kc)-2/kc^2*(EllipticK(kc)-EllipticE(kc));
end