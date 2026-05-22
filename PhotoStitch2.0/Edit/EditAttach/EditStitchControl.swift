//
//  EditStitchControl.swift
//  Photo Stitch
//
//  Created by Azuby on 6/24/25.
//

import UIKit
import SwiftUI
import Combine

private let DRAG_WIDTH: CGFloat = 24
private let DRAG_LONG: CGFloat = 32
private let DRAG_SHORT: CGFloat = 3

private let DIVIDER_WIDTH: CGFloat = 1.5
private let ICON_SIZE: CGSize = CGSize(width: 24, height: 24)
private let BUTTON_SIZE: CGSize = CGSize(width: 56, height: 56)
private let ARROW_SIZE: CGFloat = 32
private let ARROW_WIDTH: CGFloat = 3.5

enum EditStitchControlMode {
    case edgeDrag
    case contentDrag
}

class EditStitchControl: UIViewPointSubview {
    private(set) weak var editUpdater: EditUpdater?
    private(set) var context: EditGallery.Context?
    
    private var didLoad = false
    
    private var scrollViewUpdate: AnyCancellable?
    
    private let beforeView = UIView()
    private let afterView = UIView()

    func setup(editUpdater: EditUpdater, context: EditGallery.Context) {
        self.editUpdater = editUpdater
        self.context = context
        
        let isVer = editUpdater.axis == .vertical
        
        beforeView
            .elayerModifier({ layer in
                layer.cornerRadius = DRAG_WIDTH / 2
                layer.cornerCurve = .continuous
                layer.maskedCorners = [.layerMinXMinYCorner, (isVer ? .layerMaxXMinYCorner : .layerMinXMaxYCorner)]
            })
            .ebackgroundColor(._primary)
            .eaddSubview(UIView()
                .elayerModifier({ layer in
                    layer.cornerRadius = DRAG_SHORT / 2
                    layer.cornerCurve = .continuous
                })
                .ebackgroundColor(.white)
                .eselfConstraints([.width(isVer ? DRAG_LONG : DRAG_SHORT), .height(isVer ? DRAG_SHORT : DRAG_LONG)]),
             [.centerX(0), .centerY(0)])
        
        afterView
            .elayerModifier({ layer in
                layer.cornerRadius = DRAG_WIDTH / 2
                layer.cornerCurve = .continuous
                layer.maskedCorners = [(isVer ? .layerMinXMaxYCorner : .layerMaxXMinYCorner), .layerMaxXMaxYCorner]
            })
            .ebackgroundColor(._primary)
            .eaddSubview(UIView()
                .elayerModifier({ layer in
                    layer.cornerRadius = DRAG_SHORT / 2
                    layer.cornerCurve = .continuous
                })
                .ebackgroundColor(.white)
                .eselfConstraints([.width(isVer ? DRAG_LONG : DRAG_SHORT), .height(isVer ? DRAG_SHORT : DRAG_LONG)]),
            [.centerX(0), .centerY(0)])
        
        addSubview(beforeView)
        addSubview(afterView)
        
        scrollViewUpdate = editUpdater.editGallery.scrollViewUpdate.eraseToAnyPublisher().sink { [self] _ in
            contentUpdate(editUpdater: editUpdater, context: context)
        }
    }
    
    func update(editUpdater: EditUpdater, context: EditGallery.Context) {
        self.editUpdater = editUpdater
        self.context = context
        
        if !didLoad {
            didLoad = true
            contentUpdate(editUpdater: editUpdater, context: context)
        }
    }
    
    private func contentUpdate(editUpdater: EditUpdater, context: EditGallery.Context) {
        let isVer = editUpdater.axis == .vertical
        
        guard let stack = context.coordinator.stackView
        else { return }
        
        let rect = stack.convert(stack.bounds, to: self)
        print(rect)
        
        beforeView.frame.size = CGSize(width: isVer ? rect.width : DRAG_WIDTH, height: !isVer ? rect.height : DRAG_WIDTH)
        beforeView.frame.origin = CGPoint(x: !isVer ? rect.minX - DRAG_WIDTH : rect.minX, y: isVer ? rect.minY - DRAG_WIDTH : rect.minY)
        beforeView.layoutIfNeeded()
        
        afterView.frame.size = CGSize(width: isVer ? rect.width : DRAG_WIDTH, height: !isVer ? rect.height : DRAG_WIDTH)
        afterView.frame.origin = CGPoint(x: !isVer ? rect.maxX : rect.minX, y: isVer ? rect.maxY : rect.minY)
        afterView.layoutIfNeeded()
    }
}

class EditStitchViews {
    
}
