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
private let DELETE_SIZE: CGFloat = 36
private let BUTTON_SIZE: CGFloat = 44
private let BUTTON_SPACING: CGFloat = 32

class EditCutControl: TouchView {
    private(set) weak var editUpdater: EditUpdater?
    private(set) var context: EditGallery.Context?
    
    private var scrollViewUpdate: AnyCancellable?
    private var deleteAll: AnyCancellable?
    
    private let iconConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 14, weight: .bold))
    
    private var splitBefore = EditSplitDivider()
    private var splitAfter = EditSplitDivider()
    private var splitButton = UIButtonPro()
    private var splitMarks = [EditSplitMark]()
    private var splitArea = UIView()
    private var splitDeletors = [EditSplitDeletorList]()
    
    private var cutNorRect = RECT0011
    private var cutNorPart = CGFloat.zero
    private var beginNorRect = RECT0011
    private var beginNorPart = CGFloat.zero
    private var onDragView: UIView?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard editUpdater?.tab == .split else {
            return false
        }
        
        for view in ([splitButton] + splitDeletors.flatMap({ [$0.before?.button, $0.after?.button].compactMap({ $0 }) })) {
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
        
        for view in [splitBefore, splitAfter, splitArea] {
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
             [.top(isVer ? -20 : 0), .leading(isVer ? 0 : -20), isVer ? .trailing(0) : .bottom(0)])
            .eaddSubview(splitAfter
                .eselfConstraints([isVer ? .height(40) : .width(40)]),
             [.bottom(isVer ? -20 : 0), .trailing(isVer ? 0 : -20), isVer ? .leading(0) : .top(0)]))
        
        eaddSubview(splitButton
            .egestureRecognizers([UITapGestureRecognizer(target: self, action: #selector(cutAction))])
            .setContentColor(.white)
            .econfiguration({ configuration in
                var configuration = configuration
                configuration?.cornerStyle = .capsule
                return configuration
            }))
        
        setGestureMappings(zip([splitBefore, splitAfter, splitArea], [dragAction, dragAction, dragAction]))
        
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
        
        deleteAll = editUpdater.cutUpdater?.deleteAll.eraseToAnyPublisher().sink(receiveValue: { [weak self] _ in
            guard let stackView = context.coordinator.stackView,
                  editUpdater.axis == .vertical,
                  let self = self
            else { return }
            
            var curNorRects: [CGRect] = []
            
            for splitDeletor in splitDeletors {
                let size = splitDeletor.item.size
                let stackFrame = stackView.convert(stackView.bounds, to: self)
                
                guard size.height > HIGH_REMOVE,
                      size.height > LOW_REMOVE
                else { return }
                
                if let areaFrame = splitDeletor.before?.area.frame {
                    curNorRects.append(CGRect(origin: areaFrame.origin - stackFrame.origin, size: areaFrame.size) / stackFrame.size)
                }
                
                if let areaFrame = splitDeletor.after?.area.frame {
                    curNorRects.append(CGRect(origin: areaFrame.origin - stackFrame.origin, size: areaFrame.size) / stackFrame.size)
                }
            }
            
            applyCuts(curNorRects, switchStitch: false)
        })
    }
    
    func contentUpdate(editUpdater: EditUpdater, context: EditGallery.Context) {
        guard let stackView = context.coordinator.stackView,
              let scrollView = context.coordinator.scrollView
        else { return }
        
        let stackFrame = stackView.convert(stackView.bounds, to: self)
        let scrollFrame = scrollView.convert(scrollView.bounds, to: self)
        let isVer = editUpdater.axis == .vertical
        
        if stackFrame.width == 0 || stackFrame.height == 0 { return }
        
        let beginSize = scrollFrame.size * 0.25
        let expectFrame = CGRect(mid: scrollFrame.mid, size: beginSize)
        let norRect = expectFrame.relative(to: stackFrame).limit0011()
        
        if editUpdater.cutUpdater?.mode == .pair {
            cutNorPart = isVer ? norRect.midY : norRect.midX
        } else {
            cutNorRect = norRect
        }
        
        if alpha < 0.5 {
            cutNorPart = isVer ? norRect.midY : norRect.midX
            cutNorRect = norRect
        }
        
        splitBefore.layer.fillColor = ._red
        splitAfter.layer.fillColor = editUpdater.cutUpdater?.mode == .pair ? ._red : UIColor.clear.cgColor
        splitArea.backgroundColor = editUpdater.cutUpdater?.mode == .pair ? ._red.withAlphaComponent(0.2) : .clear
        
        if editUpdater.cutUpdater?.mode == .pair {
            let cutRect = cutNorRect * stackFrame.size + stackFrame.origin
            splitArea.frame = isVer ? CGRect(x: stackFrame.minX, y: cutRect.minY, width: stackFrame.width, height: cutRect.height) : CGRect(x: cutRect.minX, y: stackFrame.minY, width: cutRect.width, height: stackFrame.height)
            splitButton.transform = .identity
            splitButton.frame = isVer ? CGRect(x: min(bounds.width - BUTTON_SIZE - 12, stackFrame.maxX + 12.0), y: cutRect.midY - BUTTON_SIZE / 2, width: BUTTON_SIZE, height: BUTTON_SIZE) : CGRect(x: cutRect.midX - BUTTON_SIZE / 2, y: min(bounds.height - BUTTON_SIZE - 12, stackFrame.maxY + 24.0), width: BUTTON_SIZE, height: BUTTON_SIZE)
        } else {
            let cutPart = cutNorPart * (isVer ? stackFrame.height : stackFrame.width) + (isVer ? stackFrame.minY : stackFrame.minX)
            splitArea.frame = isVer ? CGRect(x: stackFrame.minX, y: cutPart, width: stackFrame.width, height: 0) : CGRect(x: cutPart, y: stackFrame.minY, width: 0, height: stackFrame.height)
            splitButton.transform = .identity
            splitButton.frame = isVer ? CGRect(x: min(bounds.width - BUTTON_SIZE - 12, stackFrame.maxX + 12.0), y: cutPart - BUTTON_SIZE / 2, width: BUTTON_SIZE, height: BUTTON_SIZE) : CGRect(x: cutPart - BUTTON_SIZE / 2, y: min(bounds.height - BUTTON_SIZE - 12, stackFrame.maxY + 24.0), width: BUTTON_SIZE, height: BUTTON_SIZE)
            splitButton.transform = .init(rotationAngle: -.pi)
        }
        
        splitArea.layoutIfNeeded()
        
        splitButton.setBackgroundColor(._red)
        splitButton.esetImage(UIImage(named: editUpdater.cutUpdater?.mode == .pair ? "trash" : "scissors", variableValue: 0, configuration: iconConfiguration), for: .normal)
        
        let newMarkItems = Array(editUpdater.items.dropLast())
        
        let oldMarkItems = splitMarks.map { $0.item }

        oldMarkItems.transformArray(to: newMarkItems) { [self] item, index in
            let frame = itemFrame(from: item, context: context)
            splitMarks.insert(makeMark(item: item, isVer: isVer, frame: frame), at: index)
        } remove: { [self] index in
            removeMark(at: index)
        } move: { [self] (from, to) in
            splitMarks.insert(removeMark(at: from), at: to)
        }
        
        splitMarks.forEach { mark in
            let frame = itemFrame(from: mark.item, context: context)
            mark.divider.frame = markFrame(isVer: isVer, frame: frame)
        }
        
        let oldDeletorItems = splitDeletors.map { $0.item }

        oldDeletorItems.transformArray(to: editUpdater.items) { [self] item, index in
            let frame = itemFrame(from: item, context: context)
            splitDeletors.insert(makeDeletor(item: item, isVer: isVer, frame: frame), at: index)
        } remove: { [self] index in
            removeDeletor(at: index)
        } move: { [self] (from, to) in
            splitDeletors.insert(removeDeletor(at: from), at: to)
        }
        
        splitDeletors.forEach { deletor in
            let frame = itemFrame(from: deletor.item, context: context)
            deletorSetup(deletor: deletor, isVer: isVer, frame: frame)
        }
    }
    
    private func itemFrame(from item: StitchItem, context: EditGallery.Context) -> CGRect {
        guard let item = itemView(from: item, context: context) else {
            return .zero
        }
        
        return item.convert(item.bounds, to: self)
    }
    
    private func itemView(from item: StitchItem, context: EditGallery.Context) -> UIView? {
        guard let stack = context.coordinator.stackView,
              let index = (stack.arrangedSubviews as? [EditItem])?.firstIndex(where: { $0.item == item }),
              stack.arrangedSubviews.indices.contains(index)
        else { return nil }
        
        let item = stack.arrangedSubviews[index]
        
        return item
    }
    
    private func makeMark(item: StitchItem, isVer: Bool, frame: CGRect) -> EditSplitMark {
        if let view = splitMarks.first(where: { $0.item == item }) {
            return view
        }
        
        let divider = EditSplitDivider(frame: markFrame(isVer: isVer, frame: frame))
        divider.layer.fillColor = ._primary
        
        insertSubview(divider, at: 0)
        
        return EditSplitMark(item: item, divider: divider)
    }
    
    @discardableResult
    private func removeMark(at index: Int) -> EditSplitMark {
        let view = splitMarks.remove(at: index)
        view.divider.removeFromSuperview()
        
        return view
    }
    
    private func markFrame(isVer: Bool, frame: CGRect) -> CGRect {
        return CGRect(x: isVer ? frame.minX : (frame.maxX - 5), y: isVer ? (frame.maxY - 5) : frame.minY,
                      width: isVer ? frame.width : 10, height: isVer ? 10 : frame.height)
    }
    
    private func makeDeletor(item: StitchItem, isVer: Bool, frame: CGRect) -> EditSplitDeletorList {
        if let view = splitDeletors.first(where: { $0.item == item }) {
            return view
        }
        
        let deletor = EditSplitDeletorList(item: item)
        deletorSetup(deletor: deletor, isVer: isVer, frame: frame)
        
        return deletor
    }
    
    @discardableResult
    private func removeDeletor(at index: Int) -> EditSplitDeletorList {
        let view = splitDeletors.remove(at: index)
        view.remove()
        
        return view
    }
    
    private func deletorSetup(deletor: EditSplitDeletorList, isVer: Bool, frame: CGRect) {
        guard isVer else {
            deletor.remove()
            return
        }
        
        let previewSize = deletor.item.size * frame.width / deletor.item.size.width
        let itemRect = deletor.item.process.rect * previewSize

        let lowRemove = LOW_REMOVE * previewSize.width / deletor.item.size.width
        let highRemove = HIGH_REMOVE * previewSize.width / deletor.item.size.width
        
        if itemRect.minY < (lowRemove - 1) && editUpdater?.cutUpdater?.mode == .single {
            let areaFrame = CGRect(x: frame.minX, y: frame.minY,
                                   width: frame.width, height: lowRemove - itemRect.minY)
            let buttonFrame = CGRect(x: min(bounds.width - DELETE_SIZE - 12, frame.minX - 12.0 - DELETE_SIZE), y: areaFrame.midY - DELETE_SIZE / 2, width: DELETE_SIZE, height: DELETE_SIZE)
            
            if deletor.before == nil {
                deletor.before = .init(area: UIView(frame: areaFrame), button: UIButtonPro(frame: buttonFrame), isVer: isVer)
            }
            
            deletor.before?.button.frame = buttonFrame
            deletor.before?.button.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(deleteAction))]
            deletor.before?.area.frame = areaFrame
            deletor.before?.area.layoutIfNeeded()
        } else {
            deletor.before?.remove()
            deletor.before = nil
        }
        
        if (previewSize.height - itemRect.maxY) < (highRemove - 1) && editUpdater?.cutUpdater?.mode == .single {
            let height = highRemove - (previewSize.height - itemRect.maxY)
            
            let areaFrame = CGRect(x: frame.minX, y: frame.maxY - height,
                                   width: frame.width, height: height)
            let buttonFrame = CGRect(x: min(bounds.width - DELETE_SIZE - 12, frame.minX - 12.0 - DELETE_SIZE), y: areaFrame.midY - DELETE_SIZE / 2, width: DELETE_SIZE, height: DELETE_SIZE)
            
            if deletor.after == nil {
                deletor.after = .init(area: UIView(frame: areaFrame), button: UIButtonPro(frame: buttonFrame), isVer: isVer)
            }
            
            deletor.after?.button.frame = buttonFrame
            deletor.after?.button.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(deleteAction))]
            deletor.after?.area.frame = areaFrame
            deletor.after?.area.layoutIfNeeded()
        } else {
            deletor.after?.remove()
            deletor.after = nil
        }
        
        for view in [deletor.before, deletor.after].compactMap({ $0 }) {
            addSubview(view.area)
            addSubview(view.button)
        }
    }
    
    private func dragAction(g: TouchGesture) {
        guard let stackView = context?.coordinator.stackView else { return }
        
        let minWidth = CGFloat(1)
        let stackFrame = stackView.convert(stackView.bounds, to: self)
        let isVer = editUpdater?.axis == .vertical
        
        let translate = g.translation(in: self) / stackFrame.size
        
        if g.state == .began {
            beginNorRect = cutNorRect
            beginNorPart = cutNorPart
            onDragView = g.view
        }
        
        if onDragView != g.view { return }
        
        if onDragView == splitBefore && editUpdater?.cutUpdater?.mode == .pair {
            var newMinX = beginNorRect.minX
            var newMinY = beginNorRect.minY
            
            if isVer {
                newMinY = min(beginNorRect.minY + translate.y, beginNorRect.maxY - minWidth / stackFrame.height)
            } else {
                newMinX = min(beginNorRect.minX + translate.x, beginNorRect.maxX - minWidth / stackFrame.width)
            }
            
            cutNorRect = CGRect(x: newMinX, y: newMinY, width: beginNorRect.maxX - newMinX, height: beginNorRect.maxY - newMinY).limit0011()
        }
        
        if onDragView == splitAfter && editUpdater?.cutUpdater?.mode == .pair {
            var newMaxX = beginNorRect.maxX
            var newMaxY = beginNorRect.maxY
            
            if isVer {
                newMaxY = max(beginNorRect.maxY + translate.y, beginNorRect.minY + minWidth / stackFrame.height)
            } else {
                newMaxX = max(beginNorRect.maxX + translate.x, beginNorRect.minX + minWidth / stackFrame.width)
            }
            
            cutNorRect = CGRect(x: beginNorRect.minX, y: beginNorRect.minY, width: newMaxX - beginNorRect.minX, height: newMaxY - beginNorRect.minY).limit0011()
        }
        
        if onDragView == splitArea && editUpdater?.cutUpdater?.mode == .pair {
            if isVer {
                let tranY = min(max(translate.y, -beginNorRect.minY), 1 - beginNorRect.maxY)
                cutNorRect = beginNorRect.applying(.init(translationX: 0, y: tranY))
            } else {
                let tranX = min(max(translate.x, -beginNorRect.minX), 1 - beginNorRect.maxX)
                cutNorRect = beginNorRect.applying(.init(translationX: tranX, y: 0))
            }
        }

        if editUpdater?.cutUpdater?.mode == .single {
            cutNorPart = min(max(beginNorPart + (isVer ? translate.y : translate.x), 0), 1)
        }
        
        if let editUpdater = editUpdater, let context = context {
            update(editUpdater: editUpdater, context: context)
        }
    }
    
    @objc private func cutAction() {
        guard let editUpdater = editUpdater else { return }
        
        let isVer = editUpdater.axis == .vertical
        let cutNorRect = editUpdater.cutUpdater?.mode == .pair ? cutNorRect : CGRect(x: isVer ? 0 : cutNorPart, y: isVer ? cutNorPart : 0, width: isVer ? 1 : MIN_REMOVE, height: isVer ? MIN_REMOVE : 1)
        
        applyCuts([cutNorRect], switchStitch: editUpdater.cutUpdater?.mode == .single)
    }
    
    @objc private func deleteAction(g: UITapGestureRecognizer) {
        guard let editUpdater = editUpdater,
              let stackView = context?.coordinator.stackView,
              editUpdater.axis == .vertical,
              let splitDeletor = splitDeletors.first(where: { $0.before?.button == g.view || $0.after?.button == g.view })
        else { return }
        
        let size = splitDeletor.item.size
        let stackFrame = stackView.convert(stackView.bounds, to: self)
        
        guard size.height > HIGH_REMOVE,
              size.height > LOW_REMOVE
        else { return }
        
        if g.view == splitDeletor.before?.button, let areaFrame = splitDeletor.before?.area.frame {
            applyCuts([CGRect(origin: areaFrame.origin - stackFrame.origin, size: areaFrame.size) / stackFrame.size], switchStitch: false)
        }
        
        if g.view == splitDeletor.after?.button, let areaFrame = splitDeletor.after?.area.frame {
            applyCuts([CGRect(origin: areaFrame.origin - stackFrame.origin, size: areaFrame.size) / stackFrame.size], switchStitch: false)
        }
    }
    
    private func applyCuts(_ rects: [CGRect], switchStitch: Bool) {
        guard let editUpdater = editUpdater else { return }
        
        Task {
            editUpdater.anim = true
            context?.coordinator.view?.layoutIfNeeded()
            editUpdater.anim = false
            
            editUpdater.undoRedoBegin()

            do {
                try await editUpdater.cutUpdater?.applyCuts(rects)
                
                UIView.animate(withDuration: ANIM_DURATION, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
                    
                    splitArea.alpha = 0
                    splitButton.alpha = 0
                }
                
                if switchStitch {
                    editUpdater.tab = .stitch
                }
                
                editUpdater.undoRedoCommit()
            } catch {
                editUpdater.warningAlert("Exceed max items, can't \(editUpdater.cutUpdater?.mode == .single ? "split" : "cut")")
            }
            
            UIView.animate(withDuration: ANIM_DURATION, delay: 0.25, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
                
                splitArea.alpha = 1
                splitButton.alpha = 1
            }
        }
    }
}

class EditSplitMark {
    let item: StitchItem
    let divider: EditSplitDivider
    
    init(item: StitchItem, divider: EditSplitDivider) {
        self.item = item
        self.divider = divider
    }
}

class EditSplitDeletorList {
    let item: StitchItem
    var before: EditSplitDeletor?
    var after: EditSplitDeletor?
    
    init(item: StitchItem) {
        self.item = item
    }
    
    func remove() {
        [before, after].forEach({ $0?.remove() })
    }
}

class EditSplitDeletor {
    private let iconConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 12, weight: .bold))
    
    private let min = EditSplitDivider()
    private let max = EditSplitDivider()
    
    let area: UIView
    let button: UIButtonPro
    
    init(area: UIView, button: UIButtonPro, isVer: Bool) {
        self.area = area
        self.button = button
        
        area.eaddSubview(min
                .eselfConstraints([isVer ? .height(10) : .width(10)]),
             [.top(isVer ? -5 : 0), .leading(isVer ? 0 : -5), isVer ? .trailing(0) : .bottom(0)])
            .eaddSubview(max
                .eselfConstraints([isVer ? .height(10) : .width(10)]),
             [.bottom(isVer ? -5 : 0), .trailing(isVer ? 0 : -5), isVer ? .leading(0) : .top(0)])
        
        min.layer.fillColor = ._red
        max.layer.fillColor = ._red
        area.backgroundColor = ._red.withAlphaComponent(0.2)
        
        button
            .esetImage(UIImage(named: "trash", variableValue: 0, configuration: iconConfiguration), for: .normal)
            .setContentColor(._white)
            .setBackgroundColor(._red)
            .econfiguration({ configuration in
                var configuration = configuration
                configuration?.cornerStyle = .capsule
                return configuration
            })
    }
    
    func remove() {
        for view in [area, button] {
            view.removeFromSuperview()
        }
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
            .emove(to: CGPoint(x: isVer ? 0 : bounds.midX, y: isVer ? bounds.midY : 0))
            .eaddLine(to: CGPoint(x: isVer ? bounds.maxX : bounds.midX, y: isVer ? bounds.midY : bounds.maxY))
            .cgPath.copy(dashingWithPhase: 0, lengths: [5, 10]).copy(strokingWithWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: .pi)
        
        clipsToBounds = true
    }
}
