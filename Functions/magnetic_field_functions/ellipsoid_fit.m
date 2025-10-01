function [M,N,d] = ellipsoid_fit(s)

% Paramenters:
%-------------
% s: 3*n double
%    n is the number of samples
%
% Returns:
%------------
% M,N,d:3*3 double, 3*1 double, double
%    The ellipsoid parameters M,N,d
%
% Reference:
%------------
% Qingde Li; Griffiths, J.G., "Least squares ellipsoid specific
% fitting," in Geometric Modeling and Processing,2004.
% Proceedings, vol., no., pp.335-340, 2004

% D (samples)
x = s(1,:);
y = s(2,:);
z = s(3,:);
n = length(x);
D = [x.*x       ;y.*y   ;   z.*z;...
    2.*y.*z     ;2.*x.*z;   2.*x.*y;...
    2.*x        ;2.*y   ;2.*z   ;   ones(1,n)];
S = D*D';
v = FindFit4(S);
if v(1)<0
    v = -v;
end
M = [v(1),v(6),v(5);v(6),v(2),v(4);v(5),v(4),v(3)];

N = reshape(v(7:9),[3,1]);
d = v(10);
end