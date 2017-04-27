//
//  ViewController.swift
//  SwiftSocketDemo
//
//  Created by 郑东喜 on 2017/4/20.
//  Copyright © 2017年 郑东喜. All rights reserved.
//

import UIKit
import SwiftSocket
import AVFoundation

class ViewController: UIViewController {
    
    // 网络IP地址 --- 172.168.1.105
    let host = "192.168.3.4"
//    let host = "172.168.1.105"
    
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
        let d : UITextView = UITextView.init(frame: CGRect.init(x: 200, y: 0, width: UIScreen.main.bounds.width - 200, height: UIScreen.main.bounds.height * 0.5))
        d.isUserInteractionEnabled = false
        d.backgroundColor = UIColor.gray
        return d
    }()
    
    lazy var sendTfMsg: UITextField = {
        let d : UITextField = UITextField.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 30))
        d.placeholder = "输入发送的文本信息"
        return d
    }()
    
    var cellIcon : [String] = ["开始录音","停止","转换amr","播放"]
    
    
    lazy var getMsg: UITableView = {
        let d : UITableView = UITableView.init(frame: CGRect.init(x: 200, y: UIScreen.main.bounds.height * 0.5, width: UIScreen.main.bounds.width - 200, height: UIScreen.main.bounds.height * 0.5))
//        let d : UITableView = UITableView.init(frame:self.view.bounds)
        d.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        d.delegate = self;
        d.dataSource = self;
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
        
        view.addSubview(getMsg)
        
        AvdioTool.shared.creatSession()
        
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
        
        ///f发送语音
        
        print("\((#file as NSString).lastPathComponent):(\(#line))\n",AvdioTool.shared.voiceData!)
        
        var int : Int = (AvdioTool.shared.voiceData?.count)!
        
        let data2 : NSMutableData = NSMutableData()
        
        data2.append(&int, length: 4)
        
        data2.append(AvdioTool.shared.voiceData!)
        
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
            /// 剩下的长度
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
//            DispatchQueue.main.async {
//                let img = UIImageView(image: UIImage(data: data)!)
////                img.contentMode = .scaleAspectFit
//                self.view.addSubview(img)
//            }
            
            DispatchQueue.main.async {
//                let img = UIImageView(image: UIImage(data: data)!)
////                img.contentMode = .scaleAspectFit
//                self.view.addSubview(img)
                
                /// 保存的路径
                let savePath = AvdioTool.shared.amrconvertBackWav
                

                let dataAsNSData = data as NSData
                dataAsNSData.write(toFile: savePath!, atomically: true)

                /// 接收回的数据转成wav
//                VoiceConverter.convertAmr(toWav: String.init(data: data, encoding: .utf8), wavSavePath: AvdioTool.shared.amrconvertBackWav)
                
                print("\((#file as NSString).lastPathComponent):(\(#line))\n",AvdioTool.shared.amrconvertBackWav!)

                   AvdioTool.shared.playMp3()

                
                /// 计数器归零操作，反之上次存储的数据对下一次接收的数据进行干扰
                
                self.leng = 0
                
                self.resetData = 0
                
                self.allbyt = [Byte]()

                
                print("\((#file as NSString).lastPathComponent):(\(#line))\n",self.allbyt.count)
            }
        }
    }
}

extension ViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        cell?.textLabel?.text = cellIcon[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {

            /// 开始录音
        case 0:
            AvdioTool.shared.startRecord()
            
            break
            /// 停止录音
        case 1:
            AvdioTool.shared.stopRecord()
            
            break
            /// 转码
        case 2:
            AvdioTool.shared.convertWavToAmr()
            
            break
        case 3:
            AvdioTool.shared.playMp3()
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellIcon.count
    }
}
