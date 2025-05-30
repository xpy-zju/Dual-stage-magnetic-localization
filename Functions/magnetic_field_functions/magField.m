function B = magField(r,M,R,L)
%MAGFIELD 计算圆柱形磁铁外部任意点的磁场强度，椭圆积分模型
%   r为磁场坐标系下中心点到目标位置的矢量

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