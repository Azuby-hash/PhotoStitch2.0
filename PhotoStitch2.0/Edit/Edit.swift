//
//  EditVC.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 5/7/26.
//

import SwiftUI
import Combine

struct Edit: View {
    @State var editUpdater = EditUpdater()
    
    let setItems: PassthroughSubject<[StitchItem], Never>
    
    var body: some View {
        ZStack {
            ScrollView {
                
            }
        }
        .background(Color._background)
        .onReceive(setItems) { items in
            editUpdater.items = items
            print(items)
        }
    }
}

@Observable class EditUpdater {
    var items: [StitchItem] = []
}
