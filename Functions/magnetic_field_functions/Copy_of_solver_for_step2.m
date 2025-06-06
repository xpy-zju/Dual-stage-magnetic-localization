function [m_esti, um_esti, thetam_esti] = solver_for_step2(m0, um0, thetam0, Bs_cal_minus_BM, us, thetas,ids)
%% 参数说明

% um0, thetam0 初值 3*1
% Bs_cal_minus_BM 3*n的矩阵【存疑，为什么不直接3*n，我先按照3*n写了】，表示除去大磁铁影响的，完全由小磁铁造成的传感器读数
% us 1*9 cell，每个cell 3*1的向量
% thetas同上
% Jacobian_2 的输出 3n*7的矩阵，n为传感器数量

%% L-M优化过程
% 初始条件
threshold = 1e-3; %B的单位是 uT？
Sensor_for_optim = ids;
m_esti = m0;
um_esti = um0;
thetam_esti = thetam0;
Bs_hat = reshape(Bs_cal_minus_BM, [], 1); %实际的传感器测到的值
max_iteration = 100000;
tau = 100;
step_now = 0;
% 循环
tic
while step_now<max_iteration
 
% 1. 准备[Bs-Bs^]^t矩阵
    Bs_minus_Bs_hat = []; % 3n*1
    for id = Sensor_for_optim
        r_m = Exp(-thetam_esti) * (us{id} - um_esti);
        B_dipole = Exp(-thetas{id}) * Exp(thetam_esti) * magDipoleField(r_m, m_esti);
        Bs_minus_Bs_hat = [Bs_minus_Bs_hat; B_dipole-Bs_hat(id*3-2:id*3)];
    end
% 2. [Bs-Bs^]^t和Bs的雅可比相乘，得到关于Loss的最终jacobian
jacobian_Bs = Jacobian_2(m_esti, um_esti, thetam_esti, us, thetas);
row_slected = sort([Sensor_for_optim*3-2, Sensor_for_optim*3-1, Sensor_for_optim*3]);
jacobian_Bs_selected = jacobian_Bs(row_slected, :); % 3n*7

jacobian_L = Bs_minus_Bs_hat' * jacobian_Bs_selected;
%J = test_jacobian(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti, m_esti);
% 3. 执行LM优化
if step_now == 0
    A0 = jacobian_L' * jacobian_L;
    u0 = tau * max(diag(A0));
    A = A0;
    u = u0;
    
end

delta_x = -inv((A + u*eye(7))) * (jacobian_L' * calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti, m_esti));

delta_m = delta_x(1);
delta_um = delta_x(2:4);
delta_thetam = delta_x(5:7);
    % 确定/讨论 信赖区域的范围
    Loss_now = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti, m_esti);
    fprintf('Current Loss : %4.2f \n', Loss_now);
    m_esti_try = m_esti + delta_m;
    um_esti_try = um_esti + delta_um;
    thetam_esti_try = Log(Exp(thetam_esti) * Exp(delta_thetam));
    Loss_next = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti_try, um_esti_try, m_esti_try);
    delta_y = Loss_next - Loss_now;
    if abs(delta_y) < threshold
        disp("loss")
        break
    end
    RHO = (delta_y)/(jacobian_L * delta_x);
    %RHO
    if RHO > 0
        m_esti = m_esti + delta_m;
        um_esti = um_esti + delta_um;
        thetam_esti = Log(Exp(thetam_esti) * Exp(delta_thetam));
        if RHO<=0.25
            u = 0.25 * u;
        elseif (0.25<RHO) && (RHO<0.75)
            u = 1.5*u;
        elseif RHO >=0.75
            u =0.25 * u;
        end
    else
        %不更新变量
        u = 1.5 * u;
    end
if u<threshold
    disp("break u")
    break
end
step_now = step_now+1;
end

% jacobian_L
toc
end

function Loss = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti, m_esti)
Bs_minus_Bs_hat = []; % 3n*1
    for id = Sensor_for_optim
        r_m = Exp(-thetam_esti) * (us{id} - um_esti);
        B_dipole = Exp(-thetas{id}) * Exp(thetam_esti) * magDipoleField(r_m, m_esti);
        Bs_minus_Bs_hat = [Bs_minus_Bs_hat; B_dipole-Bs_hat(id*3-2: id*3)];
    end
Loss = 0.5 * (Bs_minus_Bs_hat' * Bs_minus_Bs_hat);
end


function J = test_jacobian(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti, m_esti)
    Loss0 = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti, m_esti);
    h = 1e-3;
    Loss_m = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti, m_esti+h);
    Loss_ux = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti+h*[1 0 0]', m_esti);
    Loss_uy = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti+h*[0 1 0]', m_esti+h);
    Loss_uz = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti+h*[0 0 1]', m_esti+h);
    Loss_thetax = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti+h*[1 0 0]', um_esti, m_esti+h);
    Loss_thetay = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti+h*[0 1 0]', um_esti, m_esti+h);
    Loss_thetaz = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti+h*[0 0 1]', um_esti, m_esti+h);
    
    J = ([Loss_m, Loss_ux, Loss_uy, Loss_uz, Loss_thetax, Loss_thetay, Loss_thetaz]-Loss0)/h;

end