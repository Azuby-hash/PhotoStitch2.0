//
//  Geometry.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 4/25/26.
//

import SwiftUI

@ViewBuilder
func Geometry<Content: View>(@ViewBuilder _ content: @escaping (GeometryProxy) -> Content) -> some View {
    GeometryReader { geometry in
        if geometry.size.width.isFinite && geometry.size.height.isFinite && geometry.size.width > 0 && geometry.size.height > 0 {
            content(geometry)
        }
    }
}
