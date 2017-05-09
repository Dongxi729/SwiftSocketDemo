//
//  AppDelegate.swift
//  SwiftSocketDemo
//
//  Created by 郑东喜 on 2017/4/20.
//  Copyright © 2017年 郑东喜. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let nav = UINavigationController.init(rootViewController: ViewController())
        
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = nav
        
        window?.backgroundColor = UIColor.white
        
        createSocket()
        
        createHeart()
        
        return true
    }
    
    /// 心跳包
    func createHeart() -> Void {
        TImerTool.shared.timerCount(seconds: 5)
    }
    
    
    /// 创建通信
    func createSocket() -> Void {
        
        
        AvdioTool.shared.creatSession()
        
        /// 开启链接服务器
        DispatchQueue.global(qos: .default).async {
            
            SendMediaTool.shared.testServer()
        }
    }
}

