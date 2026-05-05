//
//  UISTextInputTraitsExtension.swift
//  StitchPhotos2.0
//
//  Created by TapUniverse Dev9 on 12/3/26.
//

import UIKit

protocol UITextInputTraitsExtension : NSObjectProtocol {
    var autocapitalizationType: UITextAutocapitalizationType { get set }
    var autocorrectionType: UITextAutocorrectionType { get set }
    var spellCheckingType: UITextSpellCheckingType { get set }
    var smartQuotesType: UITextSmartQuotesType { get set }
    var smartDashesType: UITextSmartDashesType { get set }
    var smartInsertDeleteType: UITextSmartInsertDeleteType { get set }

    @available(iOS 17.0, *)
    var inlinePredictionType: UITextInlinePredictionType { get set }

    @available(iOS 18.0, *)
    var mathExpressionCompletionType: UITextMathExpressionCompletionType { get set }

    var keyboardType: UIKeyboardType { get set }
    var keyboardAppearance: UIKeyboardAppearance { get set }
    var returnKeyType: UIReturnKeyType { get set }
    var enablesReturnKeyAutomatically: Bool { get set }
    var isSecureTextEntry: Bool { get set }
    var textContentType: UITextContentType! { get set }
    var passwordRules: UITextInputPasswordRules? { get set }

    @available(iOS 18.0, *)
    var writingToolsBehavior: UIWritingToolsBehavior { get set }

    @available(iOS 18.0, *)
    var allowedWritingToolsResultOptions: UIWritingToolsResultOptions { get set }

    @available(iOS 18.4, *)
    var conversationContext: UIConversationContext? { get set }

    @available(iOS 26.0, *)
    var allowsNumberPadPopover: Bool { get set }
}

extension UITextInputTraitsExtension {
    @discardableResult
    func eautocapitalizationType(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
        self.autocapitalizationType = autocapitalizationType
        return self
    }
    
    @discardableResult
    func eautocorrectionType(_ autocorrectionType: UITextAutocorrectionType) -> Self {
        self.autocorrectionType = autocorrectionType
        return self
    }
    
    @discardableResult
    func espellCheckingType(_ spellCheckingType: UITextSpellCheckingType) -> Self {
        self.spellCheckingType = spellCheckingType
        return self
    }
    
    @discardableResult
    func esmartQuotesType(_ smartQuotesType: UITextSmartQuotesType) -> Self {
        self.smartQuotesType = smartQuotesType
        return self
    }
    
    @discardableResult
    func esmartDashesType(_ smartDashesType: UITextSmartDashesType) -> Self {
        self.smartDashesType = smartDashesType
        return self
    }
    
    @discardableResult
    func esmartInsertDeleteType(_ smartInsertDeleteType: UITextSmartInsertDeleteType) -> Self {
        self.smartInsertDeleteType = smartInsertDeleteType
        return self
    }
    
    
    @available(iOS 17.0, *)
    @discardableResult
    func einlinePredictionType(_ inlinePredictionType: UITextInlinePredictionType) -> Self {
        self.inlinePredictionType = inlinePredictionType
        return self
    }
    

    @available(iOS 18.0, *)
    @discardableResult
    func emathExpressionCompletionType(_ mathExpressionCompletionType: UITextMathExpressionCompletionType) -> Self {
        self.mathExpressionCompletionType = mathExpressionCompletionType
        return self
    }
    
    @discardableResult
    func ekeyboardType(_ keyboardType: UIKeyboardType) -> Self {
        self.keyboardType = keyboardType
        return self
    }
    
    @discardableResult
    func ekeyboardAppearance(_ keyboardAppearance: UIKeyboardAppearance) -> Self {
        self.keyboardAppearance = keyboardAppearance
        return self
    }
    
    @discardableResult
    func ereturnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        self.returnKeyType = returnKeyType
        return self
    }
    
    @discardableResult
    func eenablesReturnKeyAutomatically(_ enablesReturnKeyAutomatically: Bool) -> Self {
        self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        return self
    }
    
    @discardableResult
    func eisSecureTextEntry(_ isSecureTextEntry: Bool) -> Self {
        self.isSecureTextEntry = isSecureTextEntry
        return self
    }
    
    @discardableResult
    func etextContentType(_ textContentType: UITextContentType!) -> Self {
        self.textContentType = textContentType
        return self
    }
    
    @discardableResult
    func epasswordRules(_ passwordRules: UITextInputPasswordRules?) -> Self {
        self.passwordRules = passwordRules
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

    @available(iOS 18.4, *)
    @discardableResult
    func econversationContext(_ conversationContext: UIConversationContext?) -> Self {
        self.conversationContext = conversationContext
        return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func eallowsNumberPadPopover(_ allowsNumberPadPopover: Bool) -> Self {
        self.allowsNumberPadPopover = allowsNumberPadPopover
        return self
    }
}
