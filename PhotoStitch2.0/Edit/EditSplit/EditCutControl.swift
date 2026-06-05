//
//  EditCut.swift
//  CutPhotos2.0
//
//  Created by TapUniverse Dev9 on 11/2/26.
//

import UIKit
import SwiftUI
import Combine

private let DIVIDER_WIDTH: CGFloat = 1.5
private let DIVIDER_EXTENT: CGFloat = 16
private let DIVIDER_DRAG_RANGE: CGFloat = 16
private let BUTTON_SIZE: CGFloat = 44
private let BUTTON_SPACING: CGFloat = 32

class EditCutControl: TouchView {
    private(set) weak var editUpdater: EditUpdater?
    private(set) var context: EditGallery.Context?
    
    private var scrollViewUpdate: AnyCancellable?
    
    private let topArrowConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 16, weight: .semibold))
    
    private var splitBefore = EditSplitDivider()
    private var splitAfter = EditSplitDivider()
    private var splitButton = UIButtonPro()
    private var splitArea = UIView()
    private var splitDeletors = [EditSplitDeletorList]()
    
    private var cutNorRect = RECT0011
    private var beginNorRect = RECT0011
    private var onDragView: UIView?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard editUpdater?.tab == .split else {
            return false
        }
        
        for view in ([splitButton] + splitDeletors.flatMap({ $0.deletors.map({ $0.button }) })) {
            if view.convert(view.bounds, to: self).contains(point) {
                return true
            }
        }
        
        return false
    }
}

extension EditCutControl: ForwardScrollProtocol {
    func passInteration(at point: CGPoint) -> Bool {
        guard editUpdater?.tab == .split else {
            return false
        }
        
        for view in [splitBefore, splitAfter] {
            if view.convert(view.bounds, to: self).contains(point) || getCurrentTouch()?.view == view {
                return true
            }
        }
        
        return false
    }

    func setup(editUpdater: EditUpdater, context: EditGallery.Context) {
        self.editUpdater = editUpdater
        self.context = context
        
        let isVer = editUpdater.axis == .vertical
        
        eaddSubview(splitArea
            .eaddSubview(splitBefore
                .eselfConstraints([isVer ? .height(40) : .width(40)]),
            [.top(-20), .leading(0), isVer ? .trailing(0) : .bottom(0)])
            .eaddSubview(splitAfter
                .eselfConstraints([isVer ? .height(40) : .width(40)]),
            [.bottom(0), .trailing(0), isVer ? .leading(0) : .top(0)]))
        
        eaddSubview(splitButton
            .setContentColor(.white)
            .econfiguration({ configuration in
                var configuration = configuration
                configuration?.cornerStyle = .capsule
                return configuration
            }))
        
//        setGestureMappings(zip([firstDragger, afterDragger, areaView], [dragAction, dragAction, dragAction]))
        
        scrollViewUpdate = editUpdater.editGallery.scrollViewUpdate.eraseToAnyPublisher().sink { [self] _ in
            contentUpdate(editUpdater: editUpdater, context: context)
        }
    }

    func update(editUpdater: EditUpdater, context: EditGallery.Context) {
        self.editUpdater = editUpdater
        self.context = context
        
        if !editUpdater.editGallery.onZoom {
            contentUpdate(editUpdater: editUpdater, context: context)
        }
        
        alpha = editUpdater.tab == .split ? 1 : 0
    }
    
    func contentUpdate(editUpdater: EditUpdater, context: EditGallery.Context) {
        guard let stackView = context.coordinator.stackView,
              let scrollView = context.coordinator.scrollView
        else { return }
        
        let stackFrame = stackView.convert(stackView.bounds, to: self)
        let scrollFrame = scrollView.convert(scrollView.bounds, to: self)
        let isVer = editUpdater.axis == .vertical
        
        if stackFrame.width == 0 || stackFrame.height == 0 { return }
        
        if alpha < 0.5 {
            let beginSize = scrollFrame.size * 0.25
            let expectFrame = CGRect(mid: scrollFrame.mid, size: beginSize)
            
            cutNorRect = expectFrame.relative(to: stackFrame).limit0011()
        }
        
        let cutRect = cutNorRect * stackFrame.size + stackFrame.origin
        
        splitBefore.layer.fillColor = ._red
        splitAfter.layer.fillColor = ._red
        splitArea.backgroundColor = editUpdater.cutUpdater?.mode == .pair ? ._red.withAlphaComponent(0.2) : .clear
        splitArea.frame = isVer ? CGRect(x: stackFrame.minX, y: cutRect.minY, width: stackFrame.width, height: cutRect.height) : CGRect(x: cutRect.minX, y: stackFrame.minY, width: cutRect.width, height: stackFrame.height)
        splitButton.transform = .identity
        splitButton.frame = isVer ? CGRect(x: min(bounds.width - BUTTON_SIZE - 12, stackFrame.maxX + 12.0), y: cutRect.midY - BUTTON_SIZE / 2, width: BUTTON_SIZE, height: BUTTON_SIZE) : CGRect(x: cutRect.midX - BUTTON_SIZE / 2, y: min(bounds.height - BUTTON_SIZE - 12, stackFrame.maxY + 24.0), width: BUTTON_SIZE, height: BUTTON_SIZE)
        splitButton.transform = .init(rotationAngle: editUpdater.cutUpdater?.mode == .pair ? 0 : -.pi)
        splitButton.setBackgroundColor(editUpdater.cutUpdater?.mode == .pair ? ._red : ._primary)
        splitButton.esetImage(editUpdater.cutUpdater?.mode == .pair ? .trash : .scissors, for: .normal)
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
        
//        if onDragView == beforeDragger {
//            var newMinX = beginNorRect.minX
//            var newMinY = beginNorRect.minY
//            
//            if isVer {
//                newMinY = min(beginNorRect.minY + translate.y, beginNorRect.maxY - minWidth / stackFrame.height)
//            } else {
//                newMinX = min(beginNorRect.minX + translate.x, beginNorRect.maxX - minWidth / stackFrame.width)
//            }
//            
//            cutNorRect = CGRect(x: newMinX, y: newMinY, width: beginNorRect.maxX - newMinX, height: beginNorRect.maxY - newMinY).limit0011()
//        }
//        
//        if onDragView == afterDragger {
//            var newMaxX = beginNorRect.maxX
//            var newMaxY = beginNorRect.maxY
//            
//            if isVer {
//                newMaxY = max(beginNorRect.maxY + translate.y, beginNorRect.minY + minWidth / stackFrame.height)
//            } else {
//                newMaxX = max(beginNorRect.maxX + translate.x, beginNorRect.minX + minWidth / stackFrame.width)
//            }
//            
//            cutNorRect = CGRect(x: beginNorRect.minX, y: beginNorRect.minY, width: newMaxX - beginNorRect.minX, height: newMaxY - beginNorRect.minY).limit0011()
//        }

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

class EditSplitDivider: UIView {
    override final class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override var layer: CAShapeLayer {
        return super.layer as! CAShapeLayer
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        update()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        update()
    }
    
    private func update() {
        let isVer = bounds.width > bounds.height
        
        layer.path = UIBezierPath()
            .emove(to: CGPoint(x: isVer ? 0 : bounds.midY, y: isVer ? bounds.midX : 0))
            .eaddLine(to: CGPoint(x: isVer ? bounds.maxX : bounds.midY, y: isVer ? bounds.midX : bounds.maxY))
            .cgPath.copy(dashingWithPhase: 0, lengths: [5, 10]).copy(strokingWithWidth: 3, lineCap: .round, lineJoin: .round, miterLimit: .pi)
    }
}
