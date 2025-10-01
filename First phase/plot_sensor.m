function plot_sensor(sensor_inf,psize,facecolor,edgecolor,alpha)
    for id = 1:size(sensor_inf,2)
        p_center = sensor_inf(1:3,id);
        R_center = Exp(sensor_inf(4:6,id));
        T = [R_center,p_center;0,0,0,1];
        size_matrics = [[psize,psize,0,1]',[-psize,psize,0,1]',[-psize,-psize,0,1]',[psize,-psize,0,1]'];
        p_id = T*size_matrics;
        p_id = p_id(1:3,:);
        fill3(p_id(1,:),p_id(2,:),p_id(3,:),facecolor,'FaceAlpha',alpha/2, ...
            'EdgeColor',edgecolor,'EdgeAlpha',alpha);
        hold on 
    end
end