//
//  UISTextView.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

extension UITextView: UITextInputTraitsExtension {
    @discardableResult
    func edelegate(_ delegate: (any UITextViewDelegate)?) -> Self {
        self.delegate = delegate
        return self
    }
    
    @discardableResult
    func etext(_ text: String!) -> Self {
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
    func etextAlignment(_ textAlignment: NSTextAlignment) -> Self {
        self.textAlignment = textAlignment
        return self
    }
    
    @discardableResult
    func eselectedRange(_ selectedRange: NSRange) -> Self {
        self.selectedRange = selectedRange
        return self
    }
    
    @discardableResult
    func eisEditable(_ isEditable: Bool) -> Self {
        self.isEditable = isEditable
        return self
    }
    
    @discardableResult
    func eisSelectable(_ isSelectable: Bool) -> Self {
        self.isSelectable = isSelectable
        return self
    }
    
    @discardableResult
    func edataDetectorTypes(_ dataDetectorTypes: UIDataDetectorTypes) -> Self {
        self.dataDetectorTypes = dataDetectorTypes
        return self
    }
    
    @discardableResult
    func eallowsEditingTextAttributes(_ allowsEditingTextAttributes: Bool) -> Self {
        self.allowsEditingTextAttributes = allowsEditingTextAttributes
        return self
    }
    
    @discardableResult
    func eattributedText(_ attributedText: NSAttributedString!) -> Self {
        self.attributedText = attributedText
        return self
    }
    
    @discardableResult
    func etypingAttributes(_ typingAttributes: [NSAttributedString.Key : Any]) -> Self {
        self.typingAttributes = typingAttributes
        return self
    }
    
    @discardableResult
    func einputView(_ inputView: UIView?) -> Self {
        self.inputView = inputView
        return self
    }
    
    @discardableResult
    func einputAccessoryView(_ inputAccessoryView: UIView?) -> Self {
        self.inputAccessoryView = inputAccessoryView
        return self
    }
    
    @discardableResult
    func eclearsOnInsertion(_ clearsOnInsertion: Bool) -> Self {
        self.clearsOnInsertion = clearsOnInsertion
        return self
    }
    
    @discardableResult
    func etextContainerInset(_ textContainerInset: UIEdgeInsets) -> Self {
        self.textContainerInset = textContainerInset
        return self
    }
    
    @discardableResult
    func elinkTextAttributes(_ linkTextAttributes: [NSAttributedString.Key : Any]!) -> Self {
        self.linkTextAttributes = linkTextAttributes
        return self
    }
    
    @discardableResult
    func eusesStandardTextScaling(_ usesStandardTextScaling: Bool) -> Self {
        self.usesStandardTextScaling = usesStandardTextScaling
        return self
    }
    
    @discardableResult
    func eisFindInteractionEnabled(_ isFindInteractionEnabled: Bool) -> Self {
        self.isFindInteractionEnabled = isFindInteractionEnabled
        return self
    }
    
    @discardableResult
    func eborderStyle(_ borderStyle: UITextView.BorderStyle) -> Self {
        self.borderStyle = borderStyle
        return self
    }
    
    @available(iOS 18.0, *)
    @discardableResult
    func etextHighlightAttributes(_ textHighlightAttributes: [NSAttributedString.Key : Any]!) -> Self {
        self.textHighlightAttributes = textHighlightAttributes
        return self
    }
    
    @available(iOS 18.0, *)
    @discardableResult
    func ewritingToolsBehavior(_ writingToolsBehavior: UIWritingToolsBehavior) -> Self {
        self.writingToolsBehavior = writingToolsBehavior
        return self
    }
    
    @available(iOS 18.0, *)
    @discardableResult
    func eallowedWritingToolsResultOptions(_ allowedWritingToolsResultOptions: UIWritingToolsResultOptions) -> Self {
        self.allowedWritingToolsResultOptions = allowedWritingToolsResultOptions
        return self
    }
    
    @available(iOS 18.0, *)
    @discardableResult
    func etextFormattingConfiguration(_ textFormattingConfiguration: UITextFormattingViewController.Configuration?) -> Self {
        self.textFormattingConfiguration = textFormattingConfiguration
        return self
    }
    
    @discardableResult
    func einteractionState(_ interactionState: Any) -> Self {
        self.interactionState = interactionState
        return self
    }
    
    @discardableResult
    func escrollRangeToVisible(_ range: NSRange) -> Self {
        self.scrollRangeToVisible(range)
        return self
    }
    
    @available(iOS 18.0, *)
    @discardableResult
    func edrawTextHighlightBackground(for textRange: NSTextRange, origin: CGPoint) -> Self {
        self.drawTextHighlightBackground(for: textRange, origin: origin)
        return self
    }
}
