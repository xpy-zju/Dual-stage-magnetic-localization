
rM =(rand(3,1)-0.5)/0.5*10;
tic
B0 = magField(rM); 
h = 1e-10;
B1 = magField(rM+[h,0,0].');
dB_num(:,1)=(B1-B0)/h;
B1 = magField(rM+[0,h,0].');
dB_num(:,2)=(B1-B0)/h;
B1 = magField(rM+[0,0,h].');
dB_num(:,3)=(B1-B0)/h
toc
tic
dB_ana = magGradient(rM)
toc
abs((dB_num-dB_ana)./dB_ana)


% k = 0.2;
% h = 1e-10;
% e1 = EllipticE(k)/(k*(1-k^2))-EllipticK(k)/k
% e2 = (EllipticK(k+h)-EllipticK(k))/h