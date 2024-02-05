//
//  UIButton+Ex.swift
//  WPCommand
//
//  Created by Wen on 2024/1/12.
//

import UIKit

public extension WPSpace where Base: UIButton {

    @discardableResult
    func font(_ font:UIFont) -> Self {
        base.titleLabel?.font = font
        return self
    }

    @discardableResult
    func title(_ title: String?, _ state: UIControl.State = .normal) -> Self {
        base.setTitle(title, for: state)
        return self
    }
    
    @discardableResult
    func attTitle(_ title: NSAttributedString?,_ state:UIControl.State = .normal) -> Self {
        base.setAttributedTitle(title, for: state)
        return self
    }

    @discardableResult
    func titleColor(_ color: UIColor?, _ state: UIControl.State = .normal) -> Self {
        base.setTitleColor(color, for: state)
        return self
    }

    @discardableResult
    func titleShadowColor(_ color: UIColor?, _ state: UIControl.State = .normal) -> Self {
        base.setTitleShadowColor(color, for: state)
        return self
    }

    @discardableResult
    func image(_ image: UIImage?, _ state: UIControl.State = .normal) -> Self {
        base.setImage(image, for: state)
        return self
    }

    @discardableResult
    func backgroundImage(_ image: UIImage?, _ state: UIControl.State = .normal) -> Self {
        base.setBackgroundImage(image, for: state)
        return self
    }

    @available(iOS 14.0, *)
    @discardableResult
    func role(_ role: UIButton.Role) -> Self {
        base.role = role
        return self
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func preferredSymbolConfiguration(_ preferredSymbolConfiguration:UIImage.SymbolConfiguration?,_ state: UIControl.State) -> Self {
        base.setPreferredSymbolConfiguration(preferredSymbolConfiguration, forImageIn: state)
        return self
    }
    
    
    @available(iOS, introduced: 2.0, deprecated: 15.0, message: "This property is ignored when using UIButtonConfiguration")
    @discardableResult
    func contentEdgeInsets(_ contentEdgeInsets:UIEdgeInsets) -> Self {
        base.contentEdgeInsets = contentEdgeInsets
        return self
    }
    
    @available(iOS, introduced: 2.0, deprecated: 15.0, message: "This property is ignored when using UIButtonConfiguration")
    @discardableResult
    func titleEdgeInsets(_ titleEdgeInsets:UIEdgeInsets) -> Self {
        base.titleEdgeInsets = titleEdgeInsets
        return self
    }
 
    @available(iOS, introduced: 2.0, deprecated: 15.0, message: "This property is ignored when using UIButtonConfiguration")
    @discardableResult
    func imageEdgeInsets(_ imageEdgeInsets:UIEdgeInsets) -> Self {
        base.imageEdgeInsets = imageEdgeInsets
        return self
    }
}
