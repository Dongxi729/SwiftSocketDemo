//
//  ViewController.swift
//  SwiftSocketDemo
//
//  Created by 郑东喜 on 2017/4/20.
//  Copyright © 2017年 郑东喜. All rights reserved.
//

import UIKit
import SwiftSocket

class ViewController: UIViewController {
    
    // 网络IP地址
    let host = "192.168.3.4"
    
    /// 端口
    let port = 8411
    
    //    let host = "172.30.33.60"
    //    let port = 8888
    //
    
    /// 网络IP地址
    //    let host = "192.168.2.13"
    //
    //    /// 端口
    //    let port = 8411
    
    /// 发送信息按钮
    
    
    /// 包体长度
    var leng:Int = 0
    
    
    
    var allbyt:[Byte] = [Byte]()
    
    /// 接收到的包长度
    var didReceived : Int = 0
    
    /// 余下的数据
    var resetData : Int = 0
    
    var readData = 4
    
    lazy var msgSend: UIButton = {
        let d : UIButton = UIButton.init(frame: CGRect.init(x: 50, y: 200, width: 100, height: 100))
        
        d.backgroundColor = UIColor.gray
        d.addTarget(self, action: #selector(sendMsg(sender:)), for: .touchUpInside)
        
        d.setTitle("发送消息", for: .normal)
        return d
    }()
    
    lazy var showGetMsgView: UITextView = {
        let d : UITextView = UITextView.init(frame: CGRect.init(x: 200, y: 0, width: UIScreen.main.bounds.width - 200, height: UIScreen.main.bounds.height))
        d.isUserInteractionEnabled = false
        return d
    }()
    
    lazy var sendTfMsg: UITextField = {
        let d : UITextField = UITextField.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 30))
        d.placeholder = "输入发送的文本信息"
        return d
    }()
    
    
    /// 连接按钮
    lazy var connetBtn: UIButton = {
        let d : UIButton = UIButton.init(frame: CGRect.init(x: 0, y: 300, width: 100, height: 50))
        d.setTitle("重连/连接", for: .normal)
        d.addTarget(self, action: #selector(connectSEL), for: .touchUpInside)
        d.backgroundColor = .gray
        return d
    }()
    
    
    /// 断开连接
    lazy var disConnectBtn: UIButton = {
        let d : UIButton = UIButton.init(frame: CGRect.init(x: 0, y: 400, width: 100, height: 50))
        d.backgroundColor = UIColor.gray
        d.setTitle("断开连接", for: .normal)
        d.addTarget(self, action: #selector(disconnectSEL), for: .touchUpInside)
        return d
    }()
    
    /// 连接方式
    var client: TCPClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(msgSend)
        
        view.addSubview(sendTfMsg)
        
        view.addSubview(connetBtn)
        
        view.addSubview(disConnectBtn)
        
        view.addSubview(showGetMsgView)
        
        //        view.addSubview(chatTb)
        
        DispatchQueue.global(qos: .default).async {
            self.testServer()
        }
    }
    
    
    /// 断开连接事件
    func disconnectSEL() -> Void {
        
        client.close()
    }
    
    /// 连接是服务器
    func connectSEL() -> Void {
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
                            
                            self.showGetMsgView.text = msg
                        }
                    }
                } else {
                    print("\((#file as NSString).lastPathComponent):(\(#line))\n","连接失败")
                    /// 连接异常则关闭连接。
                    client.close()
                    
                    break
                }
            }
            
        case .failure(let _):
            
            print("\((#file as NSString).lastPathComponent):(\(#line))\n","服务器状态不好或连接不上")
        }
    }
}

extension ViewController {
    
    func sendMsg(sender : UIButton) -> Void {
        
        self.sendMessage(msgtosend:sendTfMsg.text!, clientServer: client)
    }
    
    //发送消息
    func sendMessage(msgtosend:String,clientServer : TCPClient?) {
        
        
        ///
        // let imgdata = msgtosend.data(using: .utf8)
        
        
        let img = UIImage.init(named: "wqwe")
        let imgdata = UIImagePNGRepresentation(img!)
        
        
        
        var int : Int = (imgdata?.count)!
        
        let data2 : NSMutableData = NSMutableData()
        
        data2.append(&int, length: 4)
        
        data2.append(imgdata!)
        
        guard let socket = clientServer else {
            return
        }
        print("aaaa",data2.length)
        switch socket.send(data: data2 as Data) {
        case .success:
            print("\((#file as NSString).lastPathComponent):(\(#line))\n","发送成功")
        case .failure( _):
            
            print("\((#file as NSString).lastPathComponent):(\(#line))\n","断开连接")
        }
    }
    
    /// 读取信息
    func readmsg(clientSercer : TCPClient)->String?{
        //read 4 byte int as type
        
        print("\((#file as NSString).lastPathComponent):(\(#line))\n")
        
        /// 接收包头长度
        if leng == 0 {
            if let data = clientSercer.read(4) {
                
                /// 得到读取多少长度
                if data.count == 4 {
                    let ndata = NSData(bytes: data, length: data.count)
                    var len:Int32 = 0
                    
                    ndata.getBytes(&len, length: data.count)
                    
                    /// 总长度
                    allbyt = [Byte]()
                    leng = Int(len)
                    
                    /// 余下的数据
                    resetData = leng
                    
                    print("\((#file as NSString).lastPathComponent):(\(#line))\n",leng)
                }
            }
        } else {
            resetData = leng - resetData
        }
        
        /// 问题每次都重新读取数据,相当于初始化  百搭
        if let buff = clientSercer.read(resetData) {
            
            resetData = leng - buff.count
            
            /// 接收到的
            didReceived = buff.count
            
            allbyt = allbyt + buff

            print("\((#file as NSString).lastPathComponent):(\(#line))\n",allbyt.count)

            if allbyt.count == leng {
                print("\((#file as NSString).lastPathComponent):(\(#line))\n")
                
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
            let msgd = Data(bytes: allbyt, count: leng)
            addimg(data: msgd)
        }
    }
    
    
    func addimg(data:Data)
    {
        if(data.count>50)
        {
            DispatchQueue.main.async {
                let img = UIImageView(image: UIImage(data: data)!)
//                img.contentMode = .scaleAspectFit
                self.view.addSubview(img)
            }
            
        }
        
    }
}
