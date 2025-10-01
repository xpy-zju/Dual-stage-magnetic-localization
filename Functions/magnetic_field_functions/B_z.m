function B = B_z(rho,z,M,R,L)
% calculate Bz in the form of elliptic integrals
% requires the elfun18 package to be installed.
if nargin < 5
    L =  62.4/2;
    R = 68/2;
elseif nargin <3
    M = 9.366138787219805e+8;
end
mu0 = 4*pi*1e-7;
if rho < 1e-10
    B = mu0*M/2*((z+L)/sqrt((z+L)^2+R^2)-(z-L)/sqrt((z-L)^2+R^2));
else

K = mu0*M*R/(pi*(rho+R));
xip = z+L;
xin = z-L;
ap = 1/sqrt(xip^2+(rho+R)^2);
an = 1/sqrt(xin^2+(rho+R)^2);
bp = xip*ap;
bn = xin*an;
kp = sqrt((xip^2+(rho-R)^2)/(xip^2+(rho+R)^2));
kn = sqrt((xin^2+(rho-R)^2)/(xin^2+(rho+R)^2));
gamma = (rho-R)/(rho+R);
B = K*(bp*P2(kp,gamma)-bn*P2(kn,gamma));
end
end


function output = P2(k,gamma)
kc = sqrt(1-k^2);
if gamma~=0
P  = EllipticPi(1-gamma^2,kc);
K = EllipticK(kc);
output = -gamma/(1-gamma^2)*(P-K)-1/(1-gamma^2)*(gamma^2*P-K);
else
K = EllipticK(kc);
output = K;
end
end