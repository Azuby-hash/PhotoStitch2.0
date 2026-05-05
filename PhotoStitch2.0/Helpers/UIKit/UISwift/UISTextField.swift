//
//  UISTextField.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

extension UITextField: UITextInputTraitsExtension {
    @discardableResult
    func etext(_ text: String?) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    func eattributedText(_ attributedText: NSAttributedString?) -> Self {
        self.attributedText = attributedText
        return self
    }
    
    @discardableResult
    func etextColor(_ textColor: UIColor?) -> Self {
        self.textColor = textColor
        return self
    }
    
    @discardableResult
    func efont(_ font: UIFont?) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult
    func etextAlignment(_ textAlignment: NSTextAlignment) -> Self {
        self.textAlignment = textAlignment
        return self
    }
    
    @discardableResult
    func eborderStyle(_ borderStyle: UITextField.BorderStyle) -> Self {
        self.borderStyle = borderStyle
        return self
    }
    
    @discardableResult
    func edefaultTextAttributes(_ defaultTextAttributes: [NSAttributedString.Key : Any]) -> Self {
        self.defaultTextAttributes = defaultTextAttributes
        return self
    }
    
    @discardableResult
    func eplaceholder(_ placeholder: String?) -> Self {
        self.placeholder = placeholder
        return self
    }
    
    @discardableResult
    func eattributedPlaceholder(_ attributedPlaceholder: NSAttributedString?) -> Self {
        self.attributedPlaceholder = attributedPlaceholder
        return self
    }
    
    @discardableResult
    func eclearsOnBeginEditing(_ clearsOnBeginEditing: Bool) -> Self {
        self.clearsOnBeginEditing = clearsOnBeginEditing
        return self
    }
    
    @discardableResult
    func eadjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> Self {
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return self
    }
    
    @discardableResult
    func eminimumFontSize(_ minimumFontSize: CGFloat) -> Self {
        self.minimumFontSize = minimumFontSize
        return self
    }
    
    @discardableResult
    func edelegate(_ delegate: (any UITextFieldDelegate)?) -> Self {
        self.delegate = delegate
        return self
    }
    
    @discardableResult
    func ebackground(_ background: UIImage?) -> Self {
        self.background = background
        return self
    }
    
    @discardableResult
    func edisabledBackground(_ disabledBackground: UIImage?) -> Self {
        self.disabledBackground = disabledBackground
        return self
    }
    
    @discardableResult
    func eallowsEditingTextAttributes(_ allowsEditingTextAttributes: Bool) -> Self {
        self.allowsEditingTextAttributes = allowsEditingTextAttributes
        return self
    }
    
    @discardableResult
    func etypingAttributes(_ typingAttributes: [NSAttributedString.Key : Any]?) -> Self {
        self.typingAttributes = typingAttributes
        return self
    }
    
    @discardableResult
    func eclearButtonMode(_ clearButtonMode: UITextField.ViewMode) -> Self {
        self.clearButtonMode = clearButtonMode
        return self
    }
    
    @discardableResult
    func eleftView(_ leftView: UIView?) -> Self {
        self.leftView = leftView
        return self
    }
    
    @discardableResult
    func eleftViewMode(_ leftViewMode: UITextField.ViewMode) -> Self {
        self.leftViewMode = leftViewMode
        return self
    }
    
    @discardableResult
    func erightView(_ rightView: UIView?) -> Self {
        self.rightView = rightView
        return self
    }
    
    @discardableResult
    func erightViewMode(_ rightViewMode: UITextField.ViewMode) -> Self {
        self.rightViewMode = rightViewMode
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
    func edrawPlaceholder(in rect: CGRect) -> Self {
        self.drawPlaceholder(in: rect)
        return self
    }
}
