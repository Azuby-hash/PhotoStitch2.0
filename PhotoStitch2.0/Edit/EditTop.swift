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
        HStack(spacing: 12) {
            Button {
                homeUpdater.showEdit = false
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .frame(width: 44, height: 44)
                    .modifier(MainGlass(shape: .capsule, type: .clear))
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                Button {
                    
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .frame(width: 44, height: 44)
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .frame(width: 44, height: 44)
                }
            }
            .modifier(MainGlass(shape: .capsule, type: .clear))
            
            Button {
                
            } label: {
                Image(systemName: "arrow.down.to.line")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .frame(width: 44, height: 44)
                    .modifier(MainGlass(shape: .capsule, type: .color(._primary)))
            }
        }
        .padding(.horizontal, 16)
        .align(edge: .top, constant: 0)
    }
}
