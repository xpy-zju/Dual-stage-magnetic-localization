classdef frame_graph < handle
    %FRAME_GRAPH 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        d
        ax
    end
    
    methods
        function obj = frame_graph(d,ax)
            %FRAME_GRAPH 构造此类的实例
            %   此处显示详细说明
            if nargin<2
                obj.d = digraph;
               %obj.ax = gca;
            else
                obj.d = d;
                obj.ax =ax;
            end
        end
        
        function addnodes(obj,frame,pname)
            if nargin<3
                NodeProp = table(frame.name,frame,'VariableNames',{'Name','Handle'},'RowNames',frame.name);
                obj.d = obj.d.addnode(NodeProp);
            else
                NodeProp = table(frame.name,frame,'VariableNames',{'Name','Handle'},'RowNames',frame.name);
                obj.d = obj.d.addnode(NodeProp);
                obj.d = obj.d.addedge(frame.name,pname);
            end
        end
        
        function p = get_points_at(obj,p,src_node,dst_node)
            [R,T] = obj.get_transfer(src_node,dst_node);
            p = R*p+T;
        end

        function v = get_vector_at(obj,v,src_node,dst_node)
            [R,~] = obj.get_transfer(src_node,dst_node);
            v = R*v;
        end
        function pose_new = get_pose_at(obj,pose,src_node,dst_node)
            [R,T] = obj.get_transfer(src_node,dst_node);
            p =reshape(pose(1:3),[3,1]);
            v = reshape(pose(4:6),[3,1]);
            p = R*p+T;
            v_new = Log(R*Exp(v));
            pose_new = [p;v_new]';
            if sum(isnan(pose_new))
            ;
            disp("exist nan")
            end

        end
        function pose = get_frame_pose(obj,src_node,dst_node)
            [R,T] = obj.get_transfer(src_node,dst_node);
            pose = [reshape(T,[1,3]),reshape(Log(R),[1,3])];
        end
        function [R,T] = get_transfer(obj,src_node,dst_node)
            % R = ^{dst_node}R_{src_node}
            % T = ^{dst_node}T_{src_node}
            [RA,TA,rA] = obj.get_root(src_node);
            [RB,TB,rB] = obj.get_root(dst_node);
            if ~isequal(rA,rB)
                remark = src_node+"与"+dst_node+"根节点不相连";
                error(remark);
            end
            R = RB'*RA;
            T = RB'*(TA-TB);
        end

        function [R,T,root_name] = get_root(obj,src_node)
            nodes = obj.d.dfsearch(src_node);
            R = eye(3);T =zeros(3,1);
            for i=1:length(nodes)
                h = obj.d.Nodes.Handle(nodes(i));
                R = h.R*R;
                T = h.R*T+h.u;
            end
            root_name = h.name;

        end

        function plot(obj)
            if isempty(obj.ax)
                obj.ax = gca;
            end
            plot(obj.ax,obj.d);
        end
        function nodes = get_all_nodes(obj)
            nodes = string(obj.d.Nodes.Name);
        end
        
        function show_all_at_ref(obj,ref_name)
            nodes = obj.get_all_nodes;
            for i = 1:length(nodes)
                [R,T] = obj.get_transfer(nodes(i),ref_name);
                px = poseplot(obj.ax,R',T,ScaleFactor=100);
                px.DisplayName = nodes(i);
                hold(obj.ax,"on");
            end
            legend;
            title(ref_name);
            xlabel("x");
            ylabel("y");
            zlabel("z");
        end
        
        function show_select_at_ref(obj,select,ref,scale)
            [R,T] = obj.get_transfer(select,ref);
            px = poseplot(obj.ax,R',T,"ENU",ScaleFactor=scale);
            px.DisplayName = select;
            text(obj.ax,T(1)+0.7*scale,T(2)+0.7*scale,T(3)+scale,select);
            hold(obj.ax,"on");
        end

        function show_all_at_base(obj,noshowlist,scale)
            nodes = obj.get_all_nodes;
            hold(obj.ax,"off");
            if nargin<3
                scale = 50;
            end
            if nargin<2
                noshowlist = [];
            end
            
            for i = 1:length(nodes)
                [R,T,r] = obj.get_root(nodes(i));
                if ~sum(strcmp(noshowlist,nodes(i)))
                    px = poseplot(obj.ax,R',T,"ENU",ScaleFactor=scale,PatchFaceAlpha=0.2);
                    px.DisplayName = nodes(i);
                    text(obj.ax,T(1)+70,T(2)+70,T(3)+100,nodes(i));
                    hold(obj.ax,"on");
                end
                snode = obj.d.successors(nodes(i));
                if(~isempty(snode))
                    [~,T2,~] = obj.get_root(snode);
                    plot3(obj.ax,[T(1),T2(1)],[T(2),T2(2)],[T(3),T2(3)],Color=[0,0,0],LineStyle="--");
                end
            end
            title(obj.ax,r);
            xlabel(obj.ax,"x");
            ylabel(obj.ax,"y");
            zlabel(obj.ax,"z");
            grid(obj.ax,"on");
            axis(obj.ax,"equal");
        end

        function addnodes_struct(obj,fs)
            if isempty(fs.ref_frame_name)
                f = frame2(fs.u,fs.R,fs.name);
                NodeProp = table(string(f.name),f,'VariableNames',{'Name','Handle'},'RowNames',string(f.name));
                obj.d = obj.d.addnode(NodeProp);
            else
                f = frame2(fs.u,fs.R,fs.name);
                NodeProp = table(string(f.name),f,'VariableNames',{'Name','Handle'},'RowNames',string(f.name));
                obj.d = obj.d.addnode(NodeProp);
                obj.d = obj.d.addedge(fs.name,fs.ref_frame_name);
            end
        end

        function addnodes_json(obj,js)
            if ~exist(js,"file")
                return
            end
            js_data = fileread(js);
            struct_queue = jsondecode(js_data);
            for i=1:length(struct_queue)
                obj.addnodes_struct(struct_queue(i));
            end
        end
        
        function write_to_json(obj,js)
            nodes = obj.get_all_nodes;
            struct_queue = [];
            for i = 1:length(nodes)
                h = obj.d.Nodes.Handle(nodes(i));
                struct_queue = [struct_queue,struct("name",nodes(i),"u",h.u,"R",h.theta,"ref_frame_name",obj.d.successors(nodes(i)))];
            end
            js_data = jsonencode(struct_queue,"PrettyPrint",false);
            fid = fopen(js,"w");
            fprintf(fid,"%s",js_data);
            fclose(fid);
        end

        function delete_nodes(obj,node_name)
            obj.d = obj.d.rmnode(node_name);
        end
        function set_axis(obj,ax)
            obj.ax = ax;
            hold(ax,"off");
        end
    end
end

