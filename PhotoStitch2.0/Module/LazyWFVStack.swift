//
//  LazyWFVStack.swift
//  Sticker Maker
//
//  Created by TapUniverse Dev9 on 7/1/26.
//

import SwiftUI

struct LazyWFVItem<Content: View>: Equatable {
    let id: String
    let size: CGSize
    let content: () -> Content
    
    init(id: String = UUID().uuidString, size: CGSize, content: @escaping () -> Content) {
        self.id = id
        self.size = size
        self.content = content
    }
    
    static func == (lhs: LazyWFVItem, rhs: LazyWFVItem) -> Bool {
        lhs.id == rhs.id
    }
}

fileprivate struct LazyWFVRect<Content: View>: Hashable {
    let id: String
    let rect: CGRect
    let content: () -> Content
    
    init(id: String, rect: CGRect, content: @escaping () -> Content) {
        self.id = id
        self.rect = rect
        self.content = content
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(rect.minX)
        hasher.combine(rect.minY)
        hasher.combine(rect.width)
        hasher.combine(rect.height)
    }
    
    static func == (lhs: LazyWFVRect, rhs: LazyWFVRect) -> Bool {
        lhs.rect.minX == rhs.rect.minX && lhs.rect.minY == rhs.rect.minY && lhs.rect.width == rhs.rect.width && lhs.rect.height == rhs.rect.height
    }
}

struct LazyWFVStack<Content: View>: View {
    let geometry: GeometryProxy
    let items: [LazyWFVItem<Content>]
    let colWidth: CGFloat
    let columns: Int
    var spacing: CGFloat = 8
    var onHeightChange: ((CGFloat) -> Void)?
    
    var body: some View {
        let (list, columnHeights) = calculateList()
        
        ZStack(alignment: .topLeading) {
            GeometryReader { contentGeo in
                let global = geometry.frame(in: .local).insetBy(dx: -200, dy: -200)
                let local = contentGeo.frame(in: .global)
                
                let list = list.filter({ item in
                    let gRect = item.rect + local.origin
                    return global.intersects(gRect)
                })
                
                ForEach(list, id: \.id) { item in
                    ZStack {
                        item.content()
                    }
                    .frame(width: item.rect.width, height: item.rect.height)
                    .offset(x: item.rect.minX, y: item.rect.minY)
                }
            }
        }
        .frame(width: colWidth, height: columnHeights.max())
        .onAppear {
            if let height = columnHeights.max() {
                onHeightChange?(height)
            }
        }
        .onChange(columnHeights) { _ in
            if let height = columnHeights.max() {
                onHeightChange?(height)
            }
        }
    }
    
    private func calculateList() -> ([LazyWFVRect<Content>], [CGFloat]) {
        let cardWidth = (colWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        
        var columnHeights = [CGFloat](repeating: 0, count: columns)
        
        let list = items.map { item in
            // Find the shortest column
            let minHeight = columnHeights.min() ?? 0
            let index = columnHeights.firstIndex(of: minHeight) ?? 0
            
            let itemHeight = (cardWidth / item.size.width) * item.size.height
            let origin = CGPoint(x: CGFloat(index) * (cardWidth + spacing), y: minHeight)
            let size = CGSize(width: cardWidth, height: itemHeight)
            
            // Update the height of the column for the next item
            columnHeights[index] += itemHeight + spacing
            
            return LazyWFVRect(id: item.id, rect: CGRect(origin: origin, size: size), content: item.content)
        }
        
        return (list, columnHeights)
    }
}
