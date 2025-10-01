function output = Jacobian_1(usi,uM,thetasi,thetaM,M,sz)
J = cell(length(uM),1);
n = length(uM);
usi = reshape(usi,[3,1]);
thetasi = reshape(thetasi,[3,1]);
for i = 1:n
    uMi = uM{i};
    thetaMi = thetaM{i};
    %J{i} = [jacobian_k(usi,uMi,thetasi,thetaMi),jacobian_ui(usi,uMi,thetasi,thetaMi,M),jacobian_thetai(usi,uMi,thetasi,thetaMi,M)];
    J{i} = [jacobian_ui(usi,uMi,thetasi,thetaMi,M,sz),jacobian_thetai(usi,uMi,thetasi,thetaMi,M,sz)];%,jacobian_k(usi,uMi,thetasi,thetaMi,sz)];
end
%output = zeros(3*n*(n-1)/2,7);
%output = zeros(3*(n-1),6);

% for i = 1:n
%     if i>1
%         output(3*(i-1)-2:3*(i-1),:) = J1-J{i};
%     else
%         J1 = J{i};
%     end
% end

output = zeros(3*n*(n-1)/2,6);
k = 1;
for i = 1:n
    for j = i+1:n
        output(3*k-2:3*k,:) = J{i}-J{j};
        k = k+1;
    end
end

end