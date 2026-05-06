//
//  Onboarding.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/6/26.
//

import SwiftUI

struct Onboarding: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color(uiColor: .label))
                    .frame(width: 44, height: 44)
                    .modifier(MainGlass(shape: .capsule, type: .clear))
            }
            .align(edge: .trailing, constant: 0)
            .padding(.horizontal, 16)
            .align(edge: .top, constant: 0)
        }
    }
}
