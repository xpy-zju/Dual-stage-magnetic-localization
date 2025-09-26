function output = jacobian_k(usi,uMi,thetasi,thetaMi,sz)
%Jk, Deprecated
Rso = expm(-skew(thetasi));
RoM = expm(skew(thetaMi));
RMo = RoM';
RsM = Rso*RoM;
rM = RMo*(usi-uMi);
output = RsM*magField(rM,1e12,sz(2),sz(1));
%output = zeros(3,1);
end