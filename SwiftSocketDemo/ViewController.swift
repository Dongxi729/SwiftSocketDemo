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
    
    /// 网络IP地址
    let host = "192.168.1.10"
    
    /// 端口
    let port = 2048
    
    /// 连接方式
    var client: TCPClient?
    
    
    /// 连接按钮
    lazy var connectBtn: UIButton = {
        let d : UIButton = UIButton.init(frame: CGRect.init(x: 50, y: 50, width: 100, height: 100))
        d.addTarget(self, action: #selector(connectSEl(sender:)), for: .touchUpInside)
        d.backgroundColor = UIColor.gray
        d.setTitle("启动链接", for: .normal)
        
        return d
    }()
    
    
    /// 发送信息按钮
    lazy var msgSend: UIButton = {
        let d : UIButton = UIButton.init(frame: CGRect.init(x: 50, y: 200, width: 100, height: 100))
        
        d.backgroundColor = UIColor.gray
        d.addTarget(self, action: #selector(sendMsg(sender:)), for: .touchUpInside)
        
        d.setTitle("发送消息", for: .normal)
        return d
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        view.addSubview(connectBtn)
        view.addSubview(msgSend)
    }
    
    /// 测试服务器
    func testServer() {
        let client = TCPClient(address: host, port: Int32(port))
        switch client.connect(timeout: 1) {
        case .success:
            switch client.send(string: "GET / HTTP/1.0\n\n" ) {
            case .success:
                guard let data = client.read(1024*10) else { return }
                
                while true {
                    if let msg = readmsg(clientSercer: client) {
                        DispatchQueue.main.async {
                            print("\((#file as NSString).lastPathComponent):(\(#line))\n",msg)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.client?.close()
                        }
                        break
                    }
                }
                
            case .failure(let error):
                print("\((#file as NSString).lastPathComponent):(\(#line))\n",error.localizedDescription)
            }
        case .failure(let error):

            print("\((#file as NSString).lastPathComponent):(\(#line))\n",error)
        }
    }
    
    
    /// 读取信息
    func readmsg(clientSercer : TCPClient)->String?{
        //read 4 byte int as type
        if let data = clientSercer.read(4) {
            if data.count == 4 {
                let ndata = NSData(bytes: data, length: data.count)
                var len:Int32 = 0
                ndata.getBytes(&len, length: data.count)
                
                if let buff = clientSercer.read(Int(len)){
                    let msgd = Data(bytes: buff, count: buff.count)
                    
                    print("\((#file as NSString).lastPathComponent):(\(#line))\n",msgd.description)
                    
                    
                    
                    let backToString = String(data: msgd, encoding: String.Encoding.utf8) as String!
                    
                    return backToString
                }
            }
        }
        return nil
    }
}

extension ViewController {
    
    /// 连接事件
    ///
    /// - Parameter sender: <#sender description#>
    func connectSEl(sender : UIButton) -> Void {
        
        DispatchQueue.global().async {
            self.testServer()
        }
    }
    
    func sendMsg(sender : UIButton) -> Void {
        print("\((#file as NSString).lastPathComponent):(\(#line))\n")
    }
}
