function B = axisMagField(l,dl,L,R,M)
%This function calculates the theoretical magnetic field strength along the axis
if nargin<5
    M = 9.366138787219805e+8;
end
if nargin<4
    R = 68.2e-3/2;
end
if nargin<3
    L = 58.5e-3/2;
end
if nargin<2
    dl = 0;
end
z = l+dl+L;
mu0 = 4*pi*1e-7;
B = mu0*M/2*((z+L)/sqrt((z+L)^2+R^2)-(z-L)/sqrt((z-L)^2+R^2));
end

