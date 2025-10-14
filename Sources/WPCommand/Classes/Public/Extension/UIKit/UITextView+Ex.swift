//
//  UITextView+Ex.swift
//  WPCommand
//
//  Created by Wen on 2024/1/15.
//

import UIKit
import RxCocoa
import RxSwift

public extension WPSpace where Base: UITextView {
    @discardableResult
    func placeholder(_ placeholder:String?,
                     padding:UIEdgeInsets = .init(8, 0, 8, 0),
                     config:((UILabel)->Void)? = nil) -> Self {
        
        let tag = -1999888
        let placeView = base.subviews.wp_elmt { view in
            return view.tag == tag
        }
        placeView?.removeFromSuperview()
        if placeholder == nil {
            return self
        }
        let label = UILabel().wp.padding { labe in
            labe.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(5+padding.left)
                make.right.equalToSuperview().offset(-(padding.right+5)).priority(.high)
                make.top.equalToSuperview().offset(padding.top)
                make.bottom.equalToSuperview().offset(-padding.bottom)
            }
        }
        label.tag = tag
        label.target.text = placeholder
        label.target.numberOfLines = 0
        label.target.font = base.font
        label.target.textColor = .wp.initWith(198, 198, 198, 1)
        label.target.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.target.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.isUserInteractionEnabled = false

        base.addSubview(label)
        weak var wLabel = label.target
        config?(wLabel!)
        
        label.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.greaterThanOrEqualTo(base.font?.pointSize ?? 0 + padding.top)
        }
        base.rx.text.map { str in
            return !(str?.count ?? 0 <= 0)
        }.bind(to: label.rx.isHidden).disposed(by: label.wp.disposeBag)
        return self
    }
}

public extension WPSpace where Base: UITextView {
    
    @discardableResult
    func delegate(_ delegate:UITextViewDelegate?) -> Self {
        base.delegate = delegate
        return self
    }

    @discardableResult
    func text(_ text:String) -> Self {
        base.text = text
        return self
    }

    @discardableResult
    func font(_ font:UIFont?) -> Self {
        base.font = font
        return self
    }
    
    @discardableResult
    func textColor(_ textColor:UIColor?) -> Self {
        base.textColor = textColor
        return self
    }
    
    @discardableResult
    func textAlignment(_ textAlignment:NSTextAlignment) -> Self {
        base.textAlignment = textAlignment
        return self
    }
    
    @discardableResult
    func selectedRange(_ selectedRange:NSRange) -> Self {
        base.selectedRange = selectedRange
        return self
    }
    
    @discardableResult
    func isEditable(_ isEditable:Bool) -> Self {
        base.isEditable = isEditable
        return self
    }
    
    @discardableResult
    func isSelectable(_ isSelectable:Bool) -> Self {
        base.isSelectable = isSelectable
        return self
    }

    @discardableResult
    func dataDetectorTypes(_ dataDetectorTypes:UIDataDetectorTypes) -> Self {
        base.dataDetectorTypes = dataDetectorTypes
        return self
    }

    @discardableResult
    func allowsEditingTextAttributes(_ allowsEditingTextAttributes:Bool) -> Self {
        base.allowsEditingTextAttributes = allowsEditingTextAttributes
        return self
    }
    
    @discardableResult
    func attributedText(_ attributedText:NSAttributedString) -> Self {
        base.attributedText = attributedText
        return self
    }
    
    @discardableResult
    func typingAttributes(_ typingAttributes:[NSAttributedString.Key : Any]) -> Self {
        base.typingAttributes = typingAttributes
        return self
    }
    
    @discardableResult
    func scrollRangeToVisible(_ range:NSRange) -> Self {
        base.scrollRangeToVisible(range)
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
    func textContainerInset(_ textContainerInset:UIEdgeInsets) -> Self {
        base.textContainerInset = textContainerInset
        return self
    }
    
    @discardableResult
    func linkTextAttributes(_ linkTextAttributes:[NSAttributedString.Key : Any]) -> Self {
        base.linkTextAttributes = linkTextAttributes
        return self
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func usesStandardTextScaling(_ usesStandardTextScaling:Bool) -> Self {
        base.usesStandardTextScaling = usesStandardTextScaling
        return self
    }
    
    @available(iOS 16.0, *)
    @discardableResult
    func isFindInteractionEnabled(_ isFindInteractionEnabled:Bool) -> Self {
        base.isFindInteractionEnabled = isFindInteractionEnabled
        return self
    }
    
    @available(iOS 17.0, *)
    @discardableResult
    func borderStyle(_ borderStyle:UITextView.BorderStyle) -> Self {
        base.borderStyle = borderStyle
        return self
    }
}

/// UITextInput
public extension WPSpace where Base: UITextView {
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
