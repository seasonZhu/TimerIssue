//
//  GCDTimer.swift
//  TimerIssue
//
//  Created by season on 2018/10/17.
//  Copyright © 2018 season. All rights reserved.
//

import Foundation

class GCDTimer {
    
    //  单例
    static let shared = GCDTimer()
    private init() {}
    
    //  容器
    lazy var timerContainer = [String: DispatchSourceTimer]()
    
    /// GCD定时器
    ///
    /// - Parameters:
    ///   - name: 定时器名字
    ///   - timeInterval: 时间间隔
    ///   - queue: 队列
    ///   - repeats: 是否重复
    ///   - action: 执行任务的闭包
    func scheduledDispatchTimer(withTimerName name: String?, timeInterval: Double, queue: DispatchQueue = .main, repeats: Bool, action: @escaping () -> ()) {
        
        guard let unwrapName = name else {
            return
        }
        
        var timer = timerContainer[unwrapName]
        if timer == nil {
            timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
            timer?.resume()
            timerContainer[unwrapName] = timer
        }
        //精度0.1秒
        timer?.schedule(deadline: .now(), repeating: timeInterval, leeway: DispatchTimeInterval.milliseconds(100))
        timer?.setEventHandler(handler: { [weak self] in
            action()
            if repeats == false {
                self?.cancleTimer(WithTimerName: unwrapName)
            }
        })
    }
    
    /// 取消定时器
    ///
    /// - Parameter name: 定时器名字
    func cancleTimer(WithTimerName name: String?) {
        
        guard let unwrapName = name else {
            return
        }
        
        guard let timer = timerContainer[unwrapName] else {
            return
        }
        
        timerContainer.removeValue(forKey: unwrapName)
        timer.cancel()
    }
    
    
    /// 检查定时器是否已存在
    ///
    /// - Parameter name: 定时器名字
    /// - Returns: 是否已经存在定时器
    func isExistTimer(withTimerName name: String?) -> Bool {
        
        guard let unwrapName = name else {
            return false
        }
        
        guard let _ = timerContainer[unwrapName] else {
            return false
        }
        
        return true
    }
    
}
