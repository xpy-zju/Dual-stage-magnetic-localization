
function F = F1(usi,uM,thetasi,thetaM,M,Bs,sz)
% if nargin <7
%     sz = [9.7/2, 10/2];
% end
n = length(uM);
%F = zeros(3*(n-1),1);
F = zeros(3*n*(n-1)/2,1);
thetasi = reshape(thetasi,[3,1]);
Rso = expm(-skew(thetasi));
Bs_est = cell(n,1);
usi = reshape(usi,[3,1]);

for i = 1:n
    RoM = expm(skew(thetaM{i}));
    RMo = RoM';
    RsM = Rso*RoM;
    rM = RMo*(usi-uM{i});
    Bs_est{i} = RsM*magField(rM,M*1e12,sz(2),sz(1));
    % if(i>1)
    %     F(3*(i-1)-2:3*(i-1),:) = Bs(:,i)-Bs_est{i}-err;
    % else
    %     err  = Bs(:,i)-Bs_est{i};
    % end
end
k = 1;
for i = 1:n
    for j = i+1:n
        F(3*k-2:3*k,1) = (Bs_est{i}-Bs_est{j})-(Bs(:,i)-Bs(:,j));
        k = k+1;
    end
end
end