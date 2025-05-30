function Bs= get_Bs(uM,thetaM,uS,thetaS,M,G)
%GET_BS 获得永磁体施加在传感器处的磁场
%   uM ,thetaM 永磁体在全局（相机)坐标系中的位姿
%   uS,thetaS 传感器在全局（相机坐标系）中的位姿
%   M,磁矩
%   G，地磁，暂取消磁后的值
if nargin<6
    M = 1.100186666058454e+12;
end
if nargin<5
    G = zeros(3,1);
end
RSM = Exp(-thetaS)*Exp(thetaM);
RMO = Exp(-thetaM);
L = (20.8*3)/2;
R = 68/2;

r = RMO*(uS-uM);%单位mm
Bs = RSM*magField(r,M,R,L)+G;
end

