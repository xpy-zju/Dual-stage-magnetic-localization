function B = magDipoleField(r,m)
% Calculates the magnetic field at an arbitrary point outside a cylindrical magnet using the magnetic dipole model.
% r is the vector from the magnetss center to the target position in the magnet's coordinate frame.
x = r(1);
y = r(2);
z = r(3);
nr = norm(r);
mu0 = 4*pi*1e-7;
B(1) = mu0*m/(4*pi)*3*x*z/nr^5;
B(2) = mu0*m/(4*pi)*3*y*z/nr^5;
B(3) = mu0*m/(4*pi)*(2*z^2-x^2-y^2)/nr^5;
B = reshape(B,[3,1]);
end