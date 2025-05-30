classdef realtime_filter < handle
    %FILTER 实时滤波类，仅关联于单个传感器的三通道数据
    %   带auto_reboot的自适应滤波功能，当数据跳变幅度过大时，将自动重启滤波器

    properties(Access = public)
        data
        enable
        auto_reboot
        remark
        id %滤波器编号
        algorithm % 0为默认，递推平均滤波 1为卡尔曼
        threshold
    end
    properties(Access = private)
        %Kalman related
        Pkn
        Q
        R
        %Slide window related
        N
        data_buf
        %reboot waitlist
        reboot_waitlist
        reboot_waitlist_max_size

        status
    end


    methods(Access=public)
        function obj = realtime_filter(remark,id,N)
            %FILTER 构造此类的实例
            %   此处显示详细说明

            obj.data = zeros(3,1);
            obj.status = false;
            obj.enable = true;
            obj.auto_reboot = true;
            obj.remark = remark;
            obj.id = id;
            if nargin<3
                obj.algorithm = 0;
                obj.KalmanInit();
            else
                obj.algorithm = 1;
                obj.SlideWindowInit(N);
            end
            obj.threshold = 15;
            obj.reboot_waitlist_max_size = 3;
            obj.reboot_waitlist = fifo_queue(obj.reboot_waitlist_max_size,...
                obj.remark+"reboot_waitlist");

        end

        function data = update(obj,new_data)
            %UPDATE 滤波器更新
            %   此处显示详细说明
            if ~obj.status||~obj.enable
                obj.data = new_data;
                data = new_data;
                if obj.enable
                    obj.status = true;
                end
                return
            end
            
           
            if obj.auto_reboot
                obj.reboot(new_data);
            end
            switch obj.algorithm
                case 0
                    obj.KalmanUpdate(new_data)
                case 1
                    obj.SlideWindowUpdate(new_data)
                otherwise
                    obj.data= new_data;
            end
            data = obj.data;
        end

        function data = get_data(obj)
            %DATA 获取最新数据
            %   此处显示详细说明
            data = obj.data;
        end

        function forced_reboot(obj)
            %FORCED_REBOOT 强制重启滤波器
            %   此处显示详细说明
            switch obj.algorithm
                case 0
                    obj.KalmanInit();
                case 1
                    obj.SlideWindowInit(obj.N);
                otherwise
            end
        end


    end
    methods(Access =private)
        function reboot(obj,new_data)
            %REBOOT 判断是否重启
            if (obj.reboot_waitlist.len == 0)
                obj.reboot_waitlist.append(new_data);
                return
            end
            temp = max(abs(new_data-obj.reboot_waitlist.index(1)));
            if(temp>obj.threshold)
                obj.reboot_waitlist.append(new_data);
            end
            if(obj.reboot_waitlist.len>obj.reboot_waitlist_max_size-1)
                obj.reinit();
                obj.reboot_waitlist.clear();
                obj.status = false;
            end


        end


        function reinit(obj)
            switch obj.algorithm
                case 0
                    obj.KalmanInit();
                case 1
                    obj.SlideWindowInit(obj.N);
                otherwise
            end

        end


        function KalmanInit(obj)
            obj.Pkn = eye(3)*10000;
            obj.R = diag([5.5280,5.2183,5.42440]);
            obj.Q = eye(3)*1e-5;
        end
        function KalmanUpdate(obj,new_data)
            nPkn = obj.Pkn+obj.Q;
            zk = new_data;
            xkn = obj.data;
            Kk = nPkn/(nPkn+obj.R);
            %Kk = nPkn*inv(nPkn+obj.R);
            xk = xkn+Kk*(zk-xkn);
            Pk = (eye(3)-Kk)*nPkn;
            obj.data = xk;
            obj.Pkn = Pk;
        end
        function SlideWindowInit(obj,N)
            obj.data_buf = fifo_queue(N);
            obj.N = N;

        end
        function SlideWindowUpdate(obj,new_data)
            db = obj.data_buf;
            db.append(new_data);
            obj.data= mean(db.get_last_N_data(db.len),2);
        end


    end

end


