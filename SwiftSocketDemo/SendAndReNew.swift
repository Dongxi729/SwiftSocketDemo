//
//  SendAndReNew.swift
//  SwiftSocketDemo
//
//  Created by 郑东喜 on 2017/5/3.
//  Copyright © 2017年 郑东喜. All rights reserved.
//  测试发送数据和解析数据

import UIKit

import SwiftSocket



class SendAndReNew: UIViewController {
    
    let host = "127.0.0.1"
    let port = 8888
    
    /// 连接方式
    var client: TCPClient!
    
    /// 包体长度
    var leng:Int = 0
    
    var allbyt:[Byte] = [Byte]()
    
    /// 余下的数据
    var resetData : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .default).async {
            self.testServer()
        }
    }
    
    /// 测试服务器
    func testServer() {
        
        client = TCPClient(address: host, port: Int32(port))
        
        switch client.connect(timeout: 1) {
            
        case .success:
            
            while true {
                
                if let msg = readmsg(clientSercer: client) {
                    DispatchQueue.main.async {
                        print("\((#file as NSString).lastPathComponent):(\(#line))\n",msg)
                        
                        if !msg.contains("用户") {
                            
                            
                        }
                    }
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
    
    //发送消息
    func sendMessage(msgtosend:String,clientServer : TCPClient?) {
        
        
        ///
        // let imgdata = msgtosend.data(using: .utf8)
        
        
        let img = UIImage.init(named: "wqwe")
        let imgdata = UIImagePNGRepresentation(img!)
        
        ///f发送语音
        
        
        if clientServer != nil {
            if let vvoiceData = imgdata {
                var int : Int = vvoiceData.count
                
                print("\((#file as NSString).lastPathComponent):(\(#line))\n","发送包的大小为:" + String(int))
                
                let data2 : NSMutableData = NSMutableData()
                
                data2.append(&int, length: 4)
                
                data2.append(vvoiceData)
                
                guard let socket = clientServer else {
                    return
                }
                
                
                print("aaaa",data2.length)
                
                if data2.length > 0 {
                    /// 偶尔发送异常失败  。。。。
                    switch socket.send(data: data2 as Data) {
                        
                    case .success:
                        print("\((#file as NSString).lastPathComponent):(\(#line))\n","发送成功")
                    case .failure( _):
                        
                        print("\((#file as NSString).lastPathComponent):(\(#line))\n","断开连接")
                    }
                } else {
                    print("\((#file as NSString).lastPathComponent):(\(#line))\n","语音信息为空")
                }
                
                
            } else {
                print("\((#file as NSString).lastPathComponent):(\(#line))\n","语音信息为空")
            }
        }
        
    }
    
    /// 读取信息
    func readmsg(clientSercer : TCPClient)->String? {
        //read 4 byte int as type
        
        /// 接收包头长度
        if leng == 0 {
            if let data = clientSercer.read(4) {
                
                /// 得到读取多少长度
                if data.count == 4 {
                    let ndata = NSData(bytes: data, length: data.count)
                    var len:Int32 = 0
                    
                    ndata.getBytes(&len, length: data.count)
                    
                    
                    allbyt = [Byte]()
                    leng = Int(len)
                    
                    /// 收到的字节长度
                    if leng > 0 {
                        /// 余下的数据
                        resetData = leng
                        
                    } else {
                        print("\((#file as NSString).lastPathComponent):(\(#line))\n","数据异常")
                        return nil
                    }
                    
                    
                    /// 字节不为4 的时候
                }
                
            }
        } else {
            
            if leng > 0 {
                /// 剩下的长度
                resetData = leng - resetData
            }
            
            
            print("\((#file as NSString).lastPathComponent):(\(#line))\n",resetData)
        }
        
        /// 问题每次都重新读取数据,相当于初始化  百搭
        if let buff = clientSercer.read(resetData) {
            
            if leng > 0 {
                resetData = leng - buff.count
            }
            
            
            print("\((#file as NSString).lastPathComponent):(\(#line))\n",buff.count)
            
            /// 接收到的
            allbyt = allbyt + buff
            
            
            print("\((#file as NSString).lastPathComponent):(\(#line))\n","存的读取数据长度:" + String(allbyt.count),"总长度:" + String(leng))
            
            
            if allbyt.count == leng {
                
                /// 绘图操作
                bytfun(_bytes: allbyt)
            }
            
            let backToString = "sdfsdf"
            
            return backToString
        }
        
        return nil
    }
    
    /// 绘图操作
    func bytfun(_bytes:[Byte])
    {
        allbyt.append(contentsOf: _bytes)
        
        if(allbyt.count >= leng){
            
        }
    }
}
