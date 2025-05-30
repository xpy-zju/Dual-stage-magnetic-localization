function output = jacobian_ui(usi,uMi,thetasi,thetaMi,M,sz) 
%Jtheta，第一阶段的雅可比，对姿态us求雅可比，针对单一传感器
%usi 第i个传感器的位置矢量（全局坐标系下）(待估计量）
%uMi 第i次大磁铁的位置矢量（全局）（已知量）
%thetasi 第i个传感器的姿态矢量（全局）（待估计量）
%thetaMi 第i次传感器的姿态矢量（全局）（已知量）
%M 大磁铁磁矩（已知量，标定得出）
% if nargin <6
%     sz = [9.7/2, 10/2];
% end
Rso = expm(-skew(thetasi));
RoM = expm(skew(thetaMi));
RMo = RoM';
RsM = Rso*RoM;
rM = RMo*(usi-uMi);
H = magGradient(rM,M*1e12,sz(2),sz(1));
output = RsM*H*RMo;
end