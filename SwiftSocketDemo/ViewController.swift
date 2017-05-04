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
    //    let host = "192.168.3.4"
    //    let host = "172.168.1.105"
    
    /// 端口
    //    let port = 8411
    
    let host = "127.0.0.1"
    let port = 8888
    //
    
    /// 网络IP地址
    //    let host = "192.168.2.13"
    //
    //    /// 端口
    //    let port = 8411
    
    /// 发送信息按钮
    
    
    var index : Int = 0
    
    /// 包体长度
    var leng:Int = 0
    
    var allbyt:[Byte] = [Byte]()
    
    /// 余下的数据
    var resetData : Int = 0
    
    
    var imgview : UIImageView?
    
    
    var ssss : Int = 0
    
    
    
    /// 长按录音
    lazy var lpButton: UIButton = {
        let d : UIButton = UIButton.init(frame: CGRect.init(x: 100, y: 100, width: 100, height: 100))
        let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(longSEL(gesture:)))
        
        //        longTap.minimumPressDuration = 0.8
        d.addGestureRecognizer(longTap)
        d.backgroundColor = UIColor.gray
        return d
    }()
    
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
    
    /// 表格
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
        
        /// 录音表格
        view.addSubview(getMsg)
        
        /// 长按手势
        view.addSubview(lpButton)
        
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
    
    /// 用作存储收到的字节流长度
    var bodyBytesAny:[Byte] = [Byte]()
    
    
    /// 读取信息
    func readmsg(clientSercer : TCPClient)->String? {
        //read 4 byte int as type
        
        /// 缓存池数据
        let d = clientSercer.read(1024 * 10)
        
        //ssss = ssss + (d?.count)!
        
        //  print("----",ssss)
        
        /// 绩溪县
        if d != nil {
            byteAnalyse(ddd: d!)
        }
        
        return "test"
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
                
                leng = leng + 8
                
                print("leng :",leng)
                bodyfun()
            }
            else
            {
                return
            }
        }
            /// 解析操作
        else
        {
            bodyfun()
        }
    }
    
    
    
    func bodyfun()
    {
        //主体解析
        if(bodyBytesAny.count >= leng)
        {
            
            /// 记录字节流数据
            var bodyData = [Byte]()
            
            //可以解析
            for _ in 0..<leng
            {
                bodyData.append(bodyBytesAny[0])
                bodyBytesAny.remove(at: 0)
            }
            
            /// 复制一份数据出来拿出来操作(显示操作)
            
            bytesShwoFunc(_over: bodyData)
            
            
            
            /// 清空操作
            leng = 0
            
            
            /// 如果存储身体数组长度大于0
            if(bodyBytesAny.count > 0 )
            {
                /// 调用本身
                byteAnalyse(ddd: [])
            }
        }
        else
        {
            //不能解析
        }

    }
    
    
    
    
    
    /// 最后的操作函数
    func bytesShwoFunc(_over:[Byte])
    {
        //最后的数据
        
        allbyt = _over
        
        print(_over)
        
        /// 添加类型后总长度增加了8，要减去8
        for i in 0..<8 {
            
            allbyt.remove(at: 0)
            
            
            /// 剪完8次后为我们要得到的真正数据
            if i == 7 {
                
                print("水水水水",allbyt)
                
                DispatchQueue.main.async {
                    
                    let ddd = UIImageView.init(frame: CGRect.init(x: 0, y: self.index, width: 100, height: 100))
                    
                    ddd.backgroundColor = UIColor.blue
                    
                    let imfDara = NSData.init(bytes: self.allbyt, length: self.allbyt.count)
                    
                    ddd.image = UIImage.init(data: imfDara as Data)
                    
                    self.view.addSubview(ddd)
                    
                    self.index += 100
                    //            let imfDara = NSData.init(bytes: _over, length: _over.count)
                    //
                    //            let sss = String.init(data: imfDara as Data, encoding: .utf8)
                    //            
                    //            print("字符串",sss as Any)
                }
            }
        }
        
        
        
    }
    
    var sendStr : String?
    
    var sendDataStr : Data?
    
}

extension ViewController {
    
    func sendMsg(sender : UIButton) -> Void {
        /// initData
        leng = 0
        self.sendMessage(msgtosend:sendTfMsg.text!, clientServer: client)
        
    }
    
    //发送消息
    func sendMessage(msgtosend:String,clientServer : TCPClient?) {
        
        
        ///
        // let imgdata = msgtosend.data(using: .utf8)
        
//        print("\((#file as NSString).lastPathComponent):(\(#line))\n")
//        
//        /// 数据解析
        let img = UIImage.init(named: "cccc")
        let imgdata = UIImagePNGRepresentation(img!)
        
        
//
//        
//        
//        sendStr = "aaa,bbb,cccaaa,bbb"
//        
//        
//        
//        sendDataStr = sendStr?.data(using: String.Encoding.utf8)
//        
//        let datacc : NSMutableData = NSMutableData()
//        
//        let stta = "1asdfjlksdfjkhsfjk232782ywriusdfgjbsdf"
//        let d1 = stta.data(using: String.Encoding.utf8)
//        var it1  = d1?.count;
//        
//        /// 类型
//        var myInt = 2
//        var myIntData = Data(bytes: &myInt,
//                             count: MemoryLayout.size(ofValue: myInt))
////        datacc.append(&myIntData, length: 1)
//        datacc.append(&it1, length: 4)
//        datacc.append(d1!)
//        
//        
//        
//        let stta1 = "bsdfkljsdfk238792uyfkhdfkjsdnf"
//        let d2 = stta1.data(using: String.Encoding.utf8)
//        var it2  = d2?.count;
//        
//        ///// 6  99
//        
//        datacc.append(&it2, length: 4)
//        
//        datacc.append(d2!)
//
//        
//        let stta2 = "cslkdfhjksdhfjk238ydhfjksdnbfmsdbmsdnf,smdfjsdkjghiuy342iuhfjkwebfjkwehfuiw2y32893uyhrkjwfjksdkjf"
//        let d3 = stta2.data(using: String.Encoding.utf8)
//        var it3  = d3?.count;
//        datacc.append(&it3, length: 4)
//        datacc.append(d3!)
//        
//        
//        guard let socket = clientServer else {
//            return
//        }
//        
//        socket.send(data: datacc as Data)

        
        
        
        if clientServer != nil {
            
            if let sendData = imgdata {
                var int : Int = sendData.count
                
                print("\((#file as NSString).lastPathComponent):(\(#line))\n","发送包的大小为:" + String(int))
                
                let data2 : NSMutableData = NSMutableData()
                
                
                /// 类型
                var myInt = 8
                var myIntData = Data(bytes: &myInt,
                                     count: MemoryLayout.size(ofValue: myInt))
                /// 告诉发送的数据的长度
                data2.append(&int, length: 4)
                
                /// 告诉发送的类型的长度
                data2.append(&myIntData.count,length :0)
                
                print("\((#file as NSString).lastPathComponent):(\(#line))\n",myIntData.count)
                
                data2.append(myIntData)
                
                data2.append(sendData)
                
                
                
                guard let socket = clientServer else {
                    return
                }
                
                if data2.length > 0 {
                    
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
    
}


// MARK: - 长按手势
extension ViewController {
    func longSEL(gesture : UILongPressGestureRecognizer) -> Void {
        print("\((#file as NSString).lastPathComponent):(\(#line))\n")
        
        if gesture.state == .began {
            print("\((#file as NSString).lastPathComponent):(\(#line))\n","长按事件")
            
            AvdioTool.shared.startRecord()
        } else {
            
            AvdioTool.shared.stopRecord()
            
            AvdioTool.shared.convertWavToAmr()
            
            
            print("\((#file as NSString).lastPathComponent):(\(#line))\n","结束")
            
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
