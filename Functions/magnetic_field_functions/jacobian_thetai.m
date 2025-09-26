function output = jacobian_thetai(usi,uMi,thetasi,thetaMi,M,sz)
%Jtheta，First-stage Jacobian: compute the Jacobian with respect to the orientation angles for a single sensor.
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
rM = RMo*(usi-uMi);
B= magField(rM,M*1e12,sz(2),sz(1));
%Jr = @(th) eye(3)-(1-cos(norm(th))/norm(th)^2)*skew(th)+(norm(th)-sin(norm(th)))/norm(th)^3*skew(th)^2;
output = skew(Rso*RoM*B)*Jr(thetasi);
end

function output = Jr(th)
if norm(th)<1e-10
    output = eye(3);
    
else
    output = eye(3)-(1-cos(norm(th))/norm(th)^2)*skew(th)+(norm(th)-sin(norm(th)))/norm(th)^3*skew(th)^2;
end
end