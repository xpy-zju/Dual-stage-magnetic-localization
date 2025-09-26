function G = magDipoleGradient(r,m)
% magnetic gradient tensor of dipole model.
mu0 = 4*pi*1e-7;
x = r(1);
y = r(2);
z = r(3);
nr = norm(r);
B11 = -15*x^2*z+3*nr^2*z;
B12 = -15*x*y*z;
B13 = -15*x*z^2+3*x*nr^2 ;
B21 = B12;
B22 = -15*y^2*z+3*nr^2*z;
B23 = -15*y*z^2+3*y*nr^2;
B31 = B13;
B32 = B23;
B33 = 9*x^2*z+9*y^2*z-6*z^3;
G = m*mu0/(4*pi*nr^7)*[B11,B12,B13;B21,B22,B23;B31,B32,B33];
end