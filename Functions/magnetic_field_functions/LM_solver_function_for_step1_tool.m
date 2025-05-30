function [outputArg1,outputArg2] = LM_solver_function_for_step1_tool(used_sensor,Bs,us_guess,thetas_guess,uM,thetaM,M_discrete,sz)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

function [F,J] = object_function()
output = F1(usi,uM,thetasi,thetaM,M,Bs,sz);
x0 = [reshape(us_guess,[1,3]),reshape(thetas_guess,[1,3])];

end