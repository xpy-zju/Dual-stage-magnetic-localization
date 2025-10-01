function[us_est,thetas_est,M] = estimate_us_thetas_16(searched_table,ids,us0,thetas0,M,sz)
searched_table = sortrows(searched_table, ["id","remark"]);
mag_data_cal_num_temp = table2array(searched_table(:,["Bx","By","Bz"]));
Bs_for_LM = reshape(mag_data_cal_num_temp', 3,[], 16);
h = height(searched_table)/16;
uM_for_LM =num2cell(table2array( searched_table(1:h,["M_x","M_y","M_z"]))',1);
thetaM_for_LM = num2cell(table2array( searched_table(1:h,["M_ox","M_oy","M_oz"]))',1);
%[us_est,thetas_est] = LM_solver_function_for_step1(1:20,Bs_for_LM,us0,thetas0,uM_for_LM,thetaM_for_LM,M,sz);
options = optimoptions('lsqnonlin','Algorithm','levenberg-marquardt','SpecifyObjectiveGradient',true,'Display','none');
us_est = cell(1,16);
thetas_est = cell(1,16);
%M = cell(1,16);
for id = ids
    x0 = [reshape(us0{id},[1,3]),reshape(thetas0{id},[1,3])];
    fun = @(x) objection_function1(x,uM_for_LM,thetaM_for_LM,Bs_for_LM(:,:,id),M{id},sz);
    optim_output = lsqnonlin(fun,x0,[],[],[],[],[],[],[],options);
    us_est{id} = reshape(optim_output(1:3),[3,1]);
    thetas_est{id} = reshape(optim_output(4:6),[3,1]);
    %M{id} = optim_output(7);
end
end

function [F,J] = objection_function1(x,uM,thetaM,Bs_for_LM,M,sz)
F = F1(x(1:3),uM,x(4:6),thetaM,M,Bs_for_LM,sz);
J = Jacobian_1(x(1:3),uM,x(4:6),thetaM,M,sz);
end