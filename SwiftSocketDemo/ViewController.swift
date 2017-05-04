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
                        
//                        if !msg.contains("用户") {
//                            
//                            self.showGetMsgView.text = msg
//                        }
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
    
    
    var bodyarr:[Byte] = [Byte]()
    
    
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
        
        print("\((#file as NSString).lastPathComponent):(\(#line))\n")
        
        
        let img = UIImage.init(named: "cccc")
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

        /// 缓存池数据
        let d = clientSercer.read(1024 * 10)
        
        //ssss = ssss + (d?.count)!
        
      //  print("----",ssss)

        /// 绩溪县
        if d != nil {
            testAnyalse(ddd: d!)
        }
        
        

        
        return "test"
    }
    
    
   
    
    func testAnyalse(ddd : [Byte]) -> Void {
        var arrdt : [Byte] = []
        bodyarr.append(contentsOf: ddd)
        
        if leng == 0 {
            
            ///
            if bodyarr.count >= 4 {
                arrdt.append(ddd[0])
                arrdt.append(ddd[1])
                arrdt.append(ddd[2])
                arrdt.append(ddd[3])
                
                bodyarr.remove(at: 0)
                bodyarr.remove(at: 0)
                bodyarr.remove(at: 0)
                bodyarr.remove(at: 0)
                let convertData = NSData.init(bytes: &arrdt, length: 4)
                convertData.getBytes(&leng, length: convertData.length)
                print("leng :",leng)
            }
            else
            {
                return
            }
        }
        else
        {
            //主体解析
            if(bodyarr.count >= leng)
            {
                
                var bodyarr2 = [Byte]()
                //可以解析
                for _ in 0..<leng
                {
                    bodyarr2.append(bodyarr[0])
                    bodyarr.remove(at: 0)
                }
                datafun(_over: bodyarr2)
                leng = 0
                
                if(bodyarr.count > 0 )
                {
                    testAnyalse(ddd: [])
                }
            }
            else
            {
                //不能解析
            }
        }
    }
    
    
    func datafun(_over:[Byte])
    {
        //最后的数据
        
        print("水水水水",_over.count)
        
        
        
        DispatchQueue.main.async {
            
            let ddd = UIImageView.init(frame: CGRect.init(x: 0, y: self.index, width: 100, height: 100))
            
            ddd.backgroundColor = UIColor.blue
            
            let imfDara = NSData.init(bytes: _over, length: _over.count)
            
            ddd.image = UIImage.init(data: imfDara as Data)
            
            self.view.addSubview(ddd)
            
            self.index += 100
        }
        
       
        
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
                
                /// 添加图片
                self.imgview = UIImageView(image: UIImage(data: data)!)
                //                img.contentMode = .scaleAspectFit
                self.view.addSubview(self.imgview!)
                
                
                
                
                /// 保存的路径
                //                let savePath = AvdioTool.shared.amrconvertBackWav
                //
                //
                //                let dataAsNSData = data as NSData
                //                dataAsNSData.write(toFile: savePath!, atomically: true)
                
                /// 接收回的数据转成wav
                
                //                AvdioTool.shared.playMp3()
                
                /// 计数器归零操作，反之上次存储的数据对下一次接收的数据进行干扰
                self.leng = 0
                
                self.resetData = 0
                
                //                self.allbyt = [Byte]()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.imgview?.removeFromSuperview()
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
