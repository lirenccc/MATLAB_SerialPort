clear
clc

%% 列举可用串口
Port_List = serialportlist("available");
disp(Port_List);

%% 串口配置
% 串口名
port_name = 'COM16';
% 波特率
baudrate = 115200;

% 声明串口对象
SerialObj = serialport(port_name, baudrate);

% 检测的帧尾
configureTerminator(SerialObj, "CR/LF");
% 清空串口对象的接收缓存区
flush(SerialObj);

SerialObj.UserData = struct("Data", [],  "Result", []);
disp("配置完成");

%% 回调函数
configureCallback(SerialObj,"terminator",@readSerialData);

% 采集数据点的数量
while(1)
    if(size(SerialObj.UserData.Result, 1) >= 200)
        result = SerialObj.UserData.Result;
        break
    end
end

delete(SerialObj);


%%
% 回调函数
function readSerialData(src, ~)
    data = read(src, 20, "uint8");
    src.UserData.Data = data;
    press = Process(src);
    disp(size(src.UserData.Result, 1)+1);
    disp(press);
    src.UserData.Result = [src.UserData.Result; press];
end
 
% 数据处理
function press = Process(src)
    if(src.UserData.Data(1:2) == [0xFF 0xFF])
        % 把4个uint8_t的数据合成一个float32的数据
        press = [
            typecast(fliplr(uint8([src.UserData.Data(6) src.UserData.Data(5) src.UserData.Data(4) src.UserData.Data(3)])), 'single');
            typecast(fliplr(uint8([src.UserData.Data(10) src.UserData.Data(9) src.UserData.Data(8) src.UserData.Data(7)])), 'single');
            typecast(fliplr(uint8([src.UserData.Data(14) src.UserData.Data(13) src.UserData.Data(12) src.UserData.Data(11)])), 'single');
            typecast(fliplr(uint8([src.UserData.Data(18) src.UserData.Data(17) src.UserData.Data(16) src.UserData.Data(15)])), 'single');]';
    end
end