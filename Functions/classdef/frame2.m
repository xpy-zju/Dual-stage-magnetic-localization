classdef frame2 < handle
    %FRAME2 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties(Access=public)
        u = [0,0,0]';%相对基准坐标系的平移矢量（基准坐标系下）
        theta =[0,0,0]';%相对基准坐标系的姿态矢量，轴角表示（基准坐标系下）
        name %坐标系名称
    end
    
    methods
        function obj = frame2(u,theta,name)
            %FRAME2 构造此类的实例
            %   此处显示详细说明
            obj.set_u(u);
            obj.set_theta(theta);
            obj.name = name;
        end
        function set_u(obj,u)
            obj.u = reshape(u,[3,1]);
        end

        function set_theta(obj,theta)
            if isequal(size(theta),[3,3])
                obj.theta = Log(theta);
            else
                obj.theta = reshape(theta,[3,1]);
            end
        end
        function out = R(obj)
            out = Exp(obj.theta);
        end
    
    end
    methods(Access = private)
        
    end
end

