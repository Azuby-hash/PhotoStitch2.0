//
//  EditTop.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/30/26.
//

import SwiftUI

struct EditTop: View {
    @Environment(HomeUpdater.self) var homeUpdater
    @Environment(EditUpdater.self) var editUpdater
    
    var body: some View {
        GlassContainer {
            HStack(spacing: 12) {
                Button {
                    homeUpdater.showEdit = false
                } label: {
                    Image("chevron.left")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .frame(width: 44, height: 44)
                        .modifier(MainGlass(shape: .capsule, type: .clear))
                }
                
                Spacer()
                
                HStack(spacing: 0) {
                    Button {
                        
                    } label: {
                        Image("arrow.uturn.backward")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Button {
                        
                    } label: {
                        Image("arrow.uturn.forward")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .frame(width: 44, height: 44)
                    }
                }
                .modifier(MainGlass(shape: .capsule, type: .clear))
                
                if editUpdater.tab == .sort {
                    let onSelectionMode = editUpdater.sortUpdater?.selectionMode == true
                    
                    Button {
                        editUpdater.sortUpdater?.selectionMode.toggle()
                    } label: {
                        Text(onSelectionMode ? "Done" : "Select")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(onSelectionMode ? Color._whiteVert : Color.primary)
                            .padding(.horizontal, 16)
                            .frame(height: 44)
                            .modifier(MainGlass(shape: .capsule, type: onSelectionMode ? .color(._blackVert) : .clear))
                    }
                } else {
                    Button {
                        
                    } label: {
                        Image("arrow.down.to.line")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white)
                            .frame(width: 44, height: 44)
                            .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .align(edge: .top, constant: 0)
        .animation(.smooth(duration: ANIM_DURATION), value: editUpdater.sortUpdater?.selectionMode)
    }
}
