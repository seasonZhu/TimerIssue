//
//  WeakProxy.swift
//  TimerIssue
//
//  Created by season on 2018/10/23.
//  Copyright © 2018 season. All rights reserved.
//

import Foundation

/// 弱代理协议
protocol WeakProxyProtocol {
    func sourceFunction()
}

// MARK: - 弱代理协议的默认实现
extension WeakProxyProtocol {
    func sourceFunction() {
        print("ProxyProtocol Extension sourceFunction")
    }
}

// MARK: - NSObject 遵守弱代理协议 实现方法
extension NSObject: WeakProxyProtocol {
    
    /// 记得具体类要实现具体方法的时候 重新这个方法
    @objc
    func sourceFunction() {
        print("NSObject Extension sourceFunction")
    }
}

/// 弱代理类 可以把T: NSObject 改为 T: WeakProxyProtocol, protocol WeakProxyProtocol: class 这样的写法试试
final class WeakProxy<T: NSObject> {
    private weak var target: T?
    
    init(target: T) {
        self.target = target
    }
    
    @objc
    func targetFunction() {
        target?.sourceFunction()
    }
}
