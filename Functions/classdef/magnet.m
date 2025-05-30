classdef magnet < handle
    %MAGNET 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties(Access = public)
        M %总体磁矩
        L
        R
        
        remark
    end
    properties(Dependent)
    V
    m
    size
    end
 
    
    methods 
        %构造函数
        function obj = magnet(remark,size)
            %MAGNET 构造此类的实例
            %   此处显示详细说明
            obj.remark = remark;
            obj.L = size(1); %圆柱形高度的一半 mm
            obj.R = size(2); %圆柱形半径 mm
           
        end
        %Get方法
        function V = get.V(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            V = 2*obj.L*obj.R^2*pi;
           
        end

        function m = get.m(obj)
            if ~isempty(obj.M)
                m = obj.M*obj.V;
            end
            
        end

        function size = get.size(obj)
            size(1) = obj.L;
            size(2) = obj.R;
        end
    end
end

