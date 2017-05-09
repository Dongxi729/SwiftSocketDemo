//
//  TImerTool.swift
//  NN
//
//  Created by 郑东喜 on 2017/5/6.
//  Copyright © 2017年 郑东喜. All rights reserved.
//

import UIKit
import SwiftSocket

/// 全局定时器
fileprivate var timer : Timer?

class TImerTool: NSObject {
    
    fileprivate var client: TCPClient!

    
    static let shared = TImerTool.init()
    
    func timerCount(seconds : Int) -> Void {
        timer = Timer.init(timeInterval: TimeInterval(seconds), target: self, selector: #selector(timerFunc), userInfo: nil, repeats: true)
        
        timer?.fire()
        
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }

    func timerFunc() -> Void {
        SendMediaTool.shared.sendHart()
    }
    
    func invalidTimer() -> Void {
        timer?.invalidate()
    }
    
    func timerIsValid() -> Bool {
        return (timer?.isValid)!
    }
    
}
