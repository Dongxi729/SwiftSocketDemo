//
//  SendMediaTool.swift
//  SwiftSocketDemo
//
//  Created by 郑东喜 on 2017/5/5.
//  Copyright © 2017年 郑东喜. All rights reserved.
//

import UIKit
import SwiftSocket

struct ConnectConfig {
    var host : String = ""
    var port : Int32 = 8888
}

let d = ConnectConfig.init(host: "127.0.0.1", port: 8888)

class SendMediaTool: NSObject {
    static let shared = SendMediaTool()
    
    //    let host = "127.0.0.1"
    //    let port = 8888
    
    /// 包体长度
    fileprivate var leng:Int = 0
    
    /// 连接方式
    fileprivate var client: TCPClient!
    
    /// 用作存储收到的字节流长度
    fileprivate var bodyBytesAny:[Byte] = [Byte]()
    
    
    /// 测试服务器
    func testServer() {
        
        //        client = TCPClient(address: host, port: Int32(port))
        
        client = TCPClient.init(address: d.host, port: d.port)
        
        switch client.connect(timeout: 1) {
            
        case .success:
            
            
            while true {
                
                if readmsg(clientSercer: client) != nil {
                    
                    
                } else {
                    print("\((#file as NSString).lastPathComponent):(\(#line))\n","连接失败")
                    /// 连接异常则关闭连接。
                    client.close()
                    
                    break
                }
            }
            
            
            
        case .failure( _):
            
            print("\((#file as NSString).lastPathComponent):(\(#line))\n","服务器状态不好或连接不上")
        }
        
    }
    
    /// 读取信息
    func readmsg(clientSercer : TCPClient)->String? {
        //read 4 byte int as type
        
        /// 缓存池数据
        let d = clientSercer.read(1024 * 10)
        
        
        
        /// 绩溪县
        if d != nil {
            byteAnalyse(ddd: d!)
            
            /// 进行解析
            ServerSendMsg.shared.receiverSeconds = String.init(bytes: d!, encoding: .utf8)
        }
        
        
        if d == nil {
            return "null"
        } else {
            return String.init(bytes: d!, encoding: .utf8)
        }
        
        
    }
    
    /// 数据解析
    func byteAnalyse(ddd : [Byte]) -> Void {
        /// 记录包头的值
        var headCountBytes : [Byte] = []
        
        /// 身体接收操作
        bodyBytesAny.append(contentsOf: ddd)
        
        
        if leng == 0 {
            
            /// 完整的包头长度为4
            if bodyBytesAny.count >= 4 {
                headCountBytes.append(bodyBytesAny[0])
                headCountBytes.append(bodyBytesAny[1])
                headCountBytes.append(bodyBytesAny[2])
                headCountBytes.append(bodyBytesAny[3])
                
                bodyBytesAny.remove(at: 0)
                bodyBytesAny.remove(at: 0)
                bodyBytesAny.remove(at: 0)
                bodyBytesAny.remove(at: 0)
                
                /// 读取包头指定四个字节的长度
                let convertData = NSData.init(bytes: &headCountBytes, length: 4)
                
                
                /// 获取包头长度
                convertData.getBytes(&leng, length: convertData.length)
                
                /// 增加1个长度
                leng = leng + 1
                
                print("leng :",leng)
                bodyfun()
            } else {
                return
            }
        }
            /// 解析操作
        else {
            bodyfun()
        }
    }
    
    
    
    func bodyfun() {
        //主体解析
        if(bodyBytesAny.count >= leng) {
            
            /// 记录字节流数据
            var bodyData = [Byte]()
            
            //可以解析
            for _ in 0..<leng {
                bodyData.append(bodyBytesAny[0])
                bodyBytesAny.remove(at: 0)
            }
            
            /// 复制一份数据出来拿出来操作(显示操作)
            bytesShwoFunc(_over: bodyData)
            
            
            
            /// 清空操作
            leng = 0
            
            
            /// 如果存储身体数组长度大于0
            if(bodyBytesAny.count > 0 ) {
                /// 调用本身
                byteAnalyse(ddd: [])
            }
        } else {
            //不能解析
            return
        }
    }
    
    
    /// 赋值显示操作
    func bytesShwoFunc(_over : [Byte]) -> Void {
        
        /// 通知传值
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receiveData"), object: nil, userInfo: ["send" : _over])
    }
    
    /// 发送语音
    func sendVoice() -> Void {
        if var voiceData = AvdioTool.shared.voiceData {
            
            /// 发送文字
            let datacc : NSMutableData = NSMutableData()
            
            var it1  = voiceData.count;
            
            /// 添加发送的文字
            datacc.append(&it1, length: 4)
            
            datacc.append(voiceData)
            
            /// 转语音
            var sendData : Data = datacc as Data
            
            /// 模拟类型为3
            sendData.insert(3, at: 4)
            
            guard let socket = client else {
                
                return
            }
            
            socket.send(data: sendData)
        }
    }
    
    /// 发送文字
    func sendTextFunc(sendText : String) -> Void {
        
        /// 发送文字
        let datacc : NSMutableData = NSMutableData()
        
        let stta = sendText
        let d1 = stta.data(using: String.Encoding.utf8)
        var it1  = d1?.count;
        
        /// 添加发送的文字
        datacc.append(&it1, length: 4)
        
        /// 添加发送的类型
        datacc.append(d1!)
        
        /// 转Data
        var sendData : Data = datacc as Data
        
        /// 模拟类型为1
        sendData.insert(1, at: 4)
        
        guard let socket = client else {
            return
        }
        
        
        socket.send(data: sendData)
        
    }
    
    
    
    /// 发送图片
    func sendImg(imageName : String) -> Void {
        /// 数据解析
        let img = UIImage.init(named: imageName)
        let imgdata = UIImagePNGRepresentation(img!)
        
        
        if let sendData = imgdata {
            var int : Int = sendData.count
            
            print("\((#file as NSString).lastPathComponent):(\(#line))\n","发送包的大小为:" + String(int))
            
            let data2 : NSMutableData = NSMutableData()
            
            
            /// 告诉发送的数据的长度
            data2.append(&int, length: 4)
            data2.append(sendData)
            
            var sendData : Data = data2 as Data
            
            
            /// 模拟类型为2
            sendData.insert(2, at: 4)
            
            
            guard let socket = client else {
                
                return
            }
            
            if data2.length > 0 {
                
                switch socket.send(data: sendData) {
                    
                    
                case .success:
                    print("\((#file as NSString).lastPathComponent):(\(#line))\n","发送成功")
                case .failure( _):
                    
                    print("\((#file as NSString).lastPathComponent):(\(#line))\n","断开连接")
                }
            } else {
                print("\((#file as NSString).lastPathComponent):(\(#line))\n","语音信息为空")
            }
        }
    }
}
