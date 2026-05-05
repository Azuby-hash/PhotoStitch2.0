//
//  StringHelpers.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 29/1/26.
//

import UIKit
import SwiftUI

extension String {
    func highlight(_ text: String) -> AttributedString {
        var str = AttributedString(self)
            
        // Find the range of the word "Photo"
        if let range = str.range(of: text) {
            str[range].foregroundColor = .label
            str[range].font = .system(size: 15, weight: .bold, design: .rounded)
        }
        
        return str
    }
}
