classdef fifo_queue <handle
    %FIFO_QUEUE 数据循环队列相关类
    %   此处显示详细说明

    properties(Access = public)
        max_size (1,1){mustBeNonnegative,mustBeNumeric}
        len (1,1)
        remark
        filename
        
    end

    properties(Access = private)
        data
        head (1,1)
        rear (1,1)
        save_index = 0
    end

    methods(Access = public)
       
        function obj = fifo_queue(max_size,remark)
            %FIFO_QUEUE 初始化队列
            %   此处显示详细说明
            if nargin  ==2
                obj.remark = remark;
            else
                obj.remark = "";
            end

            obj.max_size = max_size;
            obj.data = cell(1,max_size);
            obj.head = 1;
            obj.rear = 1;
            obj.len = 0;

        end
        function [data,head,rear] = get_full_data(obj)
            data = obj.data;
            head = obj.head;
            rear = obj.rear;
        end
        function copy_data(obj,new_fifo)
            if obj.max_size~=new_fifo.max_size
                error("数据长度不同，不可复制！");
            end
            [obj.data,obj.head,obj.rear] = new_fifo.get_full_data;
        end
        function set_filename(obj,filename,RootFilename)
            %SET_FILENAME 设置队列关联的文件保存路径
            if nargin<3
            RootFilename = string(pwd)+'\DataLog\';
            end
            obj.filename = RootFilename+filename+'\URMsgDataLog';
            disp("设置当下写文件目录为"+obj.filename);
            if(~exist(obj.filename,"dir"))
                mkdir(obj.filename);
                obj.save_index = 0;%若该目录为空，将其设置为0，表示文件名从0开始递增
            end
        end
        function log_json_data_to_file(obj,filepath,filename,status)
            if nargin<4
                status =0;
            end
            full_filename =filepath+"\"+filename+".json";
            if status == 0
                mkdir(filepath);
                fid = fopen(full_filename,"w");
                fprintf(fid,"[");
                for i = 1:obj.len
                    jsondata = jsonencode(obj.index(i));
                    fprintf(fid,'%s',jsondata);
                    if i<obj.len
                        fprintf(fid,",\n");
                    else
                        fprintf(fid,"]");
                    end
                end
            elseif status == 1
                fid = fopen(full_filename,"a");
                for i = 1:obj.len
                    jsondata = jsonencode(obj.index(i));
                    fprintf(fid,'%s',jsondata);
                    fprintf(fid,",\n");
 
                end     
            end
             fclose(fid);
                disp("saving:"+full_filename);
                disp("成功写入"+num2str(obj.len)+"条命令")
                obj.save_index = obj.save_index+1;
        end
        function log_data_to_file(obj,DataType,datafilename)
            %LOG_DATA_TO_FILE 将队列中的所有数据保存至filename中
            %obj.filename示例："RootFilename\DataLog\第十二次实验"
            if nargin<3
                datafilename = obj.remark+num2str(obj.save_index,"%06d");
            end
            if(isempty(obj.filename))
                %若默认路径为空，设置其至DataLog\temp目录
                error("当前filename目录为空，请通过set_filename方法设置保存根目录")
            end
            if strcmp(DataType,'parquet')
                %若保存为parquet模式，将队列中所有数据转成列表
                %队列中的数据应默认保存成行向量中需要含timestamp
                full_filename = obj.filename+"\"+datafilename+".parquet";
                obj.save_index = obj.save_index+1;
                data_to_be_save = obj.get_last_N_data(obj.len);
                parquetwrite(full_filename,data_to_be_save);
                disp("saving:"+full_filename+num2str(obj.len)+"条table数据");
                return
            end
            if strcmp(DataType,'json')
                %若保存为json模式，将cell转换为json后写入文件
                full_filename = obj.filename+"\"+datafilename+".json";
                fid = fopen(full_filename,"w");
                fprintf(fid,"[");
                for i = 1:obj.len
                    jsondata = jsonencode(obj.index(i));
                    fprintf(fid,'%s',jsondata);
                    if i<obj.len
                        fprintf(fid,",\n");
                    else
                        fprintf(fid,"]");
                    end
                end
                fclose(fid);
                disp("saving:"+full_filename);
                disp("成功写入"+num2str(obj.len)+"条命令")
                obj.save_index = obj.save_index+1;
            end
            
            
        end
        function [datatemp,c,sz] = type(obj)
        %TYPE 获取数据类型
            if obj.len == 0
                disp("队列为空");
                datatemp = [];
                c = "null";
                sz = [0,0];
                return;
            else
                datatemp = obj.get_last_N_data(1);

                sz = size(datatemp);
                c = class(datatemp);
                disp("class:"+class(datatemp)+" size"+num2str(sz));
            end
        end


        function length = append(obj,new_data)
            %APPEND 新向量入队
            %   obj.append(new_item)
            %类型检查
            

            if obj.head ==obj.rear &&obj.len == obj.max_size
                %队满头加1
                obj.head = obj.single_add(obj.head);
            end
            obj.data{obj.rear} = new_data;
            obj.rear = mod(obj.rear,obj.max_size)+1;
            obj.len = min(obj.max_size,obj.len+1);
            length = obj.len;
        end
        function data = pop_head(obj)
            if obj.len == 0
                disp("The queue" +obj.remark+"is empty!");
                data = [];
                return
            else
                data = obj.get_item(obj.head);
                obj.head = obj.single_add(obj.head);
                obj.len = obj.len-1;
            end
        end
        function data = pop(obj)
            %POP 删除最后一个入队的数列
            if obj.len == 0
                disp("The queue" +obj.remark+"is empty!");
                data = [];
                return
            else
                obj.rear = obj.single_sub(obj.rear);
                data = obj.data{obj.rear};
                obj.len = obj.len-1;
            end
        end
        function data= get_last_N_data(obj,N)
            %GET_LAST_N_DATA 获取最后N个队列数据，构成数组
            %检查队列元素数据类型，若为一维vector，则返回为二维矩阵
            %若为二维以上矩阵或其他类型的数据，则返回为cell
            if(obj.len == 0)
                disp("The queue" +obj.remark+"is empty!")
                data = [];
                return;
            end
            if(obj.len<N)
                disp("数组"+obj.remark+"长度小于N，仅返回"+num2str(obj.len)+"个数据");
                index = obj.resort(obj.head,obj.rear);

            else
                index = obj.resort(obj.multiple_sub(obj.rear,N),obj.rear);
            end
            %若为vector 构成矩阵返回
            data = obj.get_item(index);
        end
        function clear(obj)
            %CLEAR 清空队列
            %obj.data = cell(1,obj.max_size);
            obj.head = 1;
            obj.rear = 1;
            obj.len = 0;
        end

        function data = index(obj,a,b)
            % INDEX 索引队列， 
            % 调用格式：obj.index(x) obj.index(start,end)
            if nargin<3
                if(a>obj.len)
                    error("索引大于队列"+obj.remark+"长度，索引应小于"+num2str(obj.len));
                end
                index = obj.multiple_add(obj.head,a-1);
                data = obj.get_item(index);
            else
                if(b<a)||(b>obj.len)
                    error("索引大于队列已有元素");
                end
                index = obj.resort(obj.multiple_add(obj.head,a-1),obj.multiple_add(obj.head,b));
                data = obj.get_item(index);
            end
        end



    end

    methods(Access=private)
        function out = single_add(obj,num)
            out = mod(num,obj.max_size)+1;
        end
        function out =multiple_add(obj,num,n)
            out = num+n;
            if out>obj.max_size
                out = out-obj.max_size;
            end
        end

        function out = single_sub(obj,num)
            out = num-1;
            if out == 0
                out = num-obj.max_size;
            end
        end

        function out = multiple_sub(obj,num,n)
            out = num-n;
            if(out<1)
                out = obj.max_size+out;
            end
        end

        function data = get_item(obj,index)
            item = obj.data{obj.head};
            if isa(item,'numeric')&&length(size(item))<3&&min(size(item)) == 1
                l = length(item);
                data = cellfun(@(x) reshape(x,l,1),obj.data(index),'UniformOutput',false);
                data = [data{:}];
            elseif isa(item,'table')
                %table，返回table构成的表
                data = obj.data(index);
                data = vertcat(data{:});
            else
                %直接返回cell
                data = obj.data(index);
                if length(data)==1
                    data = data{1};
                end
            end 
        end

        function out = resort(obj,a,b)
            if a<b
                out =a:obj.single_sub(b);
            elseif a>b
                out = [a:obj.max_size,1:obj.single_sub(b)];
            elseif a==b||obj.len == obj.max_size
                out = [a:obj.max_size,1:obj.single_sub(b)];
            else
                out = [];
            end
        end


    end
end

