//
//  EditContent.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 5/2/26.
//

import UIKit
import SwiftUI
import Combine

/**
 EditGallery
 - ScrollView
    - ScrollContent
        - StackView
        - EditContent
 - EditOverlay
 */
struct EditGallery: UIViewRepresentable {
    @Environment(EditUpdater.self) var editUpdater

    var edgeInsets: EdgeInsets {
        get { editUpdater.edgeInsets }
    }
    
    var baseInsets: EdgeInsets {
        get { editUpdater.baseInsets }
    }
    
    func makeUIView(context: Context) -> UIViewContent {
        let view = UIViewContent()
        let scrollView = ForwardScroll()
            .edelegate(context.coordinator)
            .emaximumZoomScale(MAX_ZOOM)
            .ebackgroundColor(.clear)
            .eclipsToBounds(false)
            .econtentInset(editUpdater.axis == .vertical ? edgeInsets.toUI() : baseInsets.toUI())
        let scrollContent = UIViewPointSubview()
        let stackView = UIStackView()
        let editContent = EditContent()
        let editOverlay = EditOverlay()
        
        view.eaddSubview(scrollView
                .eaddSubview(scrollContent
                    .eaddSubview(stackView, [.centerX(0, 900), .centerY(0, 900), .width(0, 900), .height(0, 900)])
                    .eaddSubview(editContent, [.centerX(0), .centerY(0)]),
                 [.leading(0), .trailing(0), .top(0), .bottom(0)]),
            [.leading(0), .trailing(0), .top(0), .bottom(0)])
            .eaddSubview(editOverlay, [.leading(0), .trailing(0), .top(0), .bottom(0)])
        
        context.coordinator.content = self
        context.coordinator.view = view
        context.coordinator.scrollView = scrollView
        context.coordinator.scrollContent = scrollContent
        context.coordinator.stackView = stackView
        context.coordinator.editContent = editContent
        context.coordinator.editOverlay = editOverlay
        
        editUpdater.editGallery.context = context
        
        view.content = self
        view.context = context
        
        editUpdater.animIfNeeded {
            view.layoutIfNeeded()
            
            context.coordinator.editContent?.setup(editUpdater: editUpdater, context: context)
            context.coordinator.editOverlay?.setup(editUpdater: editUpdater, context: context)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewContent, context: Context) {
        editUpdater.editGallery.context = context
        
        context.coordinator.stackView?.layer.shadowColor = ._blackVert
        context.coordinator.stackView?.layer.shadowOffset = .zero
        context.coordinator.stackView?.layer.shadowOpacity = 0.2
        context.coordinator.stackView?.layer.shadowRadius = 40
        
        context.coordinator.scrollView?.econtentInset(editUpdater.axis == .vertical ? edgeInsets.toUI() : baseInsets.toUI())
        
        uiView.content = self
        uiView.context = context

        editUpdater.animIfNeeded {
            if uiView.bounds.size.wxh() < 1 { return }
            
            uiView.layoutIfNeeded()
            
            context.coordinator.layoutUpdate()
            
            context.coordinator.editContent?.update(editUpdater: editUpdater, context: context)
            context.coordinator.editOverlay?.update(editUpdater: editUpdater, context: context)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var content: EditGallery?

        weak var view: UIView?
        weak var scrollView: ForwardScroll?
        weak var scrollContent: UIViewPointSubview?
        weak var stackView: UIStackView?
        
        weak var editContent: EditContent?
        weak var editOverlay: EditOverlay?
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollContent
        }
        
        func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            content?.editUpdater.editGallery.onZoom = true
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            content?.editUpdater.editGallery.onZoom = false
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            content?.editUpdater.editGallery.scrollViewUpdate.send()
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            content?.editUpdater.editGallery.scrollViewUpdate.send()
        }
        
        func layoutUpdate() {
            guard let scroll = scrollView,
                  let stack = stackView,
                  let editUpdater = content?.editUpdater
            else { return }
            
            scroll.delegate = nil
            defer {
                scroll.delegate = self
            }
            
            let newSegements = editUpdater.items
            let oldSegements = (stack.arrangedSubviews as? [EditItem])?.map({ $0.item }) ?? []
            
            UIView.animate(withDuration: ANIM_DURATION, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseInOut]) { [self] in

                oldSegements.transformArray(to: newSegements) { [self] segment, index in
                    let item = EditItem()

                    item.item = segment
                    item.editUpdater = editUpdater
                    
                    if let segment = segment {
                        item.setSize(calculateSize(for: segment))
                    }
                    
                    item.setContent()
                    stack.insertArrangedSubview(item, at: index)
                    stack.layoutIfNeeded()
                } remove: { index in
                    stack.arrangedSubviews[index].removeFromSuperview()
                } move: { (from, to) in
                    stack.insertArrangedSubview(stack.arrangedSubviews[from], at: to)
                }
                
                view?.layoutIfNeeded()
                
                stack.arrangedSubviews.enumerated().forEach { (index, view) in
                    guard editUpdater.items.indices.contains(index),
                          let view = view as? EditItem
                    else { return }
                    
                    let item = editUpdater.items[index]
                    
                    view.item = item
                    view.editUpdater = editUpdater
                    view.setSize(calculateSize(for: item))
                    view.setContent()
                    
                    if editUpdater.tab == .sort {
                        stack.setCustomSpacing(SPLIT_ITEM_SPACING, after: view)
                    } else {
                        stack.setCustomSpacing(0, after: view)
                    }
                }
                
                stack.axis = editUpdater.axis
                stack.layoutIfNeeded()
                
                view?.layoutIfNeeded()
                
                if editUpdater.tab == .sort {
                    scrollContent?.transform = .identity
                }
            }
        }
        
        private func calculateSize(for item: StitchItem) -> CGSize {
            guard let scroll = scrollView,
                  let content = content
            else { return .zero }
            
            let editUpdater = content.editUpdater
            
            let size = item.process.rect.size * item.size
            let bounds = scroll.bounds.size - CGSize(width: content.edgeInsets.leading + content.edgeInsets.trailing, height: content.edgeInsets.top + content.edgeInsets.bottom)
            
            if editUpdater.axis == .vertical {
                return size * (bounds.width / size.width)
            }
            
            if editUpdater.axis == .horizontal {
                return size * (bounds.height / size.height)
            }
            
            return bounds
        }
    }
    
    class UIViewContent: UIView {
        var content: EditGallery?
        var context: Context?
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            if bounds.size.wxh() < 1 { return }
            
            guard let editUpdater = content?.editUpdater,
                  let context = context
            else { return }
            
            editUpdater.animIfNeeded { [self] in
                layoutIfNeeded()
                
                context.coordinator.layoutUpdate()
                
                context.coordinator.editContent?.update(editUpdater: editUpdater, context: context)
                context.coordinator.editOverlay?.update(editUpdater: editUpdater, context: context)
            }
        }
    }
}

@Observable class EditGalleryModel {
    @ObservationIgnored var context: EditGallery.Context?
    @ObservationIgnored var onZoom = false
    
    let scrollViewUpdate = PassthroughSubject<Void, Never>()
}

extension StitchItem: Hashable {
    static func == (lhs: StitchItem, rhs: StitchItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class EditItem: UIView {
    weak var item: StitchItem?
    weak var editUpdater: EditUpdater?
    
    private var data: Data?
    
    let imageView = UIImageView().econtentMode(.scaleAspectFill)
    
    func setSize(_ size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        clipsToBounds = true
        
        eselfConstraints([.width(size.width), .height(size.height)])
        layoutIfNeeded()
    }
    
    func setContent() {
        guard let item = item,
              let editUpdater = editUpdater
        else { return }
        
        let data = editUpdater.clean ? item.image : item.clean
        
        if data != self.data {
            self.data = data
            
            imageView.image = UIImage(data: data)
        }
                
        var imageSize: CGSize
        
        let exportSize = item.process.rect * item.size
        
        if editUpdater.axis == .horizontal {
            let scale = bounds.size.height / exportSize.height
            imageSize = item.size * scale
        } else {
            let scale = bounds.size.width / exportSize.width
            imageSize = item.size * scale
        }
        
        let imagePosi = item.process.rect.origin * imageSize * -1
        
        imageView.eselfConstraints([.width(imageSize.width), .height(imageSize.height)])
        eaddSubview(imageView, [.leading(imagePosi.x), .top(imagePosi.y)])
        layoutIfNeeded()
    }
}

extension EdgeInsets {
    func toUI() -> UIEdgeInsets {
        UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
    }
    
    static func + (lhs: EdgeInsets, rhs: EdgeInsets) -> EdgeInsets {
        EdgeInsets(top: lhs.top + rhs.top, leading: lhs.leading + rhs.leading, bottom: lhs.bottom + rhs.bottom, trailing: lhs.trailing + rhs.trailing)
    }
    
    static func - (lhs: EdgeInsets, rhs: EdgeInsets) -> EdgeInsets {
        EdgeInsets(top: lhs.top - rhs.top, leading: lhs.leading - rhs.leading, bottom: lhs.bottom - rhs.bottom, trailing: lhs.trailing - rhs.trailing)
    }
}
