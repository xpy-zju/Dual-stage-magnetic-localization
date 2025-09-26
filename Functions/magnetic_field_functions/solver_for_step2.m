function [m_esti, um_esti, thetam_esti] = solver_for_step2(m0, um0, thetam0, Bs_cal_minus_BM, us, thetas,ids)

% um0, thetam0 initial value 3*1
% Bs_cal_minus_BM 3*n
% us 1*9 cell，
% thetas
% Jacobian_2 3n*7

%% L-M
% initialize
threshold_fx = 0.00001; %
% threshold_J = 1e-46;
threshold_U = 1e10;
threshold_g = 1e-4;
Sensor_for_optim = ids;
m_esti = m0;
um_esti = um0;
thetam_esti = thetam0;
Bs_hat = reshape(Bs_cal_minus_BM, [], 1); %measurement
max_iteration = 10000;
tau = 1e-5;
step_now = 0;
v = 2;
% Loop

while step_now<max_iteration

    % 1. Prepare [Bs-Bs^]^t
    Bs_minus_Bs_hat = []; % 3n*1
    for id = Sensor_for_optim
        r_m = Exp(-thetam_esti) * (us{id} - um_esti);
        B_dipole = Exp(-thetas{id}) * Exp(thetam_esti) * magDipoleField(r_m, m_esti{id});
        Bs_minus_Bs_hat = [Bs_minus_Bs_hat; B_dipole-Bs_hat(id*3-2:id*3)];
    end
    % 2. Multiply [Bs-Bs^]^t by the Jacobian of Bs to obtain the final Jacobian of the loss function.
    jacobian_Bs = Jacobian_2(m_esti, um_esti, thetam_esti, us, thetas,ids);
    %row_slected = sort([Sensor_for_optim*3-2, Sensor_for_optim*3-1, Sensor_for_optim*3]);
    %jacobian_Bs_selected = jacobian_Bs(row_slected, :); % 3n*7

    % jacobian_L = Bs_minus_Bs_hat' * jacobian_Bs_selected;
    Jacobian_fx = jacobian_Bs;
    %J = test_jacobian(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti, m_esti);
    % 3. LM optimization
    if step_now == 0
        A0 = Jacobian_fx' * Jacobian_fx;
        u0 = tau * max(diag(A0));
        A = A0;
        u = u0;

    end

    %delta_x = -inv((A + u*eye(7))) * (Jacobian_fx' * Bs_minus_Bs_hat);
    g = (Jacobian_fx' * Bs_minus_Bs_hat);
    delta_x = -inv((A + u*eye(5))) *g ;
    % delta_m = delta_x(1);
    % delta_um = delta_x(2:4);
    % delta_thetam = delta_x(5:7);
    delta_um = delta_x(1:3);
    delta_thetam = delta_x(4:5);
    delta_thetam(3) = 0;
    % Determine / discuss the range of the trust region.
    fx_now = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti, m_esti);
    fprintf('Current Loss : %4.2f ,u:%4.2f,v:%4.2f,grad:%4.2f\n', norm(fx_now),u,v,norm(g));

    %m_esti_try = m_esti + delta_m;
    um_esti_try = um_esti + delta_um;
    thetam_esti_try = Log(Exp(thetam_esti) * Exp(delta_thetam));
    fx_next = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti_try, um_esti_try, m_esti);
    delta_fx = -(fx_next - fx_now);
    if max(delta_fx) < threshold_fx

        fprintf('End Loss : %4.2f, delta fx break\n', norm(fx_now));
        break
    end
    % RHO = (fx_next - fx_now)./(Jacobian_fx * delta_x);
    RHO = norm(fx_now) - norm(fx_next);
    %RHO 
    if RHO > 0
        %m_esti = m_esti + delta_m;
        um_esti = um_esti + delta_um;
        thetam_esti = Log(Exp(thetam_esti) * Exp(delta_thetam));
        % if RHO<=0.25
        %     u = 0.25 * u;
        % elseif (0.25<RHO) && (RHO<0.75)
        %     u = 1.5*u;
        % elseif RHO >=0.75
        %     u =0.25 * u;
        % end
        v = max([2,v/2]);
        u =max([1/3,u0*0.1,u*0.01]);

    else
       
        u = v * u;
        v = 2*v;
    end

    if u > threshold_U
        fprintf('End Loss : %4.2f,break u \n', norm(fx_now));
        break
    end
    % if det(Jacobian_fx' * Jacobian_fx) < threshold_J
    %     det(Jacobian_fx' * Jacobian_fx)
    %     disp("break jacobian")
    %     break
    % end
    if norm(fx_now) < threshold_fx
        fprintf('End Loss : %4.2f ,break fx too low\n', norm(fx_now));
        break
    end
    if norm(g)<threshold_g
        fprintf('End Loss : %4.2f ,break g too low\n', norm(g));
        break
    end
    step_now = step_now+1;
end

% jacobian_L

end

function fx = calcu_f(Sensor_for_optim, Bs_hat, us, thetas, thetam_esti, um_esti, m_esti)
Bs_minus_Bs_hat = []; % 3n*1
for id = Sensor_for_optim
    r_m = Exp(-thetam_esti) * (us{id} - um_esti);
    B_dipole = Exp(-thetas{id}) * Exp(thetam_esti) * magDipoleField(r_m, m_esti{id});
    Bs_minus_Bs_hat = [Bs_minus_Bs_hat; B_dipole-Bs_hat(id*3-2: id*3)];
end
fx = Bs_minus_Bs_hat;
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