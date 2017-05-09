//
//  ServerSendMsg.swift
//  SwiftSocketDemo
//
//  Created by 郑东喜 on 2017/5/8.
//  Copyright © 2017年 郑东喜. All rights reserved.
//

import UIKit

class ServerSendMsg: NSObject {
    /// 发送的时间长度
    var receiverSeconds : String? {
        didSet {
            print("asdsads")
            
            if receiverSeconds != nil {
                analyse(analyseXmlStr: receiverSeconds!)
            }
        }
    }
    
    
    /// 倒计时
    var coutSec : Int = 0
    
    static let shared = ServerSendMsg()
    
    
    
    /// 解析服务器数据
    func analyse(analyseXmlStr : String) -> Void {
        let xmlData = analyseXmlStr.data(using: String.Encoding.utf8)
        
        print("\((#file as NSString).lastPathComponent):(\(#line))\n",xmlData as Any)
        /// 收到的转string,进行解析
        let xmlStr = String.init(data: xmlData!, encoding: .utf8)
        
        print(xmlStr as Any)
        
        //构造XML文档
        
        
        do {
            let doc =  try DDXMLDocument(data: xmlData!, options:0)
            let users = try! doc.nodes(forXPath: "//R") as! [DDXMLElement]
            
            for user in users {
                
                /// 倒数计时
                let countDownSec = user.attribute(forName: "f")?.stringValue
                
                self.coutSec = Int(countDownSec!)!
                
                //            ViewController.shared.timerSec = Int(countDownSec!)!
                
                xxxx.shared.vv = Int(countDownSec!)!
            }
        } catch {
            print("xml数据异常")
        }

    }
}


class xxxx: NSObject {
    var vv : Int = 0
    
    static let shared = xxxx()
}
