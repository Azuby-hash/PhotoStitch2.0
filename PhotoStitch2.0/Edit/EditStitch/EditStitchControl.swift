//
//  EditStitchControl.swift
//  Photo Stitch
//
//  Created by Azuby on 6/24/25.
//

import UIKit
import SwiftUI
import Combine
import AVFoundation

private let DRAG_WIDTH: CGFloat = 24
private let DRAG_LONG: CGFloat = 32
private let DRAG_SHORT: CGFloat = 3

private let DIVIDER_WIDTH: CGFloat = 1.5
private let ICON_SIZE: CGSize = CGSize(width: 24, height: 24)
private let BUTTON_SIZE: CGFloat = 44
private let ARROW_SIZE: CGFloat = 32
private let ARROW_WIDTH: CGFloat = 3.5

enum EditStitchControlMode {
    case edgeDrag
    case contentDrag
}

enum EditStitchDrag {
    case before
    case after
    case none
}

class EditStitchControl: TouchView {
    private(set) weak var editUpdater: EditUpdater?
    private(set) var context: EditGallery.Context?
    
    private var scrollViewUpdate: AnyCancellable?
    
    private let beforeView = UIView()
    private let midDragView = UIView()
    private let afterView = UIView()
    private var stitchViews = [EditStitchViews]()
    
    private let midArrowConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 24, weight: .bold))
    private let otherConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 16, weight: .bold))
    
    private var beginNorFrameBefores: [(item: StitchItem, rect: CGRect)]?
    private var beginNorFrameAfters: [(item: StitchItem, rect: CGRect)]?
    private var beginNorFrameMids: [(item: StitchItem, rect: CGRect)]?
    private var dragFrom = EditStitchDrag.before

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        guard cEdit.getState() == .editing && cEdit.getTab() == .stitch else {
//            return false
//        }
        
        for view in stitchViews.map({ $0.button }) {
            if view.convert(view.bounds, to: self).contains(point) {
                return true
            }
        }
        
        return false
    }
    
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
        
        insertSubview(midDragView, at: 0)
        
        setGestureMappings(zip([beforeView, afterView, midDragView], [dragBefore, dragAfter, dragMid]))
        
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
    }
    
    private func contentUpdate(editUpdater: EditUpdater, context: EditGallery.Context) {
        let isVer = editUpdater.axis == .vertical
        let stitchUpdater = editUpdater.stitchUpdater
        
        guard let stack = context.coordinator.stackView, let items = stack.arrangedSubviews as? [EditItem], !items.isEmpty else { return }
        
        let rect = stack.convert(stack.bounds, to: self)
        
        midDragView.frame = stack.convert(stack.bounds, to: self)
//        midDragView.isUserInteractionEnabled = cEdit.getTab() == .stitch && cEdit.getState() == .editing && cEdit.getStitchIndex() != nil
        
        beforeView.frame.size = CGSize(width: isVer ? rect.width : DRAG_WIDTH, height: !isVer ? rect.height : DRAG_WIDTH)
        beforeView.frame.origin = CGPoint(x: !isVer ? rect.minX - DRAG_WIDTH : rect.minX, y: isVer ? rect.minY - DRAG_WIDTH : rect.minY)
        beforeView.layoutIfNeeded()
        
        afterView.frame.size = CGSize(width: isVer ? rect.width : DRAG_WIDTH, height: !isVer ? rect.height : DRAG_WIDTH)
        afterView.frame.origin = CGPoint(x: !isVer ? rect.maxX : rect.minX, y: isVer ? rect.maxY : rect.minY)
        afterView.layoutIfNeeded()
        
        let newItems = Array(items.dropLast()).compactMap({ $0.item })
        
        let oldItems = stitchViews.map { $0.item }

        oldItems.transformArray(to: newItems) { [self] item, index in
            stitchViews.insert(make(item: item, isVer: isVer, frame: itemFrame(from: item, context: context), editUpdater: editUpdater), at: index)
        } remove: { [self] index in
            remove(at: index)
        } move: { [self] (from, to) in
            stitchViews.insert(remove(at: from), at: to)
        }
        
        let selected = stitchViews.first(where: { $0.item == stitchUpdater?.selectItem })
        
        stitchViews.forEach { view in
            let frame = itemFrame(from: view.item, context: context)
            let width = selected?.item == view.item ? 0 : DIVIDER_WIDTH
            
            view.divider.frame = dividerFrame(isVer: isVer, frame: frame, width: width)
            view.button.frame = selected?.item == view.item ? doneFrame(isVer: isVer, frame: frame) : stitchFrame(isVer: isVer, frame: frame)
            view.button.setBackgroundColor(._primary)
            view.button.setContentColor(._white)
            view.button.setImage(UIImage(named: selected?.item == view.item ? "lock.open.fill" : "lock.fill", in: .main, with: otherConfiguration), for: .normal)
            
            UIView.performWithoutAnimation {
                if beginNorFrameBefores == nil && beginNorFrameAfters == nil {
                    if let selected = selected, selected.item != view.item {
                        view.divider.alpha = selected.divider.center.length(to: view.divider.center) < BUTTON_SIZE * 2 ? 0 : 1
                        view.button.alpha = selected.divider.center.length(to: view.divider.center) < BUTTON_SIZE * 2 ? 0 : 1
                    } else {
                        view.divider.alpha = 1
                        view.button.alpha = 1
                    }
                }
            }
            
            view.gradientB.frame = isVer ? CGRect(x: frame.minX, y: frame.maxY - 114, width: frame.width, height: 114) : CGRect(x: frame.maxX - 80, y: frame.minY, width: 80, height: frame.height)
            view.gradientB.alpha = selected?.item == view.item ? 1 : 0
            view.gradientB.elayerModifier { (layer: CAGradientLayer) in
                layer.shadowColor = ._primary
                layer.shadowOffset = CGSize(width: 0, height: 10)
                layer.shadowOpacity = 0.5
                layer.shadowRadius = 10
            }.esubviewsModifier { subviews in
                subviews.first(type: EditStitchArrow.self)?.subviews.first(type: UIImageView.self)?.image = UIImage(named: "chevron.\(isVer ? "down" : "right").2", in: .main, with: midArrowConfiguration)
                subviews.first(type: EditStitchArrow.self)?.esetOffset(isVer ? .init(x: 0, y: 15) : .init(x: 15, y: 0))
            }
            view.gradientB.layoutIfNeeded()

            view.gradientA.frame = isVer ? CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: 114) : CGRect(x: frame.maxX, y: frame.minY, width: 80, height: frame.height)
            view.gradientA.alpha = selected?.item == view.item ? 1 : 0
            view.gradientA.elayerModifier { (layer: CAGradientLayer) in
                layer.shadowColor = ._primary
                layer.shadowOffset = CGSize(width: 0, height: 10)
                layer.shadowOpacity = 0.5
                layer.shadowRadius = 10
            }.esubviewsModifier { subviews in
                subviews.first(type: EditStitchArrow.self)?.subviews.first(type: UIImageView.self)?.image = UIImage(named: "chevron.\(isVer ? "up" : "left").2", in: .main, with: midArrowConfiguration)
                subviews.first(type: EditStitchArrow.self)?.esetOffset(isVer ? .init(x: 0, y: -15) : .init(x: -15, y: 0))
            }
            view.gradientA.layoutIfNeeded()
        }
        
        stitchViews.forEach { view in
            guard let index = (stack.arrangedSubviews as? [EditItem])?.firstIndex(where: { $0.item == view.item }),
                  index > 0,
                  view.item != stitchUpdater?.selectItem
            else { return }
            
            let beforeLength = isVer ? view.item.process.rect.minY : view.item.process.rect.minX
            let afterLength = isVer ? (1 - view.item.process.rect.maxY) : (1 - view.item.process.rect.maxX)
            let beforeDragger = stitchViews[index - 1]
            
            UIView.performWithoutAnimation {
                if beginNorFrameBefores == nil && beginNorFrameAfters == nil && beforeDragger.divider.center.length(to: view.divider.center) < BUTTON_SIZE * 2 {
                    if beforeLength > afterLength {
                        if view.button.alpha > 0.5 && selected?.item != view.item {
                            view.divider.alpha = 0
                            view.button.alpha = 0
                        }
                    } else {
                        if view.button.alpha > 0.5 && selected?.item != view.item {
                            view.divider.alpha = 0
                            view.button.alpha = 0
                        }
                    }
                }
            }
        }
    }
    
    private func dividerFrame(isVer: Bool, frame: CGRect, width: CGFloat) -> CGRect {
        return isVer ? CGRect(x: frame.minX, y: frame.maxY - width / 2, width: frame.width, height: width) : CGRect(x: frame.maxX - width / 2, y: frame.minY, width: width, height: frame.height)
    }
    
    private func stitchFrame(isVer: Bool, frame: CGRect) -> CGRect {
        return isVer ? CGRect(x: min(bounds.width - BUTTON_SIZE - 12, frame.midX - BUTTON_SIZE / 2), y: frame.maxY - BUTTON_SIZE / 2, width: BUTTON_SIZE, height: BUTTON_SIZE) : CGRect(x: frame.maxX - BUTTON_SIZE / 2, y: min(bounds.height - BUTTON_SIZE - 12, frame.midY - BUTTON_SIZE / 2), width: BUTTON_SIZE, height: BUTTON_SIZE)
    }
    
    private func doneFrame(isVer: Bool, frame: CGRect) -> CGRect {
        return isVer ? CGRect(x: min(bounds.width - BUTTON_SIZE - 12, frame.maxX + 12.0), y: frame.maxY - BUTTON_SIZE / 2, width: BUTTON_SIZE, height: BUTTON_SIZE) : CGRect(x: frame.maxX - BUTTON_SIZE / 2, y: min(bounds.height - BUTTON_SIZE - 12, frame.maxY + 24.0), width: BUTTON_SIZE, height: BUTTON_SIZE)
    }
    
    private func make(item: StitchItem, isVer: Bool, frame: CGRect, editUpdater: EditUpdater) -> EditStitchViews {
        if let view = stitchViews.first(where: { $0.item == item }) {
            return view
        }
        
        let divider = UIViewPointSubview(frame: dividerFrame(isVer: isVer, frame: frame, width: DIVIDER_WIDTH))
            .ebackgroundColor(._primary)
        
        let button = UIButtonPro(frame: stitchFrame(isVer: isVer, frame: frame))
            .econfiguration({ configuration in
                var configuration = configuration
                configuration?.cornerStyle = .capsule
                return configuration
            })
            .etranslatesAutoresizingMaskIntoConstraints(true)
            .eaddTarget(self, action: #selector(centerControlEnable), for: .touchUpInside)
        
        let gradientB = EditStitchGradient()
            .eaddSubview(EditStitchArrow().eaddSubview(
                UIImageView()
                    .etintColor(._primary)
                    .eselfConstraints([.width(32), .height(32)]), [.centerX(0), .centerY(0)]
                ), [.width(0), .height(0), .centerX(0), .centerY(0)])
            .eisUserInteractionEnabled(false)
        
        let gradientA = EditStitchGradient()
            .eaddSubview(EditStitchArrow().eaddSubview(
                UIImageView()
                    .etintColor(._primary)
                    .eselfConstraints([.width(32), .height(32)]), [.centerX(0), .centerY(0)]
                ), [.width(0), .height(0), .centerX(0), .centerY(0)])
            .eisUserInteractionEnabled(false)
        
        addSubview(gradientB)
        addSubview(gradientA)
        addSubview(divider)
        addSubview(button)
        
        UIView.performWithoutAnimation {
            gradientB.alpha = 0
            gradientA.alpha = 0
        }
        
        return EditStitchViews(item: item, button: button, divider: divider, gradientB: gradientB, gradientA: gradientA)
    }
    
    @discardableResult
    private func remove(at index: Int) -> EditStitchViews {
        let remove = stitchViews.remove(at: index)
        
        remove.remove()
        
        return remove
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
    
    @objc private func centerControlEnable(button: UIButton) {
        let stitchUpdater = editUpdater?.stitchUpdater
        
        guard let stitchView = stitchViews.first(where: { $0.button == button }),
              let context = context,
              let stackView = context.coordinator.stackView,
              let scrollContent = context.coordinator.scrollContent,
              let scrollView = context.coordinator.scrollView,
              let itemView = itemView(from: stitchView.item, context: context),
              beginNorFrameBefores == nil,
              beginNorFrameAfters == nil
        else { return }
        
        let zoomScale = scrollView.zoomScale
        let isVer = editUpdater?.axis == .vertical
        
        let visibleSize = scrollView.bounds.inset(by: scrollView.contentInset).size
        let visibleDimUnscaled = (isVer ? visibleSize.height : visibleSize.width) / zoomScale

        if stitchUpdater?.selectItem == stitchView.item {
            UIView.animate(withDuration: ANIM_DURATION, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
                let contentOffset = scrollView.contentOffset
                let storedPadding = isVer ? stackView.convert(stackView.bounds, to: scrollContent).minY : stackView.convert(stackView.bounds, to: scrollContent).minX
                
                stitchUpdater?.setSelectItem(nil)
                
                context.coordinator.view?.layoutIfNeeded()
                
                let offX = isVer ? contentOffset.x : contentOffset.x - (storedPadding * zoomScale)
                let offY = isVer ? contentOffset.y - (storedPadding * zoomScale) : contentOffset.y

                scrollView.contentOffset = clampedContentOffset(CGPoint(x: offX, y: offY), in: scrollView)
            }
        } else {
            let itemFrame = itemView.convert(itemView.bounds, to: scrollContent)
            // 1. Calculate the 'visual' center target
            let itemEdgeInStack = isVer ? itemFrame.maxY : itemFrame.maxX
            let targetOffsetUnscaled = itemEdgeInStack - (visibleDimUnscaled / 2)
            
            // 2. Add 'Top/Leading' padding:
            // If targetOffset is negative, we need to push the stackView down
            // so the scrollview can reach a 'negative' position relative to the stack.
            let topLeadingPadding = max(0, -targetOffsetUnscaled)
            
            // 3. Add 'Bottom/Trailing' padding:
            // Ensure the content is long enough to scroll to the item if it's at the end.
            let stackDim = isVer ? stackView.frame.height : stackView.frame.width
            let bottomTrailingPadding = max(0, (targetOffsetUnscaled + visibleDimUnscaled) - (stackDim + topLeadingPadding))

            let totalWidth = isVer ? stackView.frame.width : (stackDim + topLeadingPadding + bottomTrailingPadding)
            let totalHeight = isVer ? (stackDim + topLeadingPadding + bottomTrailingPadding) : stackView.frame.height

            if scrollContent.constraints.contains(where: { ($0.firstAnchor == scrollContent.widthAnchor || $0.firstAnchor == scrollContent.heightAnchor) && $0.secondAnchor == nil }) {
                stitchUpdater?.setConstraints([
                    scrollContent.widthAnchor.constraint(equalToConstant: scrollContent.bounds.width),
                    scrollContent.heightAnchor.constraint(equalToConstant: scrollContent.bounds.height),
                    
                    itemView.bottomAnchor.constraint(equalTo: scrollContent.topAnchor, constant: itemFrame.maxY),
                    itemView.trailingAnchor.constraint(equalTo: scrollContent.leadingAnchor, constant: itemFrame.maxX)
                ])
                
                context.coordinator.view?.layoutIfNeeded()
            } else {
                stitchUpdater?.setConstraints([
                    scrollContent.widthAnchor.constraint(equalToConstant: totalWidth),
                    scrollContent.heightAnchor.constraint(equalToConstant: totalHeight),
                    
                    itemView.bottomAnchor.constraint(equalTo: scrollContent.topAnchor, constant: itemView.frame.maxY + (isVer ? topLeadingPadding : 0)),
                    itemView.trailingAnchor.constraint(equalTo: scrollContent.leadingAnchor, constant: itemView.frame.maxX + (isVer ? 0 : topLeadingPadding))
                ])
                
                context.coordinator.view?.layoutIfNeeded()
            }
            
            let finalTarget = targetOffsetUnscaled + topLeadingPadding
            let offX = isVer ? scrollView.contentOffset.x : (finalTarget * zoomScale - scrollView.contentInset.left)
            let offY = isVer ? (finalTarget * zoomScale - scrollView.contentInset.top) : scrollView.contentOffset.y
            
            scrollView.setContentOffset(CGPoint(x: offX, y: offY), animated: true)
            
            stitchUpdater?.setSelectItem(stitchView.item)
        }
    }
    
    private func clampedContentOffset(_ targetOffset: CGPoint, in scrollView: UIScrollView) -> CGPoint {
        let minOffsetX = -scrollView.contentInset.left
        let minOffsetY = -scrollView.contentInset.top
        let maxOffsetX = max(minOffsetX, scrollView.contentSize.width  + scrollView.contentInset.right  - scrollView.bounds.width)
        let maxOffsetY = max(minOffsetY, scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.height)

        return CGPoint(
            x: min(max(targetOffset.x, minOffsetX), maxOffsetX),
            y: min(max(targetOffset.y, minOffsetY), maxOffsetY)
        )
    }
}

extension EditStitchControl: ForwardScrollProtocol {
    func passInteration(at point: CGPoint) -> Bool {
        let stitchUpdater = editUpdater?.stitchUpdater
        
//        guard cEdit.getState() == .editing && cEdit.getTab() == .stitch else {
//            return false
//        }
        
        for view in [beforeView, afterView, midDragView] {
            if view.convert(view.bounds, to: self).contains(point) || getCurrentTouch()?.view == view {
                if view == midDragView && stitchUpdater?.selectItem == nil {
                    return false
                }
                
                return true
            }
        }
        
        return false
    }
}

extension EditStitchControl {
    private func dragBefore(g: TouchGesture) {
        let stitchUpdater = editUpdater?.stitchUpdater
        
        if g.state == .ended || g.state == .cancelled {
            UIView.animate(withDuration: ANIM_DURATION, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
                stitchViews.forEach({ $0.show(true) })
            }
        }
        
        guard let scrollContent = context?.coordinator.scrollContent,
              let stackView = context?.coordinator.stackView
        else { return }
        
        if g.state == .began {
            beginDrag()
            
            beginNorFrameBefores = context?.coordinator.content?.editUpdater.items.map({ ($0, $0.process.rect) })
            
            let scrollContentBounds = scrollContent.bounds
            
            stitchUpdater?.setSelectItem(nil)
            
            stitchUpdater?.setConstraints([
                scrollContent.widthAnchor.constraint(equalToConstant: scrollContentBounds.width),
                scrollContent.heightAnchor.constraint(equalToConstant: scrollContentBounds.height),
                stackView.bottomAnchor.constraint(equalTo: scrollContent.bottomAnchor),
                stackView.trailingAnchor.constraint(equalTo: scrollContent.trailingAnchor),
            ])
            
            UIView.animate(withDuration: ANIM_DURATION, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
                stitchViews.forEach({ $0.show(false) })
            }
            
            dragFrom = .after
        }
        
    
        if let begin = beginNorFrameBefores {
            UIView.performWithoutAnimation {
                dragCalculate(g: g, index: -1, isMid: false, begin: begin)
            }
        }
        
        if g.state == .ended || g.state == .cancelled {
            if stitchUpdater?.selectItem == nil {
                stitchUpdater?.setConstraints([])
            }
            
            endDrag()
        }
    }
    
    private func dragAfter(g: TouchGesture) {
        let stitchUpdater = editUpdater?.stitchUpdater
        
        if g.state == .ended || g.state == .cancelled {
            UIView.animate(withDuration: ANIM_DURATION, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
                stitchViews.forEach({ $0.show(true) })
            }
        }
        
        guard let scrollContent = context?.coordinator.scrollContent,
              let stackView = context?.coordinator.stackView
        else { return }
        
        if g.state == .began {
            beginDrag()
            
            beginNorFrameAfters = context?.coordinator.content?.editUpdater.items.map({ ($0, $0.process.rect) })
            
            let scrollContentBounds = scrollContent.bounds
            
            stitchUpdater?.setSelectItem(nil)
            
            stitchUpdater?.setConstraints([
                scrollContent.widthAnchor.constraint(equalToConstant: scrollContentBounds.width),
                scrollContent.heightAnchor.constraint(equalToConstant: scrollContentBounds.height),
                stackView.topAnchor.constraint(equalTo: scrollContent.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: scrollContent.leadingAnchor),
            ])
            
            UIView.animate(withDuration: ANIM_DURATION, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
                stitchViews.forEach({ $0.show(false) })
            }
            
            dragFrom = .before
        }
        
        if let begin = beginNorFrameAfters {
            UIView.performWithoutAnimation {
                dragCalculate(g: g, index: stackView.arrangedSubviews.count - 1, isMid: false, begin: begin)
            }
        }
        
        if g.state == .ended || g.state == .cancelled {
            if stitchUpdater?.selectItem == nil {
                stitchUpdater?.setConstraints([])
            }
            
            endDrag()
        }
    }
    
    private func dragMid(g: TouchGesture) {
        if g.state == .ended || g.state == .cancelled {
            UIView.animate(withDuration: ANIM_DURATION, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
                stitchViews.forEach({ $0.show(true) })
            }
        }
        
        guard let editUpdater = editUpdater,
              let stitchUpdater = editUpdater.stitchUpdater,
              let stitchItem = stitchUpdater.selectItem,
              let items = context?.coordinator.content?.editUpdater.items,
              let stitchIndex = items.firstIndex(of: stitchItem),
              items.indices.contains(stitchIndex),
              items.indices.contains(stitchIndex + 1),
              let stackView = context?.coordinator.stackView,
              stackView.arrangedSubviews.indices.contains(stitchIndex),
              stackView.arrangedSubviews.indices.contains(stitchIndex + 1)
        else { return }
        
        if g.state == .began {
            beginDrag()
            
            if stackView.bounds.contains(g.location(in: stackView)) {
                let isVer = editUpdater.axis == .vertical
                
                if isVer {
                    if stackView.arrangedSubviews[stitchIndex].bounds.maxY > g.location(in: stackView.arrangedSubviews[stitchIndex]).y {
                        dragFrom = .before
                    } else {
                        dragFrom = .after
                    }
                } else {
                    if stackView.arrangedSubviews[stitchIndex].bounds.maxX > g.location(in: stackView.arrangedSubviews[stitchIndex]).x {
                        dragFrom = .before
                    } else {
                        dragFrom = .after
                    }
                }
            }
            
            beginNorFrameMids = context?.coordinator.content?.editUpdater.items.map({ ($0, $0.process.rect) })
        }
        
        UIView.performWithoutAnimation {
            dragCalculate(g: g, index: stitchIndex, isMid: true, begin: stitchUpdater.frames)
        }
        
        if g.state == .ended || g.state == .cancelled {
            endDrag()
        }
    }
    
    private func dragCalculate(g: TouchGesture, index: Int, isMid: Bool, begin: [(item: StitchItem, rect: CGRect)]) {
        guard let stackView = context?.coordinator.stackView,
              let editItems = stackView.arrangedSubviews as? [EditItem],
              let stitchUpdater = editUpdater?.stitchUpdater
        else { return }

        let isVer = editUpdater?.axis == .vertical
        
        if dragFrom == .before {
            let translate = isMid ? (stitchUpdater.translateBefore + g.translation(in: stackView)) : (g.translation(in: stackView) * -1)
            
            var index = index
            var tran = isVer ? translate.y : translate.x
            var changes = [StitchItem: (CGRect, CGFloat)]()
            var saveTran = CGPoint.zero
            
            while index >= 0 && abs(tran) > 0 {
                guard begin.indices.contains(index) else { break }
                
                let (item, rect) = begin[index]
                let editRect = rect * editItems[index].imageView.bounds.size
                let maxLength = isVer ? editItems[index].imageView.bounds.height : editItems[index].imageView.bounds.width
                
                if tran > 0 {
                    let reduce = min(tran, isVer ? editRect.height : editRect.width)
                    tran = tran - reduce
                    saveTran = saveTran + reduce
                    changes[item] = (rect, -reduce / maxLength)
                    index -= 1
                } else {
                    let bonus = min(-tran, maxLength - (isVer ? editRect.maxY : editRect.maxX))
                    tran = tran + bonus
                    saveTran = saveTran - bonus
                    changes[item] = (rect, bonus / maxLength)
                    break
                }
            }
            
            changes.forEach { (item, info) in
                let (rect, change) = info

                item.process.setRect(CGRect(origin: rect.origin, maxOrigin: rect.maxOrigin + CGPoint(x: isVer ? 0 : change, y: isVer ? change : 0)))
            }
            
            if (g.state == .ended || g.state == .cancelled) && isMid {
                stitchUpdater.setTranslateBefore(saveTran)
            }
        }
        
        if dragFrom == .after {
            let translate = isMid ? (stitchUpdater.translateAfter + g.translation(in: stackView)) : (g.translation(in: stackView) * -1)
            
            var index = index + 1
            var tran = isVer ? -translate.y : -translate.x
            var changes = [StitchItem: (CGRect, CGFloat)]()
            var saveTran = CGPoint.zero

            while index < editItems.count && abs(tran) > 0 {
                guard begin.indices.contains(index) else { break }
                
                let (item, rect) = begin[index]
                let editRect = rect * editItems[index].imageView.bounds.size
                let maxLength = isVer ? editItems[index].imageView.bounds.height : editItems[index].imageView.bounds.width
                
                if tran > 0 {
                    let reduce = min(tran, isVer ? editRect.height : editRect.width)
                    tran = tran - reduce
                    saveTran = saveTran + reduce
                    changes[item] = (rect, -reduce / maxLength)
                    index += 1
                } else {
                    let bonus = min(-tran, isVer ? editRect.minY : editRect.minX)
                    tran = tran + bonus
                    saveTran = saveTran - bonus
                    changes[item] = (rect, bonus / maxLength)
                    break
                }
            }
            
            changes.forEach { (item, info) in
                let (rect, change) = info
                
                item.process.setRect(CGRect(origin: rect.origin - CGPoint(x: isVer ? 0 : change, y: isVer ? change : 0), maxOrigin: rect.maxOrigin))
            }
            
            if (g.state == .ended || g.state == .cancelled) && isMid {
                stitchUpdater.setTranslateAfter(saveTran * -1)
            }
        }
    }
    
    private func beginDrag() {
        editUpdater?.anim = false
    }
    
    private func endDrag() {
        editUpdater?.anim = true
        
//        if let begin = beginNorFrameMids {
//            cEdit.setStitchFramesStep(oldFrames: begin.filter({ $0.rect.width >= MIN_REMOVE && $0.rect.height >= MIN_REMOVE }),
//                                      newFrames: cEdit.getItems().map({ ($0, $0.getProcess().rect) }).filter({ $0.rect.width >= MIN_REMOVE && $0.rect.height >= MIN_REMOVE }))
//        } else if let begin = beginNorFrameBefores {
//            cEdit.setStitchFramesStep(oldFrames: begin.filter({ $0.rect.width >= MIN_REMOVE && $0.rect.height >= MIN_REMOVE }),
//                                      newFrames: cEdit.getItems().map({ ($0, $0.getProcess().rect) }).filter({ $0.rect.width >= MIN_REMOVE && $0.rect.height >= MIN_REMOVE }))
//        } else if let begin = beginNorFrameAfters {
//            cEdit.setStitchFramesStep(oldFrames: begin.filter({ $0.rect.width >= MIN_REMOVE && $0.rect.height >= MIN_REMOVE }),
//                                      newFrames: cEdit.getItems().map({ ($0, $0.getProcess().rect) }).filter({ $0.rect.width >= MIN_REMOVE && $0.rect.height >= MIN_REMOVE }))
//        }
        
        beginNorFrameBefores = nil
        beginNorFrameAfters = nil
        beginNorFrameMids = nil
        dragFrom = .none
        
        UIView.animate(withDuration: ANIM_DURATION, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
            context?.coordinator.view?.layoutIfNeeded()
            
            if let editUpdater = editUpdater, let context = context {
                contentUpdate(editUpdater: editUpdater, context: context)
            }
        }
    }
}

fileprivate class EditStitchViews {
    let item: StitchItem
    let button: UIButtonPro
    let divider: UIView
    let gradientB: EditStitchGradient
    let gradientA: EditStitchGradient
    
    init(item: StitchItem, button: UIButtonPro, divider: UIView, gradientB: EditStitchGradient, gradientA: EditStitchGradient) {
        self.item = item
        self.button = button
        self.divider = divider
        self.gradientB = gradientB
        self.gradientA = gradientA
    }
    
    func remove() {
        for view in [divider, button, gradientB, gradientA] {
            view.removeFromSuperview()
        }
    }
    
    func show(_ bool: Bool) {
        for view in [divider, button] {
            view.alpha = bool ? 1 : 0
        }
    }
}

fileprivate class EditStitchArrow: UIView {
    private var didLoad = false
    
    private var offset: CGPoint = .zero
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        setupNotifications()
        startAnimation()
    }
        
    private func setupNotifications() {
        // Handle returning to app: animations usually stop when app is backgrounded
        NotificationCenter.default.addObserver(self, selector: #selector(startAnimation), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func startAnimation() {
        guard let imageView = subviews.first(type: UIImageView.self) else { return }
        
        // Remove existing animation before adding a new one
        imageView.layer.removeAnimation(forKey: "anim")
        
        // Reset position to identity to ensure we start from the origin
        imageView.transform = .identity
        
        let animation = CABasicAnimation(keyPath: "transform.translation")
        
        // Set the 'toValue' using the offset
        animation.toValue = CGSize(width: self.offset.x, height: self.offset.y)
        
        animation.duration = 0.6
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        
        // Crucial: prevents the animation from being removed when app enters background
        animation.isRemovedOnCompletion = false
        
        imageView.layer.add(animation, forKey: "anim")
    }
    
    @discardableResult
    func esetOffset(_ offset: CGPoint) -> Self {
        if offset == self.offset { return self }
        
        self.offset = offset
        
        startAnimation()
        
        return self
    }
}

fileprivate class EditStitchGradient: UIView {
    override final class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }
}
