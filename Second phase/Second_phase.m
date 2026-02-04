%% load the file and prepare the data
load('datafile\data5.mat')

Bs_real_lisa = searched_table_new_lisa(:,2:4).Variables;
us_lisa = searched_table_new_lisa(:,5:7).Variables;
thetas_lisa = searched_table_new_lisa(:,8:10).Variables;
um_lisa = searched_table_new_lisa(1:16:end,17:19).Variables;
thetam_lisa = searched_table_new_lisa(1:16:end,20:22).Variables;
x_real_lisa = [um_lisa,thetam_lisa];

%% localization of the Lissajous trajectory with analytical jacobian
% if set 'SpecifyObjectiveGradient' as false, the computational time increases significantly. 
% Thus, the analytical Jacobian is crucial for real time optimization and
% tracking. We now find that if C++ is used, the optimization frequency
% will enen higher than 100Hz.
options = optimoptions('lsqnonlin','Algorithm','levenberg-marquardt','SpecifyObjectiveGradient',true,'Display','none');
est_result_lisa = [];
x0 = x_real_lisa(1,:)' + [rand([3,1])*3;1;0;0];

real_color = [176,177,182]/255;
est_color = [243,112,33]/255;

plot3(x_real_lisa(:,1),x_real_lisa(:,2),x_real_lisa(:,3),'Color',real_color,'LineWidth',1.5,'LineStyle',':');
hold on
tic
for i = 1:length(x_real_lisa)
    Bs_in_loop = Bs_real_lisa(16*(i-1)+1:16*i,:)';
    Bs_minus_G = Bs_in_loop - G_reshape_lisa;
    us_in_loop = us_lisa(16*(i-1)+1:16*i,:)';
    thetas_in_loop = thetas_lisa(16*(i-1)+1:16*i,:)';
    x_real = x_real_lisa(i,:)';
    fun = @(x)object_fun_of_localize_small_magnet(x,Bs_minus_G,us_in_loop,thetas_in_loop,M,[5,5]);
    x_lisa_est = lsqnonlin(fun,x0,[],[],[],[],[],[],[],options);
        
        plot3(x_lisa_est(1),x_lisa_est(2),x_lisa_est(3),'*','Color',est_color);
        hold on
        z_dir_est = Exp([x_lisa_est(4),x_lisa_est(5),x_lisa_est(6)])*[0,0,1]';
        quiver3(x_lisa_est(1),x_lisa_est(2),x_lisa_est(3),z_dir_est(1),z_dir_est(2),z_dir_est(3),...
        "AutoScaleFactor",3,"LineStyle","-", "Linewidth",1.5,...
        "ShowArrowHead","on",...
        "Color",est_color);

        x0 = x_lisa_est;
        axis equal
        grid on
        xlabel('x (mm)');ylabel('y (mm)');zlabel('z (mm)');
        drawnow
end
toc

set(gca,'FontName','Arial','LineWidth',1);

%% objective function
function [F,J] = object_fun_of_localize_small_magnet(x,Bs,us,thetas,M,sz)
    % x 6*1
    % Bs 3*16
    F = zeros([48,1]);
    for id = 1:16
        Bs_now = Bs(:,id);
        r = Exp(-x(4:6))*(us(:,id) - x(1:3));
        Bs_model = magField(r, M(id), sz(1), sz(2));
        Bs_model = Exp(-thetas(:,id))*Exp(x(4:6))*Bs_model;
        F(3*(id-1)+1:3*id) = Bs_now - Bs_model;
    end
    if nargout>1
        J = zeros([48,6]);
        for id = 1:16
            J((id-1)*3+1:3*id,:) = -[J_u(us(:,id),thetas(:,id),x(1:3),x(4:6),M(id),sz(1),sz(2)),J_theta(us(:,id),thetas(:,id),x(1:3),x(4:6),M(id),sz(1),sz(2))];
        end
    end
end

%% jacobian function. speed up the optimization

function J = J_u(us,thetas,um,thetam,M,R,L)
    r = Exp(-thetam)*(us-um);
    [H,~,~] = magGradient(r,M,R,L);
    J = Exp(-thetas)*Exp(thetam)*H*(-Exp(-thetam));
end

function J = J_theta(us,thetas,um,thetam,M,R,L)
    r = Exp(-thetam)*(us-um);

    J_r_ = J_r(thetam);
    B = magField(r,M,R,L);
    J1 = -Exp(-thetas)*Exp(thetam)*skew(B)*J_r_;
    
    J_r_ = J_r(-thetam);
    [H,~,~] = magGradient(r,M,R,L);
    J2 = Exp(-thetas)*Exp(thetam)*H*Exp(-thetam)*skew(us-um)*J_r_;

    J = J1+J2;
end

function J = J_r(theta)
    norm_theta = norm(theta);
    sk_theta = skew(theta);
    J = eye(3)-(1-cos(norm_theta))/norm_theta^2*sk_theta+(norm_theta-sin(norm_theta))/norm_theta^3*sk_theta^2;
end
