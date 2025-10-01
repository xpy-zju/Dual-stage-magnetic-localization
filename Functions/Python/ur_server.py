# 　　　　　　　　┏┓　　　┏┓+ +
# 　　　　　　　┏┛┻━━━┛┻┓ + +
# 　　　　　　　┃　　　　　　　┃ 　
# 　　　　　　　┃　　　━　　　┃ ++ + + +
# 　　　　　　 ████━████ ┃+
# 　　　　　　　┃　　　　　　　┃ +
# 　　　　　　　┃　　　┻　　　┃
# 　　　　　　　┃　　　　　　　┃ + +
# 　　　　　　　┗━┓　　　┏━┛
# 　　　　　　　　　┃　　　┃　　　　　　　　　　　
# 　　　　　　　　　┃　　　┃ + + + +
# 　　　　　　　　　┃　　　┃　　　　　　　　
# 　　　　　　　　　┃　　　┃ + 　　　　神兽保佑,无bug　　
# 　　　　　　　　　┃　　　┃
# 　　　　　　　　　┃　　　┃　　+　　　　　　　　　
# 　　　　　　　　　┃　 　　┗━━━┓ + +
# 　　　　　　　　　┃ 　　　　　　　┣┓
# 　　　　　　　　　┃ 　　　　　　　┏┛
# 　　　　　　　　　┗┓┓┏━┳┓┏┛ + + + +
# 　　　　　　　　　　┃┫┫　┃┫┫
# 　　　　　　　　　　┗┻┛　┗┻┛+ + + +   
from copy import deepcopy
import urx
import socket
import threading
import time
import sys
import json
import copy
import logging
class UR_execute(threading.Thread):
    def __init__(self,UR,pose,relative,recv_msg,id,is_movel=True):
        """
        UR:urx句柄
        pose: 若为movel为pose;若为movej为deg
        relative:True表示绝对位置移动 False表示相对位置移动
        recv_msg:表示udp接收线程的句柄,udp同时接收来自matlab端UR0与UR1的命令,通过recgv_msg类下的is_busy区分机械臂下位机状态和线程状态
        id:区分该条线程针对哪个UR
        is_movel: True表示执行movel,False表示执行movej
        """
        self.UR = UR
        self.pose = pose
        self.recv_msg = recv_msg
        self.relative = relative
        self.id = id
        self.movel = is_movel
        threading.Thread.__init__(self)
    def run(self):
        if self.movel:
            self.UR.movel(self.pose,acc=0.3,vel=0.3,relative=self.relative)
        else:
            deg = self.pose#此处的self.pose 表示为六个关节的关节角
            self.UR.movej(deg,acc=0.3,vel=0.3)
        #释放状态
        self.recv_msg.is_busy[self.id] = False

class Recv_msg(threading.Thread):
    def __init__(self,udp_socket,ip_port):
        """
        ip_port: tuple  ('172.20.172.xxx',7890)
        """
        
        
        self.ip_port = ip_port
        self.udp_socket = udp_socket
        self.execute_ur0 = []
        self.execute_ur1 = []
        self.execute_ur2 = []
        self.execute = []
        threading.Thread.__init__(self)
        
        
    def UR_initialize(self):
        self.UR = {}
        self.UR_key = ['UR0','UR1','UR2']
        self.Running = True#Running用于退出Recv_msg线程
        self.is_busy = [True,False,False]
        self.is_connect = [False,True,True]
        #UR 0
        if self.is_busy[0]==False:
            logging.basicConfig(level=logging.WARN)
        
            rob = urx.Robot("172.20.172.102")
        
            rob.set_tcp((0,0,0,0,0,0))#设置工具坐标系
            #rob.set_payload(0.5,(0,0,0))#设置负载
            time.sleep(0.1)
            pose = rob.getl()
            print("--------------------------")
            print(f"robot 0 tcp is at:{pose}")
            self.UR['UR0']=rob
        #UR 1
        if self.is_busy[1] == False:
            logging.basicConfig(level=logging.WARN)
        
            rob = urx.Robot("172.20.172.4")#这里请改成具体的ip地址
        
            rob.set_tcp((0,0,0,0,0,0))#设置工具坐标系
            #rob.set_payload(1.65,(0,0,0))#设置负载
            time.sleep(0.1)
            pose = rob.getl()
            print("--------------------------")
            print(f"robot 1 tcp is at:{pose}")
            self.UR['UR1']=rob
        #UR 2
        if self.is_busy[2] == False:
            
            logging.basicConfig(level=logging.WARN)
        
            rob = urx.Robot("172.20.172.3")#这里请改成具体的ip地址
        
            rob.set_tcp((0,0,0,0,0,0))#设置工具坐标系
            #rob.set_payload(1.65,(0,0,0))#设置负载
            time.sleep(0.1)
            pose = rob.getl()
            print("--------------------------")
            print(f"robot 2 tcp is at:{pose}")
            self.UR['UR2']=rob
        
        
        
    def run(self):
        """
        线程的运行模式：
        同时接收id0与id1的信号
        若程序中初始化时is_busy[id]设置为了True,则对应id的指令请求被阻塞,统一反馈默认值给matlab端。
        若初始化时is_busy[id]为False,而后续执行指令时该标志位会自动设置为True,直到UR_execute线程执行完毕释放该标志位;故使用者需要根据机械臂的实际情况在初始化时合理配置is_busy[id]
        """
        self.UR_initialize()
        self.execute = []
        pose = [0,0,0,0,0,0]
        relative = True
        #(self,UR,pose,relative,recv_msg,id,is_movel=True)
        #execute = UR_execute(self.UR[0],pose,relative,self,0,True)
        #self.execute.append(execute)
      
        #URDegDataLog格式：
        #struct:
        #stamp:[1*1 double] 
        #ur0:[1*1struct]  
        #ur1:[1*1struct]
        #ur0:
            #id:[1*1 double]
            #mode:[1*1 double] 0:查询状态 1:movel 2:movej
            #pose: [1*6 double] mode 0 1 起效
            #deg:[1*6 double]  mode 0 2 起效
            #enable:[1*1 logic]  mode 1 2 起效
            #relative:[1*1 logic] mode 1 起效

        while self.Running:
            self.udp_socket.settimeout(0.5)
            #设置超时等待时间为0.5s
            try:
                data = self.udp_socket.recvfrom(1024)
                #data[0]为接收到的数据 data[1]为接收方的ip和端口号
                recv_data = json.loads(data[0])
                mode = recv_data['mode']
                id = recv_data['id']
                enable = recv_data['enable']
                if id == 0:
                    self.execute = self.execute_ur0
                if id == 1:
                    self.execute = self.execute_ur1
                if id ==2:
                    self.execute = self.execute_ur2

                if (not self.is_busy[id]) or (id != 0 and mode == 0):
                #if (not self.is_busy[id]) or (id == 2 or mode ==0):
                    if mode == 0:   #查询TCP位姿,发送
                        rob = self.UR[self.UR_key[id]]
                        pose = rob.getl()
                        deg = rob.getj()
                        #enable 1 表示机械臂空闲, 当且仅当机械臂空闲时返回机械臂位置命令
                        data = json.dumps({"id":id,"mode":2,"pose":pose,"deg":deg,"enable":True,"relative":False})
                        data = data+"\r\n"
                        #print(f"robot {id} tcp is at:pose:{pose} deg:{deg}")
                        self.udp_socket.sendto(data.encode('utf-8'),self.ip_port)
                        #print("robot pos send finish.")
                    if mode == 1:   #发送机械臂movel指令,直线运动到某个点
                        if enable == False:#若该条为无效指令,退出后续操作
                            continue
                        self.is_busy[id] = True #此处令is_busy标志位处于繁忙中,在之后的UR_execute的run线程予以释放
                        
                        pose = recv_data['pose']
                        relative = recv_data['relative']
                        
                        execute_temp = UR_execute(self.UR[self.UR_key[id]],pose,relative,self,id,True)
                        self.execute.append(execute_temp)
                        self.execute[-1].start()#开始执行对机械臂id执行UR_execute线程,在此处为对机械臂id执行movej命令
                        print("move data sent")
                    if mode == 2:   #发送机械臂movej指令,运行到机械臂的某个关节角姿态
                        if enable == False:#若该条为无效指令,退出后续操作
                            continue
                        self.is_busy[id] = True
                        deg = recv_data['deg']
                        relative = False #执行movej时,默认relative为False
                        self.execute.append(UR_execute(self.UR[self.UR_key[id]],deg,relative,self,id,False)) #第一个False表示进行绝对坐标移动,第二个False表示执行movej命令,由于第二个False对应的参数is_movel存在默认参数True,故在mode==1时无此参数
                        self.execute[-1].start()#开始执行对机械臂id执行UR_execute线程,在此处为对机械臂id执行movel命令

                        
                else:   #返回繁忙信号,当py端得知机械臂处于繁忙状态但接收到来自matlab端的请求时
                    #机械臂直接向matlab端返回繁忙状态和全为0的pose信息
                    if self.is_connect[id]:
                        rob = self.UR[self.UR_key[id]]
                        pose = rob.getl()
                        deg = rob.getj()
                    else:
                        pose = [0,0,0,0,0,0]
                        deg = [0,0,0,0,0,0]
                    data = json.dumps({"id":id,"mode":0,"pose":pose,"deg":deg,"enable":False,"relative":False})
                    data = data+"\r\n"
                    self.udp_socket.sendto(data.encode('utf-8'),self.ip_port)
                    print(f"robot {id} is busy !")
            except:
                pass

            time.sleep(0.01)
        

        for UR_handle in self.UR.values():
            UR_handle.close()



def main():
    # 1、创建套接字1
    
    udp_socket = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
    
    # 2、绑定本地信息
    #udp_socket.bind(("172.20.172.103",8001))
    udp_socket.bind(("127.0.0.1",8001))
    # 3、获取对方的ip
    #dest_ip = '172.20.172.181'
    dest_ip = '127.0.0.1'
    dest_port = 8000
    # 4、创建线程
    
    t_recv = Recv_msg(udp_socket,(dest_ip,dest_port))

    t_recv.start()
    while True:
        key = input("Please quit with Q or q\r\n")
        
        if key =='q' or key == 'Q':
                print("Enter the exit process")
                t_recv.Running = False
                t_recv.join()
                udp_socket.close()
                break
        time.sleep(0.1)

if __name__=="__main__":
    main()
                