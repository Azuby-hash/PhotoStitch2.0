//
//  UILabelColor.swift
//  VideoRemoveObject
//
//  Created by TapUniverse Dev9 on 21/4/25.
//


import UIKit

class UILabelHighlightColor: UILabel {
    /**
     Array is highlightStrings split by ","
     */
    @IBInspectable var highlightStrings: String = ""
    @IBInspectable var highlightColor: UIColor = .clear
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        procHighlightStrings()
    }
    /**
     Highlights specific strings in the label's text with a custom color while preserving
     the label's font, font size, line break mode, and number of lines
     
     - Parameters:
       - stringsToHighlight: Array of strings to highlight with the custom color
       - highlightColor: The color to apply to the specified strings
     */
    func procHighlightStrings() {
        guard let text = self.text, !text.isEmpty else { return }
        
        let stringsToHighlight = highlightStrings.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces) })
        
        // Store original attributes to preserve
        let originalFont = self.font
        let originalTextColor = self.textColor ?? .black
        let originalLineBreakMode = self.lineBreakMode
        let originalNumberOfLines = self.numberOfLines
        let originalTextAlignment = self.textAlignment
        
        // Create an attributed string with the label's current text
        let attributedString = NSMutableAttributedString(string: text)
        
        // Apply the base attributes to the entire string
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = originalLineBreakMode
        paragraphStyle.alignment = originalTextAlignment
        
        // Apply base attributes (font, color, paragraph style) to the entire text
        attributedString.addAttributes([
            .font: originalFont as Any,
            .foregroundColor: originalTextColor,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: attributedString.length))
        
        // Highlight each specified string
        for stringToHighlight in stringsToHighlight {
            // Find all occurrences of the string
            var searchRange = NSRange(location: 0, length: attributedString.length)
            
            while searchRange.location < attributedString.length {
                let range = (attributedString.string as NSString).range(of: stringToHighlight, options: [], range: searchRange)
                
                // Break if no more occurrences found
                if range.location == NSNotFound {
                    break
                }
                
                // Apply highlight color while preserving other attributes
                attributedString.addAttribute(.foregroundColor, value: highlightColor, range: range)
                
                // Update the search range for the next iteration
                searchRange.location = range.location + range.length
                searchRange.length = attributedString.length - searchRange.location
            }
        }
        
        // Apply the attributed text to the label
        self.attributedText = attributedString
        
        // Ensure the number of lines is preserved
        // (sometimes setting attributedText can reset this property)
        self.numberOfLines = originalNumberOfLines
    }
}
