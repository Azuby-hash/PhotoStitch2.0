//
//  Helpers.swift
//  BlurVideo2.0
//
//  Created by TapUniverse Dev9 on 19/9/24.
//

import UIKit

/**
 Run this on main for work well
 */
func waitForBool(interval: CGFloat = 0.02, timeOut: CGFloat = 5, bool: @escaping (()->Bool), completion: @escaping (()->Void)) {
    let date = Date()
    Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
        if !bool() && -date.timeIntervalSinceNow < 5 {
            return
        }
        
        timer.invalidate()
        completion()
    }
}
