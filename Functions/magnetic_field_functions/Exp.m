function output = Exp(theta)
%Convert a Lie algebra element to a rotation matrix.
output = expm(skew(theta));
end