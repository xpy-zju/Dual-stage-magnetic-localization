function [us0,thetas0] = getus0thetas0_16(searched_table,M,ids,par,sz)

L = sz(1);
R = sz(2);
ids = reshape(ids,[1,length(ids)]);
searched_table = sortrows(searched_table,["id","point_index"]);
n = height(searched_table)/16;
for nid = ids
    searched_table_id = searched_table(n*(nid-1)+1:n*nid,:);
    r = []; uMs = [];thetaMs = [];Bss=[];r_real=[];
    for i = 1:n/4
        searched_table_id_temp = searched_table_id((i-1)*4+1:i*4,:);
        [r(:,i),uMs(:,i),thetaMs(:,i),Bss(:,i),r_real(:,i)] = get_single_r(M{nid},searched_table_id_temp,sz);
    end
    % [r(:,end+1),uMs(:,end+1),thetaMs(:,end+1),Bss(:,end+1),r_real(:,end+1)] = get_single_r(M{nid},searched_table_id(index(end):end,:),sz);
    
    A =-2* (uMs)';
    A = [ones(length(A),1),A];
    norm_at_column = @(a) (a(1,:).^2+a(2,:).^2+a(3,:).^2)';
    
    r = reshape(r,[length(r),1]);
    b = r.^2 - norm_at_column(uMs);
    ust = pinv(A)*b;
    us0{nid} = ust(2:4,:); 
    
   % ust(2:4,:)
    % us0_temp = trilateration(uMs,r);
    % us0{nid} = us0_temp(:,2);

    for i = 1:n/4
        RoM = Exp(thetaMs(:,i));
        RMo = RoM';
        rsm = RMo*(us0{nid}-uMs(:,i));
        BM_ana = magField(rsm,M{nid},sz(2),sz(1));
        Bo(:,i) = RoM*BM_ana;
    end
    Bo = Bo-mean(Bo,2);
    Bss = Bss-mean(Bss,2);
    Ros = (Bo*Bo')^(-1)*Bo*Bss';
    thetas0{nid}= real(Log(Ros/norm(Ros)));
end
end


function [r,uM,thetaM,Bs,r_real] = get_single_r(M,searched_table,sz)
    % if nargin<3
    %     sz = [62.4/2,68/2];
    % end
    L = sz(1);
    R = sz(2);
    u = table2array(searched_table(:,["M_x","M_y","M_z"]));
    u_mean = mean(u);
    u_error = u-u_mean;
    norm_as_rows = @(a) (a(:,1).^2+a(:,2).^2+a(:,3).^2);
    [~,center_index] = min(norm_as_rows(u_error));
    non_center_index = [1:height(searched_table)];
    non_center_index(center_index)=[];
    k = 0;
    
    for index=non_center_index
        k=k+1;
        B_err_x = table2array(searched_table(index,"Bx")-searched_table(center_index,"Bx"));
        B_err_y = table2array(searched_table(index,"By")-searched_table(center_index,"By"));
        B_err_z = table2array(searched_table(index,"Bz")-searched_table(center_index,"Bz"));
        dB(k,:) = [B_err_x,B_err_y,B_err_z];
        u_error_x = table2array(searched_table(index,"M_x")- searched_table(center_index,"M_x"));
        u_error_y = table2array(searched_table(index,"M_y")- searched_table(center_index,"M_y"));
        u_error_z = table2array(searched_table(index,"M_z") - searched_table(center_index,"M_z"));
        du(k,:) = [u_error_x,u_error_y,u_error_z];
    end
    RH = pinv(du)*dB;

    lambda = eig(RH*RH');
    %calculate NSS
    a1 = -lambda(1)+sqrt(lambda(2)*lambda(3));
    a2 = -lambda(2)+sqrt(lambda(1)*lambda(3));
    a3 = -lambda(3)+sqrt(lambda(1)*lambda(2));
    mu_NSS = sqrt(max([a1,a2,a3]));

    V = 2*pi*R^2*L;
    m = M*V*1.05;

    mu0 = 4*pi*1e-7;
    r = (3*mu0*m/(4*pi*mu_NSS))^(1/4);

    uM = reshape(table2array(searched_table(center_index,["M_x","M_y","M_z"])),[3,1]);
    us =    reshape(table2array(searched_table(center_index,["sensor_x","sensor_y","sensor_z"])),[3,1]);
    thetaM = reshape(table2array(searched_table(center_index,["M_ox","M_oy","M_oz"])),[3,1]);
    Bs = reshape(table2array(searched_table(center_index,["Bx","By","Bz"])),[3,1]);
    r_real = norm((us-uM));
end


