function output = Jacobian_2(m,um,thetam,us,thetas,ids)
n = length(ids);
%output = zeros(3*n,7);
output = zeros(3*n,5);
for i = 1:n
    id = ids(i);
    usi = us{id};
    thetasi = thetas{id};
    
    %output(3*i-2:3*i,:) = [jacobian2_m(um,thetam,usi,thetasi),jacobian2_u(m,um,thetam,usi,thetasi),jacobian2_theta(m,um,thetam,usi,thetasi)];
    output(3*i-2:3*i,:) = [jacobian2_u(m,um,thetam,usi,thetasi),jacobian2_theta(m,um,thetam,usi,thetasi)];%,jacobian2_m(um,thetam,usi,thetasi)];
end
end

function Jm = jacobian2_m(um,thetam,usi,thetasi)
Rsm = Exp(-thetasi)*Exp(thetam);
Rom = Exp(thetam);
Rmo = Rom';
r =     Rmo*(um-usi);
Jm = Rsm*magDipoleField(r,1e12);
end

function Ju = jacobian2_u(m,um,thetam,usi,thetasi)
    Rsim = Exp(-thetasi)*Exp(thetam);
    Rmo = Exp(-thetam);
    r = Rmo*(usi-um);
    H = magDipoleGradient(r,m*1e12);
    Ju = -Rsim*H*Rmo;
end

function Jt = jacobian2_theta(m,um,thetam,usi,thetasi)
    Rsim = Exp(-thetasi)*Exp(thetam);
    Rmo = Exp(-thetam);
    r = Rmo*(usi-um);
    H = magDipoleGradient(r,m*1e12);
    B = magDipoleField(r,m*1e12);
    Jt = -Rsim * skew(B)+Rsim*H*skew(r);
    Jt = Jt * Jr(thetam);
    Jt(:,end)=[];
end

function output = Jr(thetam)
    ntheta = norm(thetam);
    output = eye(3);
    output = output - (1-cos(ntheta))/ntheta^2*skew(thetam);
    output = output + (ntheta-sin(ntheta))/ntheta^3*skew(thetam)^2;
end
