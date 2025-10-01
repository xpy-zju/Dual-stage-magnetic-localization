classdef ur < handle
    %UR 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        stamp
        myUDP
        Dest_addr
        Dest_port
        URMsgQueue%UR消息队列
        app
        enable_status
        data_temp
        data_ready
        data_valid
    end
    


    methods
        function obj = ur(apphandle)
            %UR 构造此类的实例
            %   此处显示详细说明
           % Local_addr = '172.20.172.181';
           Local_addr = '127.0.0.1';
             Local_port = 8000;
           % obj.Dest_addr = '172.20.172.103';
            obj.Dest_addr = '127.0.0.1';
            obj.Dest_port = 8001;
            obj.myUDP = udpport('IPV4',...
                'LocalHost',Local_addr,...
                'LocalPort',Local_port);
            configureCallback(obj.myUDP,"terminator",@obj.readUDPData);
            obj.URMsgQueue = fifo_queue(22000,"");
            obj.stamp = 0;
            obj.enable_status = [true,false];
            obj.app = apphandle;
            obj.data_ready = false;
        end
        
        function data = readUDPData(obj,src,~)
            %readUDPData 接收数据回调
            %   详细说明见下列注释
            obj.data_valid = false;
            if(src.NumBytesAvailable == 0)
                data = [];
                return
            end

            %读取并解析接收到的信号帧
            %信号帧格式
            % id:[1*1 double]
            % mode:[1*1 double]
            % pose: [1*6 double]
            % deg:[1*6 double]
            % enable:[1*1 logic]
            % relative:[1*1 logic]
            data = readline(src);
            data_struct = jsondecode(data);
            %将接收到的单位转成mm
            data_struct.pose(1:3) = data_struct.pose(1:3)*1000;
            obj.data_temp = data_struct;
            
            % if data_struct.mode == 2
            %     obj.data_valid = true;
            % else
            %     obj.data_valid = false;
            % end
            obj.data_ready = true;
           
        end
        function delete(obj)
            delete(obj.myUDP);
            disp("URMsgQueue队列清空");
            obj.URMsgQueue.clear();
            
        end
        
        function set_single_msg(obj,ur_std_msg)
            %SET_SINGLE_MSG 只发送一条命令
            %一条ur_std_msg为URMsgQueue的成员，内部包含两条ur_std_frame
            ur0 = ur_std_msg.ur0;
            if(ur0.enable)
                if(ur0.mode==0)
                    ur0.mode = 2;%默认发送movej
                end
                obj.send_json_to_Dest_UDP(ur0);
            end
            %obj.app.update_UR_status_Panel(ur0);

            ur1 = ur_std_msg.ur1;
            if(ur1.enable)
                if(ur1.mode==0)
                    ur1.mode = 2;%默认发送movej
                end
                obj.send_json_to_Dest_UDP(ur1);
            end
            try ur2 = ur_std_msg.ur2;
                %obj.app.update_UR_status_Panel(ur1);
                if(ur2.enable)
                    if(ur2.mode==0)
                        ur2.mode = 2;%默认发送movej
                    end
                    obj.send_json_to_Dest_UDP(ur2);
                end
            catch
            end
        end
        function get_msg(obj,id)
            %GET_MSG 向机械臂id发送消息
            %命令帧格式
                    % id:[1*1 double]
                    % mode:[1*1 double]
                    % pose: [1*6 double]
                    % deg:[1*6 double]
                    % enable:[1*1 logic]
                    % relative:[1*1 logic]
                    obj.data_ready = false;
        ur_std_frame = struct("id",id,...
            "mode",0,...
            "pose",zeros(1,6),...
            "deg",zeros(1,6),...
            "enable",false,...
            "relative",false);
        obj.send_json_to_Dest_UDP(ur_std_frame);
        end
        function send_json_to_Dest_UDP(obj,ur_std_frame)
            %SEND_JSON_TO_DEST_UDP
            % u = udpport('IPV4',...
            %     'LocalHost','127.0.0.1',...
            %     'LocalPort',8002);

        %writeline(obj.myUDP,jsonencode(ur_std_frame),obj.Dest_addr,obj.Dest_port);
        u = obj.myUDP;
        Da = obj.Dest_addr;
        Dp = obj.Dest_port;
        %这里默认将发送的pose除以1000，转成m
        ur_std_frame.pose(1:3) = ur_std_frame.pose(1:3)/1000;
        writeline(u,jsonencode(ur_std_frame),Da,Dp);
        end
    end

    methods(Access=public)
    end
end

