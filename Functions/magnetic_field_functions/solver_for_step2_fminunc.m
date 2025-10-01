function [ um_esti, thetam_esti] = solver_for_step2_fminunc(m0, um0, thetam0, Bs_cal_minus_BM, us, thetas,ids)       
    %m_esti = 8000*ones(16,1);
    options = optimoptions('lsqnonlin','Algorithm','levenberg-marquardt','SpecifyObjectiveGradient',true,'Display','iter');
    
    x0 = [um0;thetam0(1:2)];
    
    fun = @(u_theta_of_small_mag)calculate_loss(u_theta_of_small_mag,Bs_cal_minus_BM, m0, us, thetas, thetam0, ids);
    optim_output = lsqnonlin(fun,x0,[],[],[],[],[],[],[],options);
    um_esti = optim_output(1:3);
    thetam_esti = [optim_output(4:5);thetam0(3)];
    %m_esti = optim_output(6);
    
end

function [Loss_step2,g] = calculate_loss(u_theta_of_small_mag, Bs_cal_minus_BM, m0, us, thetas, thetam0, ids)
    Bs_hat = reshape(Bs_cal_minus_BM, [], 1); %measurement
    Bs_minus_Bs_hat = zeros([3*length(ids),1]); % 3n*1
    %m0 = u_theta_of_small_mag(6);
    m0 = m0{1};
    um_esti = u_theta_of_small_mag(1:3);
    thetam_esti = [u_theta_of_small_mag(4:5);thetam0(3)];
    i= 1;
    for id = ids        
        r_m = Exp(-thetam_esti) * (us{id} - um_esti);
        B_dipole = Exp(-thetas{id}) * Exp(thetam_esti) * magDipoleField(r_m, m0*1e12);
        Bs_minus_Bs_hat(3*i-2:3*i,1) = B_dipole-Bs_hat(id*3-2:id*3);
        i = i+1;
    end
    % Loss_step2 = sum(Bs_minus_Bs_hat.^2);
    Loss_step2 = Bs_minus_Bs_hat; %3n*1
    if nargout > 1 % gradient required
        jacobian_Bs = Jacobian_2(m0, um_esti, thetam_esti, us, thetas,ids);
        g = jacobian_Bs;
        %g = 2 * jacobian_Bs' * Bs_minus_Bs_hat;
        %g = g';
    end
end

