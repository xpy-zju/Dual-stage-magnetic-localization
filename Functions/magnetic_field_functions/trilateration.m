function [p4,p4_psy] = trilateration(p,l)
% p: 3*3 matrix (列向量构成）代表三个station的坐标
% l: 1*3 matrix 代表p4到 station的距离，顺序与p对应
p1 = p(:,1);
p2 = p(:,2);
p3 = p(:,3);
U2 = (p1-p2)'*(p1-p2);
V2 = (p2-p3)'*(p2-p3);
W2 = (p3-p1)'*(p3-p1);
D123 = D3(U2,V2,W2);
u2 = l(3)^2;
v2 = l(1)^2;
w2 = l(2)^2;
%D1234 = 1/8*det([0,U2,V2,W2,1;U2,0,w2,v2,1;V2,w2,0,u2,1;W2,v2,u2,0,1;1,1,1,1,0]);


D1234 = 1/8*det([  0,1,1,1,1;...
                               1,0,U2,W2,v2;...
                               1,U2,0,V2,w2;...
                               1,W2,V2,0,u2;...
                               1,v2,w2,u2,0]);



D13 = W2;
D12 = U2;
D134 = D3(W2,u2,v2);
D124 = D3(U2,w2,v2);

S123 = S_triangle(U2,V2,W2);
h2 = D1234/D123;
r12 = v2-h2;
r22 = w2-h2;
r32 = u2-h2;

alpha = acos((w2+u2-v2)/(2*sqrt(w2*u2)));
beta = acos((v2+U2-w2)/(2*sqrt(v2*U2)));
gamma = acos((v2+W2-u2)/(2*sqrt(v2*W2)));


cosB = (cos(beta)-cos(alpha)*cos(gamma))/(sin(alpha)*sin(gamma));
cosC = (cos(alpha)-cos(alpha)*cos(beta))/(sin(alpha)*sin(beta));
s1 = sign(cosB);
s2 = sign(cosC);
% S12P = S_triangle(v2-h2,w2-h2,U2);
% S13P = S_triangle(v2-h2,u2-h2,W2);
% S23P = S_triangle(V2,w2-h2,u2-h2);
% 
% a11 = abs(S12P+S23P-S13P-S123);
% a12 = abs(S13P+S23P+S123-S12P);
% a21 = abs(S13P+S23P-S12P-S123);
% a22 = abs(S12P+S23P+S123-S13P);
% a3 = abs(S23P-S123-S12P-S13P);
% s1 = 1;s2 = 1;
% threshold = 1e-7;
% if(a11<threshold||a12<threshold)
%     s1 = -1;
% end
% if(a21<threshold||a22<threshold)
%     s2 = -1;
% end
% 
% if(a3<threshold)
%     s1=-1;s2=-1;
% end

D123134 = Sqrt(D123*D134-D1234*D13)*(s1);
D123124 = Sqrt(D123*D124-D1234*D12)*(s2);


vec_v1 = p2-p1;
vec_v2 = p3-p1;

p4p= real(p1+1/D123*((D123134)*vec_v1+D123124*vec_v2 +Sqrt(D1234)*cross(vec_v1,vec_v2)));
p4n = real(p1+1/D123*((D123134)*vec_v1+D123124*vec_v2 -Sqrt(D1234)*cross(vec_v1,vec_v2)));
lp = abs(norm(p(:,4)-p4p)-l(4));
ln = abs(norm(p(:,4)-p4n)-l(4));
if(lp<ln)
    p4 = p4p;
    p4_psy = p4n;
else
    p4 = p4n;
    p4_psy = p4p;
end

end

function out = D3(a2,b2,c2)
out = -1/4*det([0,a2,b2,1;a2,0,c2,1;b2,c2,0,1;1,1,1,0]);
end

function out = S_triangle(a2,b2,c2)
out = Sqrt(D3(a2,b2,c2))/2;
end

function out = Sqrt(a)
if (a<0&&abs(a)<1e-7)
    out = 0;
else
    out = sqrt(a);
end
end