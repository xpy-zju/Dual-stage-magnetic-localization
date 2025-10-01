obj = OptiTrack;
obj.Initialize;
while true
    rb = obj.RigidBody;
    fprintf('\nFrame Index: %d\n',rb(1).FrameIndex);
    % 遍历所有刚体
    for i = 1:numel(rb)
        fprintf('- %s, Tracking Status: %d\n',rb(i).Name,rb(i).isTracked);
        if rb(i).isTracked
            % 组成变换矩阵%
            if rb(i).Name == "Sensor_part"
                T_sensor_rigid = [rb(i).Rotation, rb(i).Position; 0 0 0 1];
                T_sensor(T_sensor_rigid, [0,0,0]')  % 取用传感器的位姿

            elseif rb(i).Name == "Small_magnet"
                T_Small_magnet_rigid = [rb(i).Rotation, rb(i).Position; 0 0 0 1];
                T_small_magnet(T_Small_magnet_rigid, [0,0,0]') % 取用小磁铁的位姿
                
            end
        else
            fprintf('\t Position []\n');
            fprintf('\t Quaternion []\n');
        end
    end
end
        