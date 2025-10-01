function [dB,dBrr,dBrz] = magGradient(r,M,R,L)
%MAGGRADIENT Calculate the magnetic field gradient at an arbitrary point outside a cylindrical magnet 
% using the elliptic integral model.
if nargin < 4
    %L = 58.5e-3/2;
    %R = 68.2e-3/2;
    L = 62.4/2;
    R = 68/2;
elseif nargin <2
    M = 9.366138787219805e+8;
end

rho = norm(r(1:2));
x = r(1);
y = r(2);
z = r(3);
mu0 = 4*pi*1e-7;


xip = z+L;
xin = z-L;
ap = 1/sqrt(xip^2+(rho+R)^2);
an = 1/sqrt(xin^2+(rho+R)^2);

kp = sqrt((xip^2+(rho-R)^2)/(xip^2+(rho+R)^2));
kn = sqrt((xin^2+(rho-R)^2)/(xin^2+(rho+R)^2));

kpc = sqrt(1-kp^2);
EP = EllipticE(kpc);
KP = EllipticK(kpc);
P1P = KP-2/kpc^2*(KP-EP);
darp = -(R+rho)/(xip^2+(R+rho)^2)^(3/2);
AP = (-1/kpc+4/kpc^3)*KP+(1/kp^2)*(1/kpc-2/kpc^3)*EP-2/kpc^3*EP;
dkcrp = sqrt(R/rho)*(R^2+xip^2-rho^2)/(xip^2+(R+rho)^2)^1.5;
%dkcrp = R*(R^2+xip^2-rho^2)/(sqrt((R*rho)/(R^2+xip^2+2*R*rho+rho^2))*(R^2+xip^2+2*R*rho+rho^2)^2);

RP = darp*P1P+ap*AP*dkcrp;

dazp = -xip/(xip^2+(R+rho)^2)^(3/2);
dkczp = -2*xip*sqrt(R*rho)/(xip^2+(R+rho)^2)^1.5;
ZP = dazp*P1P+ap*AP*dkczp;

knc = sqrt(1-kn^2);
EN = EllipticE(knc);
KN = EllipticK(knc);
P1N = KN-2/knc^2*(KN-EN);
darn = -(R+rho)/(xin^2+(R+rho)^2)^(3/2);
AN = (-1/knc+4/knc^3)*KN+(1/kn^2)*(1/knc-2/knc^3)*EN-2/knc^3*EN;
dkcrn = sqrt(R/rho)*(R^2+xin^2-rho^2)/(xin^2+(R+rho)^2)^1.5;
%dkcrn = R*(R^2+xin^2-rho^2)/(sqrt((R*rho)/(R^2+xin^2+2*R*rho+rho^2))*(R^2+xin^2+2*R*rho+rho^2)^2);

RN= darn*P1N+an*AN*dkcrn;
dazn = -xin/(xin^2+(R+rho)^2)^(3/2);
dkczn = -2*xin*sqrt(R*rho)/(xin^2+(R+rho)^2)^1.5;
ZN = dazn*P1N+an*AN*dkczn;

K = mu0*M*R/pi;

dBrr = K*(RP-RN);
dBrz = K*(ZP-ZN);


Br = B_rho(rho,z,M,R,L);
dBxx = (1/rho-x^2/rho^3)*Br+x^2/rho^2*dBrr;
dByy = (1/rho-y^2/rho^3)*Br+y^2/rho^2*dBrr;
dBxy = -x*y/rho^3*Br+x*y/rho^2*dBrr;
dBxz = x/rho*dBrz;
dByz = y/rho*dBrz;

dB = zeros(3,3);
dB(1,1) = dBxx;
dB(2,2) = dByy;
dB(3,3) = -(dBxx+dByy);
dB(1,2) = dBxy;
dB(2,1) = dBxy;
dB(1,3) = dBxz;
dB(3,1) = dBxz;
dB(2,3) = dByz;
dB(3,2) = dByz;
end

