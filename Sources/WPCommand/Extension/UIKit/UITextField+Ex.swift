//
//  UITextField+Ex.swift
//  WPCommand
//
//  Created by Wen on 2024/1/15.
//

import UIKit

public extension WPSpace where Base: UITextField {
    
    @discardableResult
    func text(_ text:String?) -> Self {
        base.text = text
        return self
    }
    
    @discardableResult
    func attributedText(_ text:NSAttributedString?) -> Self {
        base.attributedText = text
        return self
    }
    
    @discardableResult
    func textColor(_ textColor:UIColor?) -> Self{
        base.textColor = textColor
        return self
    }
    
    @discardableResult
    func font(_ font:UIFont?) -> Self {
        base.font = font
        return self
    }
    
    @discardableResult
    func textAlignment(_ textAlignment:NSTextAlignment) -> Self {
        base.textAlignment = textAlignment
        return self
    }
    
    @discardableResult
    func borderStyle(_ borderStyle:UITextField.BorderStyle) -> Self {
        base.borderStyle = borderStyle
        return self
    }
    
    @discardableResult
    func defaultTextAttributes(_ defaultTextAttributes:[NSAttributedString.Key : Any]) -> Self {
        base.defaultTextAttributes = defaultTextAttributes
        return self
    }
    
    @discardableResult
    func placeholder(_ placeholder:String?) -> Self {
        base.placeholder = placeholder
        return self
    }
    
    @discardableResult
    func attributedPlaceholder(_ attributedPlaceholder:NSAttributedString?) -> Self {
        base.attributedPlaceholder = attributedPlaceholder
        return self
    }
    
    @discardableResult
    func clearsOnBeginEditing(_ clearsOnBeginEditing:Bool) -> Self {
        base.clearsOnBeginEditing = clearsOnBeginEditing
        return self
    }
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth:Bool) -> Self {
        base.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return self
    }
    
    @discardableResult
    func delegate(_ delegate:UITextFieldDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func background(_ background:UIImage?) -> Self {
        base.background = background
        return self
    }
    
    @discardableResult
    func disabledBackground(_ disabledBackground:UIImage?) -> Self {
        base.disabledBackground = disabledBackground
        return self
    }
    
    @discardableResult
    func allowsEditingTextAttributes(_ allowsEditingTextAttributes:Bool) -> Self {
        base.allowsEditingTextAttributes = allowsEditingTextAttributes
        return self
    }
    
    @discardableResult
    func typingAttributes(_ typingAttributes:[NSAttributedString.Key : Any]?) -> Self {
        base.typingAttributes = typingAttributes
        return self
    }
    
    @discardableResult
    func clearButtonMode(_ clearButtonMode:UITextField.ViewMode) -> Self {
        base.clearButtonMode = clearButtonMode
        return self
    }
    
    @discardableResult
    func leftView(_ leftView:UIView?) -> Self {
        base.leftView = leftView
        return self
    }
    
    @discardableResult
    func leftViewMode(_ leftViewMode:UITextField.ViewMode) -> Self {
        base.leftViewMode = leftViewMode
        return self
    }

    @discardableResult
    func rightView(_ rightView:UIView?) -> Self {
        base.rightView = rightView
        return self
    }
    
    @discardableResult
    func rightViewMode(_ rightViewMode:UITextField.ViewMode) -> Self {
        base.rightViewMode = rightViewMode
        return self
    }
    
    @discardableResult
    func inputView(_ inputView:UIView?) -> Self {
        base.inputView = inputView
        return self
    }

    @discardableResult
    func inputAccessoryView(_ inputAccessoryView:UIView?) -> Self {
        base.inputAccessoryView = inputAccessoryView
        return self
    }

    @discardableResult
    func clearsOnInsertion(_ clearsOnInsertion:Bool) -> Self {
        base.clearsOnInsertion = clearsOnInsertion
        return self
    }
}

/// UITextInput
public extension WPSpace where Base: UITextField {
    @discardableResult
    func autocapitalizationType(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
        base.autocapitalizationType = autocapitalizationType
        return self
    }
    
    @discardableResult
    func autocorrectionType(_ autocorrectionType: UITextAutocorrectionType) -> Self {
        base.autocorrectionType = autocorrectionType
        return self
    }
    
    @discardableResult
    func spellCheckingType(_ spellCheckingType: UITextSpellCheckingType) -> Self {
        base.spellCheckingType = spellCheckingType
        return self
    }
    
    @discardableResult
    func smartQuotesType(_ smartQuotesType: UITextSmartQuotesType) -> Self {
        base.smartQuotesType = smartQuotesType
        return self
    }
    
    @discardableResult
    func smartDashesType(_ smartDashesType: UITextSmartDashesType) -> Self {
        base.smartDashesType = smartDashesType
        return self
    }
    
    @discardableResult
    func smartInsertDeleteType(_ smartInsertDeleteType: UITextSmartInsertDeleteType) -> Self {
        base.smartInsertDeleteType = smartInsertDeleteType
        return self
    }
    
    @available(iOS 17.0, *)
    @discardableResult
    func inlinePredictionType(_ inlinePredictionType: UITextInlinePredictionType) -> Self {
        base.inlinePredictionType = inlinePredictionType
        return self
    }
    
    @discardableResult
    func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        base.keyboardType = keyboardType
        return self
    }
    
    @discardableResult
    func keyboardAppearance(_ keyboardAppearance: UIKeyboardAppearance) -> Self {
        base.keyboardAppearance = keyboardAppearance
        return self
    }
    
    @discardableResult
    func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        base.returnKeyType = returnKeyType
        return self
    }
    
    @discardableResult
    func enablesReturnKeyAutomatically(_ enablesReturnKeyAutomatically: Bool) -> Self {
        base.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        return self
    }
    
    @discardableResult
    func isSecureTextEntry(_ isSecureTextEntry: Bool) -> Self {
        base.isSecureTextEntry = isSecureTextEntry
        return self
    }
    
    @discardableResult
    func textContentType(_ textContentType: UITextContentType) -> Self {
        base.textContentType = textContentType
        return self
    }
    
    @available(iOS 12.0, *)
    @discardableResult
    func passwordRules(_ passwordRules: UITextInputPasswordRules?) -> Self {
        base.passwordRules = passwordRules
        return self
    }
}
