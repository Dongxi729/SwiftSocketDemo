//
//  CountDownBtn.swift
//  DollBuy
//
//  Created by 郑东喜 on 2016/11/27.
//  Copyright © 2016年 郑东喜. All rights reserved.
//  倒计时按钮

import UIKit
//发送几秒
var  NUMSS : Int = 30

class CountDownBtn: UIButton {
    
    
    
    //触发倒计时事件
    var countYES = ""
    
    //秒数
    var i = 0
    
    //定时器
    var timer:Timer?
    
    //当前按钮背景颜色
    var  currentColor:UIColor?
    
    
    /// 是否继续
    var canContinue = false
    
    
//    static let shared = CountDownBtn()
    
    
    /// 调用倒计时
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - title: 标题
    ///   - superView: 添加到的视图
    ///   - descc: 描述
    func initwith(color : UIColor,title:String,superView:UIView,descc : Int) ->
        Void {
            
            canContinue = true
            
            i = descc
            
            self.setTitle(title, for: UIControlState.normal)
            
            self.setTitle("重发(\(descc))s", for: UIControlState.disabled)
            self.titleLabel?.adjustsFontSizeToFitWidth = true
            self.backgroundColor=UIColor.lightGray
            self.isEnabled=false
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tiemrBengin), userInfo: self, repeats: true)
            
            superView.addSubview(self)
            
            self.isUserInteractionEnabled = true
            self.currentColor = color
    }
    
    
    
    func  tiemrBengin() {
        
        if canContinue == false {
            
            timer?.invalidate()
            self.isEnabled = true
            self.backgroundColor = self.currentColor
            return
            
        }
        
        
        if self.i != 0 && self.i > 0 && self.canContinue == true {
            self.i -= 1
            
            
            self.setTitle(String(format: "重发(%d)s",self.i), for: UIControlState.disabled)
            self.backgroundColor=UIColor.lightGray
            
            print("i = :",self.i)
            
        }
        
        
        
        if i == 0 || canContinue == false {
            
            canContinue = false
            
            self.timer?.invalidate()
            self.isEnabled = true
            self.backgroundColor = self.currentColor
            i = NUMSS
            
        }
    }
    
    func isvalidate() -> Bool {
        print(NUMSS)
        
        if NUMSS > 0 {
            return true
        } else {
            return false
        }
    }
    
    func terminate() -> Void {
        self.timer?.invalidate()
        self.isEnabled = true
        self.backgroundColor = self.currentColor
    }
}
