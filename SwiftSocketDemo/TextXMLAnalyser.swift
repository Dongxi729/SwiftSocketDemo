//
//  TextXMLAnalyser.swift
//  hangge_646_2
//
//  Created by 郑东喜 on 2017/5/8.
//  Copyright © 2017年 hangge. All rights reserved.
//

import UIKit

class TextXMLAnalyser: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        testXML()
    }
    
    
    fileprivate func testXML() {
        //获取xml文件路径
        let file = Bundle.main.path(forResource: "test", ofType: "xml")
        let url = URL(fileURLWithPath: file!)
        //获取xml文件内容
        let xmlData = try! Data(contentsOf: url)
        
        //构造XML文档
        let doc = try! DDXMLDocument(data: xmlData, options:0)

        
        let users = try! doc.nodes(forXPath: "//R") as! [DDXMLElement]
        
        print("\((#file as NSString).lastPathComponent):(\(#line))\n",users.count)
        
        for user in users {
            
            /// 输赢
            let resultStr = user.attribute(forName: "f")?.stringValue
            
            print(resultStr as Any)
            
        }
        

    }
}
