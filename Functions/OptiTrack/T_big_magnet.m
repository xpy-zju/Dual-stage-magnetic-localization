function T = T_big_magnet(T_rigid)
    sphere_r = 6.1;
    r=[0,0,0]';
    centroid_temp = [0, 35+sphere_r , 0]';
    R = [[-1,0,0]',[0,0,1]',[0,1,0]'];

    p = - centroid_temp+R*r;
    
    T = T_rigid * [[R, p];[0,0,0,1]];
end