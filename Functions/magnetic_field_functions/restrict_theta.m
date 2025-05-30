function output = restrict_theta(theta)
%将那些轴角模值超过2pi的姿态量回归到2pi以内
R = expm(skew(theta));
output = Log(R);
end