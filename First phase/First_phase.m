%% demostration of first-phase localization
load("step1.mat")
%% initial value of the sensor's pose
par = ":";
ids = [1:16];
[us0_,thetas0_] = getus0thetas0_16(search_table_final,M_discrete_big_average,ids,par,[30,30]);
figure
us0 = [us0_{:}];

thetas0 = [thetas0_{:}];
plot3(us0(1,:),us0(2,:),us0(3,:),'Marker','square','LineStyle','none','MarkerFaceColor',[0.5,0.5,0.5]);
hold on
for i = 1:size(us0,2)
    zdir = Exp(thetas0(:,i))*[0,0,1]';
    % quiver3(us0(1,i),us0(2,i),us0(3,i),zdir(1),zdir(2),zdir(3),10);
end
axis equal
grid on
%% optimization of sensor's pose
for i = ids
    M_discrete_big_{i} = M_discrete_big_average{i}/1e12;
end

[us_est_,thetas_est_,M] = estimate_us_thetas_16(search_table_step1,ids,us0_,thetas0_,M_discrete_big_,[30,30]);


figure
us_est_ = [us_est_{:}];
thetas_est_ = [thetas_est_{:}];
plot3(us_est_(1,:),us_est_(2,:),us_est_(3,:),'Marker','square','LineStyle','none','MarkerFaceColor',[0.5,0.5,0.5]);
hold on
for i = 1:size(us_est_,2)
    zdir = Exp(thetas_est_(:,i))*[0,0,1]';
    quiver3(us_est_(1,i),us_est_(2,i),us_est_(3,i),zdir(1),zdir(2),zdir(3),3);
end
axis equal
grid on
index = 1;



%% The following sections provide visualizations to aid in understanding the dual-stage localization algorithm.
ids = 1:4:24;
search_table = sortrows(search_table_final,"id");
big_mag_loc = table2array(search_table(:,11:13));  
big_mag_tha = table2array(search_table(:,14:16));   
sensor_loc1 = us0;
r = zeros(5,16);
for i = 1:5
    for j = 1:16
        r(i,j) = norm(big_mag_loc(i,:)' - us0(:,j));
    end
end

%% plot
figure 
j = 1;
for  i = 1:5
     [X,Y,Z] = sphere;
     X = X*r(i,j) + big_mag_loc(i,1);
     Y = Y*r(i,j) + big_mag_loc(i,2);
     Z = Z*r(i,j) + big_mag_loc(i,3);
     ball_p = surf(X,Y,Z);
     ball_p.FaceColor = "#66ccff";
     ball_p.EdgeColor = "none";
     ball_p.FaceAlpha = 0.1;
     hold on
     % sensor_p = plot3(us0(1,j),us0(2,j),us0(3,j),'o');
     line_p = plot3([big_mag_loc(i,1),us0(1,j)],...
            [big_mag_loc(i,2),us0(2,j)],...
            [big_mag_loc(i,3),us0(3,j)],'b--');
     plot_Mag([Exp(big_mag_tha),big_mag_loc(i,:)';0,0,0,1],30,30,0.3,0.3)
     set(gca,'FontName','Arial','FontSize',18)
     set(gca,'linewidth',1);
     set(gcf,'unit','centimeters','position',[10 0 20 20]); 
     grid on
     axis equal
    % xlim([500,800])
    % ylim([-330,100])
    % zlim([500,850])
    view(-40,40)
    xlabel('{\it x} (mm)');ylabel('{\it y} (mm)');zlabel('{\it z} (mm)');
    % print(gcf,'-dpng','-r600',['First phase\sensor_init\sensor_',int2str(i)','.png']);
end
plot_sensor([us0(:,1:j);thetas0(:,1:j)],3,[0.5,0.5,0.5],[0.5,0.5,0.5],0.5);
% print(gcf,'-dpng','-r600',['First phase\sensor_init\sensor_6.png']);

%%
figure
for j = 2:16
    clf
    for  i = 3:5

         [X,Y,Z] = sphere;
         X = X*r(i,j) + big_mag_loc(i,1);
         Y = Y*r(i,j) + big_mag_loc(i,2);
         Z = Z*r(i,j) + big_mag_loc(i,3);
         ball_p = surf(X,Y,Z);
         ball_p.FaceColor = "#66ccff";
         ball_p.EdgeColor = "none";
         ball_p.FaceAlpha = 0.1;
    
         hold on
         plot_Mag([Exp(big_mag_tha),big_mag_loc(i,:)';0,0,0,1],30,30,0.3,0.3)
        line_p = plot3([big_mag_loc(i,1),us0(1,j)],...
                [big_mag_loc(i,2),us0(2,j)],...
                [big_mag_loc(i,3),us0(3,j)],'b--');
    end
         % sensor_p = plot3(us0(1,j),us0(2,j),us0(3,j),'o');
        plot_sensor([us0(:,1:j);thetas0(:,1:j)],3,[0.5,0.5,0.5],[0.5,0.5,0.5],0.5);
     
         
         axis equal
         set(gca,'FontName','Arial','FontSize',18)
     set(gca,'linewidth',1);
     set(gcf,'unit','centimeters','position',[10 0 20 20]);
     grid on
    % xlim([500,800])
    % ylim([-330,100])
    % zlim([500,850])
    view(-40,40)
    xlabel('{\it x} (mm)');ylabel('{\it y} (mm)');zlabel('{\it z} (mm)');
     
    %
    % print(gcf,'-dpng','-r600',['First phase\sensor_init\sensor_',int2str(j+5),'.png']);
    
end
%% 
figure
steps = 20;
lim_max = [-27.2245  427.2311;-672.2265 -217.7709;422.7962  940.7190];
lim_min = [75.2699  135.3606;-637.4079 -610.0668;736.9862  765.4704];
limitit = (lim_min - lim_max)/(steps-1);
sizeit = -2/steps;
clf


for j = 1:steps
    clf
    axis equal
    hold on
    plot_sensor([us0;thetas0],sizeit*j+3,[0.5,0.5,0.5],[0.5,0.5,0.5],0.5);
    
    set(gca,'FontName','Arial','FontSize',18)
    set(gca,'linewidth',1);
    set(gcf,'unit','centimeters','position',[10 0 20 20]);
    grid off
    view(-40,40)
    xlim(limitit(1,:)*(j-1) + lim_max(1,:))
    ylim(limitit(2,:)*(j-1)  + lim_max(2,:))
    zlim(limitit(3,:)*(j-1)  + lim_max(3,:))
    xlabel('{\it x} (mm)');ylabel('{\it y} (mm)');zlabel('{\it z} (mm)');
    
    print(gcf,'-dpng','-r600',['First phase\sensor_lim\sensor_',int2str(j),'.png']);
    
end
%%
figure
thetas00 = thetas_est_;
us00 = us_est_;
steps = 10;
moveit = (us00 - us0)/steps;
rotit = (thetas00-thetas0)/steps;
us_new = us0;
thetas_new = thetas0;

for j = 1:steps+1
    clf
    for i = 1:16
        us_new(:,i) = moveit(:,i)*(j-1) + us0(:,i);   
        thetas_new(:,i)  = rotit(:,i)*(j-1) + thetas0(:,i);
    end
    hold on
    plot_sensor([us_new;thetas_new],1,[0.5,0.5,0.5],[0.5,0.5,0.5],0.5);
    axis equal
    
    set(gca,'FontName','Arial','FontSize',18)
     set(gca,'linewidth',1);
     set(gcf,'unit','centimeters','position',[10 0 20 20]); 
     % grid on
     % lim_min = [720  740;-135 -115;660  690];
     % xlim("auto")
     % ylim("auto")
     % zlim("auto")
    xlim(lim_min(1,:))
    ylim(lim_min(2,:))
    zlim(lim_min(3,:))
    view(-40,40)
    xlabel('{\it x} (mm)');ylabel('{\it y} (mm)');zlabel('{\it z} (mm)');
    % print(gcf,'-dpng','-r600',['First phase\sensor_move\sensor_',int2str(j),'.png']);
end

plot_sensor_board(60,30, mean(us00,2),mean(thetas00,2),[165,214,167]/255,[0.3,0.3,0.3],0.5)
% print(gcf,'-dpng','-r600',['First phase\sensor_move\sensor_',int2str(j+1),'.png']);
    

function plot_sensor_board(width,height,us,thetas,facecolor,edgecolor,alpha)
    size_matrics = [[width/2,height/2,0,1]',[-width/2,height/2,0,1]',[-width/2,-height/2,0,1]',[width/2,-height/2,0,1]'];
    R = Exp(thetas);
    P = us + Exp(thetas)*[0,0,1]';
    T = [R,P;0,0,0,1];
    p_id = T*size_matrics;
    p_id = p_id(1:3,:);
    fill3(p_id(1,:),p_id(2,:),p_id(3,:),facecolor,'FaceAlpha',alpha, ...
            'EdgeColor',edgecolor,'EdgeAlpha',alpha/2,'LineWidth',1);
end