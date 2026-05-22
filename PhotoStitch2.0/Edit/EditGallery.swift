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

    let geometry: GeometryProxy
    let edgeInsets: EdgeInsets
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
            .eselfConstraints([.width(geometry.size.width), .height(geometry.size.height)])
        let scrollView = ForwardScroll()
            .edelegate(context.coordinator)
            .emaximumZoomScale(MAX_ZOOM)
            .ebackgroundColor(.clear)
            .eclipsToBounds(false)
        let scrollContent = UIViewPointSubview()
        let stackView = UIStackView()
        let editContent = EditContent()
        let editOverlay = EditOverlay()
        
        view.eaddSubview(scrollView
                .eaddSubview(scrollContent
                    .eaddSubview(stackView, [.centerX(0), .centerY(0)])
                    .eaddSubview(editContent, [.centerX(0), .centerY(0)]),
                [.leading(0), .trailing(0), .top(0), .bottom(0)]),
            [.leading(edgeInsets.leading), .trailing(edgeInsets.trailing),.top(edgeInsets.top), .bottom(edgeInsets.bottom)])
            .eaddSubview(editOverlay, [.leading(0), .trailing(0), .top(0), .bottom(0)])
        
        context.coordinator.content = self
        context.coordinator.view = view
        context.coordinator.scrollView = scrollView
        context.coordinator.scrollContent = scrollContent
        context.coordinator.stackView = stackView
        context.coordinator.editContent = editContent
        context.coordinator.editOverlay = editOverlay
        
        editUpdater.editGallery.context = context
        
        view.layoutIfNeeded()
        
        context.coordinator.editContent?.setup(editUpdater: editUpdater, context: context)
        context.coordinator.editOverlay?.setup(editUpdater: editUpdater, context: context)
        
        context.coordinator.layoutUpdate()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        editUpdater.editGallery.context = context

        uiView.layoutIfNeeded()
        
        context.coordinator.editContent?.update(editUpdater: editUpdater, context: context)
        context.coordinator.editOverlay?.update(editUpdater: editUpdater, context: context)
        
        context.coordinator.layoutUpdate()
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
        
        var items: [StitchItem] = []
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollContent
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
            
            let spacingZeroIndex = content?.editUpdater.editGallery.spaceZeroIndex
            
            scroll.delegate = nil
            defer {
                scroll.delegate = self
            }
            
            let newSegements = editUpdater.items
            let oldSegements = items
            
            UIView.animate(withDuration: ANIM_DURATION, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseInOut]) { [self] in

                oldSegements.transformArray(to: newSegements) { [self] segment, index in
                    let item = EditItem()

                    item.item = segment
                    item.editUpdater = editUpdater
                    item.setSize(calculateSize(for: segment))
                    item.setContent()
                    stack.insertArrangedSubview(item, at: index)
                    stack.layoutIfNeeded()
                    
                    items.insert(segment, at: index)
                } remove: { [self] index in
                    stack.arrangedSubviews[index].removeFromSuperview()
                    
                    items.remove(at: index)
                } move: { [self] (from, to) in
                    stack.insertArrangedSubview(stack.arrangedSubviews[from], at: to)
                    
                    let item = items.remove(at: from)
                    items.insert(item, at: to)
                }
                
                view?.layoutIfNeeded()
                
                stack.arrangedSubviews.enumerated().forEach { (index, view) in
                    guard editUpdater.items.indices.contains(index),
                          let view = view as? EditItem
                    else { return }
                    
                    let item = editUpdater.items[index]
                    
                    view.alpha = 1
                    view.item = item
                    view.editUpdater = editUpdater
                    view.setSize(calculateSize(for: item))
                    view.setContent()
                    
                    if editUpdater.tab == .stitch {
                        stack.setCustomSpacing(0, after: view)
                    }
                    
                    if editUpdater.tab == .split || editUpdater.tab == .sort {
                        stack.setCustomSpacing(spacingZeroIndex == index ? 0 : SPLIT_ITEM_SPACING, after: view)
                    }
                }

                stack.axis = editUpdater.axis
                stack.layoutIfNeeded()
                
                view?.layoutIfNeeded()
                
//                if cEdit.getTab() != .control && cStitch.getStitchEdge() == .none {
                    scrollContent?.eselfConstraints([.width(stack.bounds.width), .height(stack.bounds.height)])
//                }
                
                view?.layoutIfNeeded()
                
                if editUpdater.tab == .sort {
                    scrollContent?.transform = .identity
                }
            }
        }
        
        private func calculateSize(for item: StitchItem) -> CGSize {
            guard let scroll = scrollView,
                  let editUpdater = content?.editUpdater
            else { return .zero }
            
            let size = item.process.rect.size * item.size
            
            if editUpdater.axis == .vertical {
                return size * (scroll.bounds.width / size.width)
            }
            
            if editUpdater.axis == .horizontal {
                return size * (scroll.bounds.height / size.height)
            }
            
            return scroll.bounds.size
        }
    }
}

@Observable class EditGalleryModel {
    @ObservationIgnored weak var editUpdater: EditUpdater?
    @ObservationIgnored var context: EditGallery.Context?
    
    let scrollViewUpdate = PassthroughSubject<Void, Never>()
    var spaceZeroIndex: Int?
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
    
    private let imageView = UIImageView().econtentMode(.scaleAspectFill)
    
    func setSize(_ size: CGSize) {
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
