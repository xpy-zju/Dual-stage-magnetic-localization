function B = magDipoleField(r,m)
%MAGFIELD 计算圆柱形磁铁外部任意点的磁场强度，磁偶极子模型
%   r为磁场坐标系下中心点到目标位置的矢量
x = r(1);
y = r(2);
z = r(3);
nr = norm(r);
mu0 = 4*pi*1e-7;
B(1) = mu0*m/(4*pi)*3*x*z/nr^5;
B(2) = mu0*m/(4*pi)*3*y*z/nr^5;
B(3) = mu0*m/(4*pi)*(2*z^2-x^2-y^2)/nr^5;
B = reshape(B,[3,1]);
end