function v = Log(R)
%Convert the rotation matrix into a Lie algebra–based orientation vector.
%Get the Log of  rotation matrix
tol = 1e-15;
if max(max(abs(R-eye(3))))<tol
    v = zeros(3,1);
    return
end

if (abs(trace(R)+1)<tol)&&(max(max(abs(R-R')))<tol)
    phi = pi;
    if ~((1+R(3,3))<tol)
        u = 1/sqrt(2*(1+R(3,3)))*[R(1,3);R(2,3);1+R(3,3)];
    elseif ~((1+R(2,2))<tol)
        u = 1/sqrt(2*(1+R(2,2)))*[R(1,2);1+R(2,2);R(3,2)];
    else 
        u = 1/sqrt(2*(1+R(1,1)))*[1+R(1,1);R(2,1);R(3,1)];
    end
    v = u*phi;
    return
end


inskew = @(R) [R(3,2),R(1,3),R(2,1)].';
phi = acos((trace(R)-1)/2);

u = inskew(R-R')/(2*sin(phi));
v = u * phi;
end
