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

private let BUTTON_SIZE: CGFloat = 44

class EditSortControl: UIViewPointSubview {
    private(set) weak var editUpdater: EditUpdater?
    private(set) var context: EditGallery.Context?
    
    private var scrollViewUpdate: AnyCancellable?
    
    private var attachs = [EditSortAttach]()
    
    private let iconConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 16, weight: .semibold))
    
    private var beginPoint: CGPoint?
    private var beginDrag: UIView?
    private var beginFrame: CGRect?
    private var beginCenters: [CGPoint]?
    private var beginGesture: UILongPressGestureRecognizer?
    private var beginEditItem: EditItem?
    private var beginItems: [StitchItem]?
    private var timer: Timer?
    
    private var isEnable = false
    
    func setup(editUpdater: EditUpdater, context: EditGallery.Context) {
        self.editUpdater = editUpdater
        self.context = context
        
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
        
        alpha = editUpdater.tab == .sort ? 1 : 0
    }

    private func contentUpdate(editUpdater: EditUpdater, context: EditGallery.Context) {
        guard let stackView = context.coordinator.stackView,
              let items = stackView.arrangedSubviews as? [EditItem], !items.isEmpty,
              let scrollView = context.coordinator.scrollView
        else {
            print("No Items")
            return
        }
        
        let enable = editUpdater.tab == .sort
        let isVer = editUpdater.axis == .vertical
        
        if isEnable != enable {
            isEnable = enable
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(dragItem))
            longPress.minimumPressDuration = 0.5
            longPress.allowableMovement = .infinity
            
            stackView.gestureRecognizers = enable ? [longPress] : []
            scrollView.maximumZoomScale = enable ? 1 : MAX_ZOOM
        }
        
        if enable {
            scrollView.setZoomScale(1, animated: true)
        }
        
        let oldAttachItems = attachs.map { $0.item }

        oldAttachItems.transformArray(to: editUpdater.items) { [self] item, index in
            let frame = itemFrame(from: item, context: context)
            attachs.insert(makeAttach(item: item, isVer: isVer, frame: frame), at: index)
        } remove: { [self] index in
            removeAttach(at: index)
        } move: { [self] (from, to) in
            attachs.insert(removeAttach(at: from), at: to)
        }
        
        attachs.forEach { attach in
            let frame = itemFrame(from: attach.item, context: context)
            attach.button.frame = buttonFrame(isVer: isVer, frame: frame)
            
            var name = "arrow.trianglehead.2.counterclockwise.rotate.90"
            if editUpdater.sortUpdater?.selectionMode == true {
                name = editUpdater.sortUpdater?.selectItems.contains(attach.item) == true ? "checkmark.circle.fill" : "circle"
            }
            
            attach.button.setImage(UIImage(named: name, in: .main, with: iconConfiguration), for: .normal)
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
    
    private func makeAttach(item: StitchItem, isVer: Bool, frame: CGRect) -> EditSortAttach {
        if let view = attachs.first(where: { $0.item == item }) {
            return view
        }
        
        let button = UIButtonPro(frame: buttonFrame(isVer: isVer, frame: frame))
            .setContentColor(._blackVert)
            .econfiguration({ configuration in
                var configuration = configuration
                configuration?.cornerStyle = .capsule
                return configuration
            })
            .etranslatesAutoresizingMaskIntoConstraints(true)
            .eaddTarget(self, action: #selector(tapAction), for: .touchUpInside)
        let attach = EditSortAttach(item: item, button: button)
        
        addSubview(button)
        
        return attach
    }
    
    @discardableResult
    private func removeAttach(at index: Int) -> EditSortAttach {
        let view = attachs.remove(at: index)
        view.remove()
        
        return view
    }
    
    private func buttonFrame(isVer: Bool, frame: CGRect) -> CGRect {
        return isVer ? CGRect(x: frame.maxX - BUTTON_SIZE / 2, y: frame.minY - BUTTON_SIZE / 2, width: BUTTON_SIZE, height: BUTTON_SIZE) : CGRect(x: frame.minX - BUTTON_SIZE / 2, y: frame.maxY - BUTTON_SIZE / 2, width: BUTTON_SIZE, height: BUTTON_SIZE)
    }
    
    @objc private func tapAction(button: UIButton) {
        guard let sortUpdater = editUpdater?.sortUpdater,
              let item = attachs.first(where: { $0.button == button })?.item
        else { return }
        
        if sortUpdater.selectionMode == true {
            if sortUpdater.selectItems.contains(item) {
                sortUpdater.selectItems.removeAll(where: { $0 == item })
            } else {
                sortUpdater.selectItems.append(item)
            }
        } else {
            sortUpdater.photoPosition = .replace(item: item)
            sortUpdater.showPhotoPicker = true
        }
    }
    
    @objc private func dragItem(g: UILongPressGestureRecognizer) {
        guard let stackView = context?.coordinator.stackView else { return }

        let point = g.location(in: self)
        let isVer = editUpdater?.axis == .vertical
        
        if g.state == .began {
            guard let item = stackView.arrangedSubviews.first(where: { $0.frame.contains(g.location(in: stackView)) }) as? EditItem,
                  let snap = item.snapshotView(afterScreenUpdates: true)
            else { return }
            
            beginPoint = point
            beginFrame = stackView.convert(item.frame, to: self)
            beginDrag = snap
            beginCenters = stackView.arrangedSubviews.map({ $0.center })
            beginGesture = g
            beginItems = editUpdater?.items

            beginEditItem = item
            
            addTimer()
            
            eaddSubview(snap
                .elayerModifier({ layer in
                    layer.shadowColor = ._blackVert
                    layer.shadowOffset = .zero
                    layer.shadowOpacity = 0.2
                    layer.shadowRadius = 40
                })
                .eaddSubview(UIView()
                .etranslatesAutoresizingMaskIntoConstraints(true)
                .eisUserInteractionEnabled(false), [.leading(0), .bottom(0), .top(0), .trailing(0)]))
            
            snap.frame = stackView.convert(item.frame, to: self)
            item.alpha = 0
            
            UIView.performWithoutAnimation {
                snap.layoutIfNeeded()
            }
            
            if let editUpdater = editUpdater, let context = context {
                contentUpdate(editUpdater: editUpdater, context: context)
            }
            
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction) {
                snap.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        }
        
        if g.state == .changed {
            guard let snap = beginDrag,
                  let beginPoint = beginPoint,
                  let beginFrame = beginFrame,
                  let beginItem = beginEditItem?.item,
                  let editUpdater = editUpdater
            else { return }
            
            let offset = isVer ? (point.y - beginPoint.y) : (point.x - beginPoint.x)
            let frame = beginFrame + CGPoint(x: isVer ? 0 : offset, y: isVer ? offset : 0)
            let frameInStack = convert(frame, to: stackView)
            
            snap.transform = CGAffineTransform(scaleX: 1.1, y: 1.1).concatenating(.init(translationX: isVer ? 0 : offset, y: isVer ? offset : 0))
            
            if let nearestCenter = beginCenters?.min(by: {
                $0.length(to: frameInStack.mid) < $1.length(to: frameInStack.mid)
            }), let index = beginCenters?.firstIndex(of: nearestCenter),
                let currIndex = editUpdater.items.firstIndex(of: beginItem),
                currIndex != index
            {
                editUpdater.items.insert(editUpdater.items.remove(at: currIndex), at: index)
            }
        }
        
        if [.ended, .cancelled].contains(g.state) {
            defer {
                if let oldItems = beginItems {
                    let newItems = editUpdater?.items
//                    cEdit.addStep(oldItems: oldItems, newItems: newItems)
                }
                
                beginPoint = nil
                beginFrame = nil
                beginDrag = nil
                beginCenters = nil
                beginGesture = nil
                beginItems = nil
                beginEditItem = nil
                
                removeTimer()
                
                if let editUpdater = editUpdater, let context = context {
                    contentUpdate(editUpdater: editUpdater, context: context)
                }
            }
            
            guard let snap = beginDrag,
                  let beginItem = beginEditItem
            else { return }
            
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut]) {
                snap.transform = .identity
                snap.frame = stackView.convert(beginItem.frame, to: self)
                snap.subviews.first?.alpha = 0
            } completion: { _ in
                beginItem.alpha = 1
                snap.removeFromSuperview()
            }
        }
    }
    
    private func addTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(scrollViewOffset), userInfo: nil, repeats: true)
    }
    
    private func removeTimer() {
        timer?.invalidate()
        
        timer = nil
    }

    @objc private func scrollViewOffset() {
        guard let snap = beginDrag,
              let scrollView = context?.coordinator.scrollView,
              let gesture = beginGesture,
              let startPoint = beginPoint
        else { return }
        
        // 1. Lấy vị trí ngón tay hiện tại so với chính nó (EditSort) để xác định hướng kéo
        let currentPoint = gesture.location(in: self)
        let isVer = editUpdater?.axis == .vertical
        
        // 2. Chuyển frame của snap sang hệ tọa độ của ScrollView để check va chạm biên
        // Lưu ý: Dùng snap.superview để convert chính xác nhất
        let snapFrameInScroll = snap.superview?.convert(snap.frame, to: scrollView) ?? .zero
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        
        var bonus = CGPoint.zero
        let step: CGFloat = 20 // Khoảng cách cuộn mỗi nhịp timer
        let padding: CGFloat = 10 // Vùng đệm sát mép

        if isVer {
            // Kéo xuống và snap chạm mép dưới
            if currentPoint.y > startPoint.y && snapFrameInScroll.maxY > visibleRect.maxY - padding {
                bonus.y = step
            }
            // Kéo lên và snap chạm mép trên
            else if currentPoint.y < startPoint.y && snapFrameInScroll.minY < visibleRect.minY + padding {
                bonus.y = -step
            }
        } else {
            // Kéo sang phải
            if currentPoint.x > startPoint.x && snapFrameInScroll.maxX > visibleRect.maxX - padding {
                bonus.x = step
            }
            // Kéo sang trái
            else if currentPoint.x < startPoint.x && snapFrameInScroll.minX < visibleRect.minX + padding {
                bonus.x = -step
            }
        }

        if bonus != .zero {
            let currentOffset = scrollView.contentOffset
            var newOffset = CGPoint(x: currentOffset.x + bonus.x, y: currentOffset.y + bonus.y)
            
            // Kiểm tra giới hạn contentSize để không cuộn ra ngoài vùng đen
            let maxOffY = scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
            let minOffY = -scrollView.contentInset.top
            newOffset.y = max(minOffY, min(maxOffY, newOffset.y))
            
            let maxOffX = scrollView.contentSize.width - scrollView.bounds.width + scrollView.contentInset.right
            let minOffX = -scrollView.contentInset.left
            newOffset.x = max(minOffX, min(maxOffX, newOffset.x))

            if newOffset != currentOffset {
                // Dùng animated: true với thời gian timer ngắn sẽ tạo hiệu ứng trượt mượt
                scrollView.setContentOffset(newOffset, animated: false)
            }
        }
    }
}

fileprivate class EditSortAttach {
    let item: StitchItem
    let button: UIButtonPro
    
    init(item: StitchItem, button: UIButtonPro) {
        self.item = item
        self.button = button
    }
    
    func remove() {
        for view in [button] {
            view.removeFromSuperview()
        }
    }
}
