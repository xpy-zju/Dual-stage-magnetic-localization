function output = jacobian_ui(usi,uMi,thetasi,thetaMi,M,sz) 
%Ju，First-stage Jacobian: compute the Jacobian with respect to the position for a single sensor.
%usi: Position vector of the i-th sensor in the global coordinate frame (to be estimated).
%uMi: Position vector of the permanent magnet in the i-th step in the global coordinate frame (known).
%thetasi: Orientation vector of the i-th sensor in the global coordinate frame (to be estimated).
%thetaMi Position vector of the i-th sensor in the global coordinate frame (known).
%M magnetic moment (Known)
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