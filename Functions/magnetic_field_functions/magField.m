function B = magField(r,M,R,L)
% Calculates the magnetic field strength at an point outside a cylindrical magnet using the elliptic integral model.
% r is the vector from the magnet's center to the target position in the magnet's coordinate frame.

% if nargin < 4
%     L = 62.4/2;
%     R = 68/2;
%     %L = 58e-3/2;
%     %R = 68e-3/2;
% end
% if nargin <2
%     M = 9.366138787219805e+8;
% end

x = r(1);
y = r(2);
z = r(3);
rho = norm([x y]);
B = zeros(3,1);
if rho == 0
    B(3) =4*pi*1e-7*M/2*((z+L)/sqrt((z+L)^2+R^2)-(z-L)/(sqrt((z-L)^2+R^2)));
    
else
    Br = B_rho(rho,z,M,R,L);
    Bz = B_z(rho,z,M,R,L);
    B(1) = x*Br/rho;
    B(2) = y*Br/rho;
    B(3) = Bz;
end


end