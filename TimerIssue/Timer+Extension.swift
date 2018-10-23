//
//  Timer+Extension.swift
//  TimerIssue
//
//  Created by season on 2018/10/17.
//  Copyright © 2018 season. All rights reserved.
//

import Foundation

extension Timer {
    static func scheduledTimer(timeInterval: TimeInterval, repeats: Bool, with callback: @escaping () -> ()) -> Timer {
        return scheduledTimer(timeInterval: timeInterval, target:
            self, selector: #selector(self.callbackInvoke(_:)), userInfo: callback, repeats: repeats)
    }
    
    @objc
    static func callbackInvoke(_ timer: Timer) {
        guard let callback = timer.userInfo as? () -> () else { return }
        callback()
    }
}
