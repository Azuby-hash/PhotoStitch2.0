//
//  UISLabel.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

extension UILabel {
    @discardableResult
    func etext(_ text: String?) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    func efont(_ font: UIFont?) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult
    func etextColor(_ textColor: UIColor?) -> Self {
        self.textColor = textColor
        return self
    }
    
    @discardableResult
    func epreferredVibrancy(_ preferredVibrancy: UILabelVibrancy) -> Self {
        self.preferredVibrancy = preferredVibrancy
        return self
    }
    
    @discardableResult
    func eshadowColor(_ shadowColor: UIColor?) -> Self {
        self.shadowColor = shadowColor
        return self
    }
    
    @discardableResult
    func eshadowOffset(_ shadowOffset: CGSize) -> Self {
        self.shadowOffset = shadowOffset
        return self
    }
    
    @discardableResult
    func etextAlignment(_ textAlignment: NSTextAlignment) -> Self {
        self.textAlignment = textAlignment
        return self
    }
    
    @discardableResult
    func elineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
        self.lineBreakMode = lineBreakMode
        return self
    }
    
    @discardableResult
    func eattributedText(_ attributedText: NSAttributedString?) -> Self {
        self.attributedText = attributedText
        return self
    }
    
    @discardableResult
    func ehighlightedTextColor(_ highlightedTextColor: UIColor?) -> Self {
        self.highlightedTextColor = highlightedTextColor
        return self
    }
    
    @discardableResult
    func eisHighlighted(_ isHighlighted: Bool) -> Self {
        self.isHighlighted = isHighlighted
        return self
    }
    
    @discardableResult
    func eisEnabled(_ isEnabled: Bool) -> Self {
        self.isEnabled = isEnabled
        return self
    }
    
    @discardableResult
    func enumberOfLines(_ numberOfLines: Int) -> Self {
        self.numberOfLines = numberOfLines
        return self
    }
    
    @discardableResult
    func eadjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> Self {
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return self
    }
    
    @discardableResult
    func ebaselineAdjustment(_ baselineAdjustment: UIBaselineAdjustment) -> Self {
        self.baselineAdjustment = baselineAdjustment
        return self
    }
    
    @discardableResult
    func eminimumScaleFactor(_ minimumScaleFactor: CGFloat) -> Self {
        self.minimumScaleFactor = minimumScaleFactor
        return self
    }
    
    @discardableResult
    func eallowsDefaultTighteningForTruncation(_ allowsDefaultTighteningForTruncation: Bool) -> Self {
        self.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
        return self
    }
    
    @discardableResult
    func elineBreakStrategy(_ lineBreakStrategy: NSParagraphStyle.LineBreakStrategy) -> Self {
        self.lineBreakStrategy = lineBreakStrategy
        return self
    }
    
    @discardableResult
    func epreferredMaxLayoutWidth(_ preferredMaxLayoutWidth: CGFloat) -> Self {
        self.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        return self
    }
    
    @discardableResult
    func eshowsExpansionTextWhenTruncated(_ showsExpansionTextWhenTruncated: Bool) -> Self {
        self.showsExpansionTextWhenTruncated = showsExpansionTextWhenTruncated
        return self
    }

    @discardableResult
    func edrawText(in rect: CGRect) -> Self {
        self.drawText(in: rect)
        return self
    }
}
