//
//  EditCut.swift
//  CutPhotos2.0
//
//  Created by TapUniverse Dev9 on 11/2/26.
//

import UIKit
import SwiftUI

private let DIVIDER_WIDTH: CGFloat = 1.5
private let DIVIDER_EXTENT: CGFloat = 16
private let DIVIDER_DRAG_RANGE: CGFloat = 16
private let BUTTON_SIZE: CGSize = CGSize(width: 44, height: 44)
private let BUTTON_SPACING: CGFloat = 32

class EditCutControl: TouchView {
    private(set) weak var editUpdater: EditUpdater?
    private(set) var context: EditGallery.Context?
    
    private let topArrowConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 16, weight: .semibold))
    
    private var splitBefore: EditSplitSlide?
    private var splitAfter: EditSplitSlide?
    private var splitDeletors = [EditSplitDeletorList]()
    
    private var cutNorRect = RECT0011
    private var beginNorRect = RECT0011
    private var onDragView: UIView?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        guard cEdit.getState() == .editing && cEdit.getTab() == .cut else {
//            return false
//        }
        
//        for view in [button] {
//            if view.convert(view.bounds, to: self).contains(point) {
//                return true
//            }
//        }
        
        return false
    }
}

extension EditCutControl: ForwardScrollProtocol {
    func passInteration(at point: CGPoint) -> Bool {
//        guard cEdit.getState() == .editing && cEdit.getTab() == .cut else {
//            return false
//        }
//        
//        for view in [firstDragger, afterDragger, areaView] {
//            if view.convert(view.bounds, to: self).contains(point) || getCurrentTouch()?.view == view {
//                return true
//            }
//        }
        
//        return false
        
        return true
    }

    func setup(editUpdater: EditUpdater, context: EditGallery.Context) {
        self.editUpdater = editUpdater
        self.context = context
        
        alpha = 0
        
//        setGestureMappings(zip([firstDragger, afterDragger, areaView], [dragAction, dragAction, dragAction]))
    }

    func update(editUpdater: EditUpdater, context: EditGallery.Context) {
        self.editUpdater = editUpdater
        self.context = context
        
        if alpha < 0.5 {
            
        }
    }
    
    private func dragAction(g: TouchGesture) {
        if onDragView != g.view && onDragView != nil { return }
        onDragView = g.view
        
        guard let stackView = context?.coordinator.stackView else { return }
        
        let minWidth = CGFloat(1)
        let stackFrame = stackView.convert(stackView.bounds, to: self)
        let isVer = editUpdater?.axis == .vertical
        
        let translate = g.translation(in: self) / stackFrame.size
        
        if g.state == .began {
            beginNorRect = cutNorRect
        }
        
        if onDragView == beforeDragger {
            var newMinX = beginNorRect.minX
            var newMinY = beginNorRect.minY
            
            if isVer {
                newMinY = min(beginNorRect.minY + translate.y, beginNorRect.maxY - minWidth / stackFrame.height)
            } else {
                newMinX = min(beginNorRect.minX + translate.x, beginNorRect.maxX - minWidth / stackFrame.width)
            }
            
            cutNorRect = CGRect(x: newMinX, y: newMinY, width: beginNorRect.maxX - newMinX, height: beginNorRect.maxY - newMinY).limit0011()
        }
        
        if onDragView == afterDragger {
            var newMaxX = beginNorRect.maxX
            var newMaxY = beginNorRect.maxY
            
            if isVer {
                newMaxY = max(beginNorRect.maxY + translate.y, beginNorRect.minY + minWidth / stackFrame.height)
            } else {
                newMaxX = max(beginNorRect.maxX + translate.x, beginNorRect.minX + minWidth / stackFrame.width)
            }
            
            cutNorRect = CGRect(x: beginNorRect.minX, y: beginNorRect.minY, width: newMaxX - beginNorRect.minX, height: newMaxY - beginNorRect.minY).limit0011()
        }

        if g.state == .ended || g.state == .cancelled {
            onDragView = nil
        }
    }
    
    @objc private func cutAction() {
        guard let editUpdater = editUpdater,
              let stackView = context?.coordinator.stackView,
              let scrollContent = context?.coordinator.scrollContent
        else { return }
        
        let isVer = editUpdater.axis == .vertical
        let cutFrame = cutNorRect.insetBy(dx: isVer ? -1 : 0, dy: isVer ? 0 : -1) * stackView.bounds.size
        
        var cutRects: [StitchItem: CGRect] = [:]
        
        for itemView in (stackView.arrangedSubviews as? [EditItem] ?? []) {
            guard let item = itemView.item else { continue }
            
            let fullItemFrame = itemView.imageView.convert(itemView.imageView.bounds, to: stackView)
            
            if cutFrame.intersects(itemView.frame) {
                cutRects[item] = (cutFrame.intersection(itemView.frame) - fullItemFrame.origin) / fullItemFrame.size
            }
        }
        
        let oldCuts = editUpdater.items.map({ ($0, $0.process.rect) })

//        cEdit.applyCut(cutRects) { [self] in
//            cEdit.setStitchConstraints([
//                scrollContent.widthAnchor.constraint(equalToConstant: scrollContent.bounds.width),
//                scrollContent.heightAnchor.constraint(equalToConstant: scrollContent.bounds.height),
//                stackView.topAnchor.constraint(equalTo: scrollContent.topAnchor),
//                stackView.leadingAnchor.constraint(equalTo: scrollContent.leadingAnchor),
//            ])
//            
//            content?.layoutIfNeeded()
//        } onAnim: { [self] in
//            if isVer {
//                cEdit.setStitchConstraints([ stackView.topAnchor.constraint(equalTo: scrollContent.topAnchor, constant: cutFrame.height / 2) ])
//            } else {
//                cEdit.setStitchConstraints([ stackView.leadingAnchor.constraint(equalTo: scrollContent.leadingAnchor, constant: cutFrame.width / 2) ])
//            }
//                                       
//            content?.layoutIfNeeded()
//        } afAnim: { [self] in
//            cEdit.setStitchConstraints([])
//            
//            content?.layoutIfNeeded()
//            
//            let newCuts = cEdit.getItems().map({ ($0, $0.getProcess().rect) })
//            
//            cEdit.applyCutStep(oldCuts: oldCuts, newCuts: newCuts)
//        }
    }
}

class EditSplitDeletorList {
    let deletors: [EditSplitDeletor]
    
    init(deletors: [EditSplitDeletor]) {
        self.deletors = deletors
    }
}

class EditSplitDeletor {
    let min: UIView
    let max: UIView
    let area: UIView
    let button: UIButtonPro
    
    init(min: UIView, max: UIView, area: UIView, button: UIButtonPro) {
        self.min = min
        self.max = max
        self.area = area
        self.button = button
    }
}

class EditSplitSlide {
    let divider: EditSplitDivider
    let button: UIButtonPro
    
    init(divider: EditSplitDivider, button: UIButtonPro) {
        self.divider = divider
        self.button = button
    }
}

class EditSplitDivider: UIView {
    override final class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override var layer: CAShapeLayer {
        return super.layer as! CAShapeLayer
    }
}
