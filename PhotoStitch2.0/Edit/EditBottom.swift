//
//  EditBottom.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/30/26.
//

import SwiftUI

struct EditBottom: View {
    @Environment(EditUpdater.self) var editUpdater
    
    var body: some View {
        GlassContainer {
            if editUpdater.tab == .none {
                HStack {
                    Button {
                        editUpdater.tab = .stitch
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.arrowtriangle.2.inward")
                            Text("Edit")
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal, 20)
                        .frame(height: 60)
                        .modifier(MainGlass(shape: .capsule, type: .clear))
                    }
                    
                    Button {
                        editUpdater.tab = .sort
                    } label: {
                        HStack {
                            Image(systemName: "square.stack.3d.up.fill")
                            Text("Sort")
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal, 20)
                        .frame(height: 60)
                        .modifier(MainGlass(shape: .capsule, type: .clear))
                    }
                }
                .align(edge: .bottom, constant: 0)
            }
            
            if editUpdater.tab == .stitch {
                EditStitchTool()
            }
            
            if editUpdater.tab == .split {
                EditCutTool()
            }
        }
    }
}
