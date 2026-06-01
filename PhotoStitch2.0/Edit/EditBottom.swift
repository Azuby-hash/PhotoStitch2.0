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
            HStack {
                if editUpdater.tab == .none {
                    HStack {
                        Button {
                            editUpdater.tab = .stitch
                        } label: {
                            HStack {
                                Image("rectangle.arrowtriangle.2.inward")
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
                                Image("square.stack.3d.up.fill")
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
                
                if editUpdater.tab == .stitch || editUpdater.tab == .split {
                    HStack {
                        Button {
                            editUpdater.tab = .none
                        } label: {
                            Image("checkmark")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(Color._whiteVert)
                                .frame(width: 60, height: 60)
                                .modifier(MainGlass(shape: .capsule, type: .color(._blackVert)))
                        }
                    }
                    .align(edge: .bottom, constant: 0)
                }
            }
            .align(edge: .bottom, constant: 0)
        }
    }
}
