//
//  NextController.swift
//  TimerIssue
//
//  Created by season on 2018/10/17.
//  Copyright © 2018 season. All rights reserved.
//

import UIKit

class NextController: UIViewController {
    
    private var timer: Timer?
    
    private var tag: Int = 0
    
    private var isInitTimer = false
    
    private var isNormalTimerFunction = false
    
    private var isInitGCDTimer = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NextController"
        view.backgroundColor = UIColor.white

        let margin: CGFloat = 10
        let buttonTitles = ["一般Timer方法", "iOS 10 Timer方法", "Timer 分类方法", "CGD Timer方法", "Proxy Timer方法"]
        let buttonCount = CGFloat(buttonTitles.count)
        let buttonWidth = (view.bounds.width - (buttonCount + 1) * margin) / buttonCount
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(frame: CGRect(x: CGFloat(index + 1) * margin + CGFloat(index) * buttonWidth, y: view.center.y - 100, width: buttonWidth, height: 30))
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 8)
            button.setTitleColor(UIColor.white, for: .normal)
            button.tag = index + 1000
            button.backgroundColor = UIColor.lightGray
            button.addTarget(self, action: #selector(timerStart(_:)), for: .touchUpInside)
            view.addSubview(button)
        }
    }
    
    
    
    @objc
    func timerStart(_ button: UIButton) {
        tag = button.tag
        switch button.tag {
        case 1000:
            normalTimerFunction()
        case 1001:
            iOS10LaterTimerFunction()
        case 1002:
            timerExtensionFunction()
        case 1003:
            GCDTimerFunction()
        case 1004:
            proxyFunction()
        default:
            break
        }
    }
    
    /// 一般Timer方法
    private func normalTimerFunction() {
        /*
         1.这样创建 timer 会导致内存泄露
         2.这个不是循环引用 控制器没有持有 timer
         解释：timer 被 rouLoop 持有，所以不会释放 runLoop 持有 timer ，timer 持有 控制器（self） 导致无法释放
         循环引用会导致内存泄漏，强应用也会导致内存泄漏，timer 就是强引用导致的内存泄漏
         类方法和构造器方法都会导致循环引用
         timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerWork), userInfo: nil, repeats: true)
         */
        
        timer = Timer(timeInterval: 2, target: self, selector: #selector(timerWork), userInfo: nil, repeats: true)
        guard let timer = timer else { return }
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        isInitTimer = true
        isNormalTimerFunction = true
    }
    
    /// iOS 10 Timer方法
    private func iOS10LaterTimerFunction() {
        if #available(iOS 10.0, *) {
            //  这个方法可以避免Timer的循环引用,但是需要iOS 10 以上的系统 当然再过几个版本 这个问题就不存在了
            let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] (timer) in
                self?.timerWork()
            })
            self.timer = timer
        }else {
            normalTimerFunction()
        }
        isInitTimer = true
    }
    
    /// Timer 分类方法
    private func timerExtensionFunction() {
        timer = Timer.scheduledTimer(timeInterval: 2, repeats: true, with: { [weak self] in
            self?.timerWork()
        })
        isInitTimer = true
    }

    /// CGD Timer方法
    private func GCDTimerFunction() {
        GCDTimer.shared.scheduledDispatchTimer(withTimerName: "NextController", timeInterval: 2, queue: .main, repeats: true) { [weak self] in
            self?.timerWork()
        }
        isInitGCDTimer = true
    }
    
    /// Proxy Timer方法
    private func proxyFunction() {
        //timer = Timer(timeInterval: 2, target: TargetProxy(target: self), selector: #selector(TargetProxy.targetFunction), userInfo: nil, repeats: true)
        timer = Timer(timeInterval: 2, target: WeakProxy(target: self), selector: #selector(WeakProxy.targetFunction), userInfo: nil, repeats: true)
        guard let timer = timer else { return }
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        isInitTimer = true
    }
    
    /// 定时器的工作方法
    @objc
    private func timerWork() {
        let message: String
        switch tag {
        case 1000:
            message = "一般Timer方法"
        case 1001:
            message = "iOS 10 Timer方法"
        case 1002:
            message = "Timer 分类方法"
        case 1003:
            message = "CGD Timer方法"
        case 1004:
            message = "Proxy Timer方法"
        default:
            message = ""
        }
        print("定时器正在工作!!! \(message)")
    }
    
    /// 移除定时器
    @objc
    private func removeTimer() {
        
        if isInitGCDTimer {
            GCDTimer.shared.cancleTimer(WithTimerName: "NextController")
        }
        
        if isInitTimer {
            timer?.invalidate()
            timer = nil
        }
    }
    
    /// 析构函数
    deinit {
        print("NextController deinit")
        removeTimer()
    }
}

// MARK: - 针对一般Timer方法解决定时器的方法
extension NextController {
    override func viewWillDisappear(_ animated: Bool) {
        if isNormalTimerFunction && isInitTimer {
            removeTimer()
        }
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil && isNormalTimerFunction && isInitTimer {
            removeTimer()
        }
    }
}


// MARK: - Proxy Timer方法需要写的一个交换类 这只是一个特例类 后面我写了一个基于泛型的WeakProxy
extension NextController {
    class TargetProxy {
        private weak var target: NextController?
        
        init(target: NextController) {
            self.target = target
        }
        
        @objc func targetFunction() {
            target?.timerWork()
        }
    }
}

// MARK: - 重写了NSObject基类遵守WeakProxyProtocol协议的sourceFunction方法
extension NextController {
    override func sourceFunction() {
        timerWork()
    }
}
