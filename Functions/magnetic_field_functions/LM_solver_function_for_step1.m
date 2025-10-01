function [us_est,thetas_est] = LM_solver_function_for_step1(used_sensor,Bs,us_guess,thetas_guess,uM,thetaM,M_discrete,sz)
us_est = cell(9,1);
thetas_est = cell(9,1);
%sensor_detect = 1;
sigma_1 = 1e-10;
sigma_2 = 1e-10;
max_iteration_time = 1000;

max_repeat_time = 1000;
used_sensor = sort(used_sensor);
for id = used_sensor
    
    i = used_sensor(id);
    M = M_discrete{i};
    %set initial value
    u = 10;
    %us_est{i} = us{i}+rand(3,1)*0.2;
    us_est{i} = us_guess{i};

    %thetas_est{i} = restrict_theta(rand(3,1)*2*pi);
    thetas_est{i} = thetas_guess{i};
    %M = 9.366138787219805e+8;
    %x = [M;us_est{i};thetas_est{i}];
    x = [us_est{i};thetas_est{i}];

    %f = @(x)F1(x(2:4),uM,x(5:7),thetaM,x(1),Bs(:,:,i));
    f = @(x)F1(x(1:3),uM,x(4:6),thetaM,M,Bs(:,:,i),sz);
    F = @(f) 1/2*f'*f;
    %J1 = @(x) Jacobian_1(x(2:4),uM,x(5:7),thetaM,x(1));
    J1 = @(x) Jacobian_1(x(1:3),uM,x(4:6),thetaM,M,sz);
    p_add = @(x1,x2) [x1(1:3)+x2(1:3);Log(Exp(x1(4:6))*Exp(x2(4:6)))];
    %p_sub = @(x1,x2) [x1(1:3)-x2(1:3);Log(Exp(x1(4:6))*Exp(-x2(4:6)))];
    fx = f(x);
    iteration_time = 0;
    repeat_time = 0;

    % start LM 
    quit_flag = false;
    while true
        %Step 1 Calculate J
        
        J = J1(x);
        H = J.'*J;
        g = J.'*fx;
        g
        normg = norm(g);
        % quit condition 1: grad is too small
        if normg<sigma_1
            us_est{i} = x(1:3);
            thetas_est{i} = x(4:6);
            %fprintf("1\n");
            break;
        end
        while true
            h = -(H+u*eye(6))^(-1)*g;
            x_new = p_add(x,h);
            x_new(4:6) = restrict_theta(x_new(4:6));
            
            
            % quit condition 2: h is too small
            if norm(h)<sigma_2*(norm(x)*sigma_2)
                fprintf("2\n");
                quit_flag = true;
                break;
            end
            fxnew = f(x_new);
            rhovar = F(fx) - F(fxnew);


            % accept the change
            if rhovar > 0
                x = x_new;
                fx = fxnew;
                u = u/10;
                break;
            else
                u = u*10;
                repeat_time = repeat_time+1;
                % quit condition 3: repeat time is too large
                if repeat_time > max_repeat_time
                    quit_flag = true;
                    fprintf("3\n");
                    break
                end
            end

        end
        iteration_time = iteration_time +1;
        %quit condition 4: iteration_time is too large
        if iteration_time>max_iteration_time
            
            fprintf("4\n");
            quit_flag = true;
        end
        if quit_flag
            us_est{i} = x(1:3);
            thetas_est{i} = x(4:6);
            break;
        end
        s = sprintf("id:%d,  res:%d,  normg:%d, x_new:[%d,%d,%d,%d,%d,%d,]",id,F(fx),normg,x_new(1),x_new(2),x_new(3),x_new(4),x_new(5),x_new(6));
            disp(s)
    end
end
%normg
res = F(fx)
end