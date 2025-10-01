function output = restrict_theta(theta)
%Map the orientation vectors with axis–angle magnitudes exceeding 2pi back
%into range within 2pi
R = expm(skew(theta));
output = Log(R);
end