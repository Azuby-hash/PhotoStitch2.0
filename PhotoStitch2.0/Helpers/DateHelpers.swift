//
//  UIVisualOpacity.swift
//  AIArtGenerator
//
//  Created by Tap Dev5 on 14/10/2022.
//

import UIKit

extension Date {
    func relative() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.formattingContext = .beginningOfSentence
        formatter.dateTimeStyle = .named
        
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func get12Time() -> (hour: Int, minute: Int, meridiem: Int) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: .now)

        var hour = components.hour ?? 4
        let minute = components.minute ?? 30
        var meridiem = 0
        
        if hour == 12 {
            meridiem = 1
        }
        
        if hour == 24 || hour == 0 {
            hour = 12
            meridiem = 0
        }
        
        if hour > 12 {
            hour = hour - 12
            meridiem = 1
        }
        
        return (hour, minute, meridiem)
    }
}

extension DateComponents {
    init(hour: Int, minute: Int = 0, second: Int = 0, meridiem: Int) {
        var hour = hour
        
        if meridiem == 0 {
            hour = hour == 12 ? hour - 12 : hour
        }
        
        if meridiem == 1 {
            hour = hour == 12 ? hour : hour + 12
        }
        
        self = DateComponents(hour: hour, minute: minute, second: second)
    }
}
