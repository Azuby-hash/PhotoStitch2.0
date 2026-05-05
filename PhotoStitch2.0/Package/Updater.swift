//
//  Updater.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 4/25/26.
//

import SwiftUI
import UIKit

func dissolveAnimationExceptIOS26(_ body: @escaping () -> Void) {
    if IOS26 {
        withAnimation {
            body()
        }
    } else {
        guard let view = VIEW_CONTROLLER.view else {
            body()
            return
        }
        
        UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction]) {
            body()
        }
    }
}

func dissolveAnimation(_ body: @escaping () -> Void) {
    guard let view = VIEW_CONTROLLER.view else {
        body()
        return
    }
    
    UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve, .allowUserInteraction]) {
        body()
    }
}
