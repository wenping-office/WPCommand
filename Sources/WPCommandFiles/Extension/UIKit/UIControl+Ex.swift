//
//  UIControl.swift
//  WPCommand
//
//  Created by Wen on 2024/1/12.
//

import UIKit

public extension WPSpace where Base: UIControl {
    
    @discardableResult
    func isEnabled(_ isEnabled: Bool) -> Self {
        base.isEnabled = isEnabled
        return self
    }
    
    @discardableResult
    func isSelected(_ isSelected: Bool) -> Self {
        base.isSelected = isSelected
        return self
    }
    
    @discardableResult
    func isHighlighted(_ isHighlighted: Bool) -> Self {
        base.isHighlighted = isHighlighted
        return self
    }
    
    @discardableResult
    func contentVerticalAlignment(_ contentVerticalAlignment: UIControl.ContentVerticalAlignment) -> Self {
        base.contentVerticalAlignment = contentVerticalAlignment
        return self
    }
    
    @discardableResult
    func contentHorizontalAlignment(_ contentHorizontalAlignment: UIControl.ContentHorizontalAlignment) -> Self {
        base.contentHorizontalAlignment = contentHorizontalAlignment
        return self
    }
    
    @discardableResult
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) -> Self {
        base.addTarget(target, action: action, for: controlEvents)
        return self
    }
    
    @discardableResult
    func sendActions(for controlEvents: UIControl.Event) -> Self {
        base.sendActions(for: controlEvents)
        return self
    }
    
    @available(iOS 14.0, *)
    @discardableResult
    func sendAction(_ action: UIAction) -> Self {
        base.sendAction(action)
        return self
    }
    
    @available(iOS 14.0, *)
    @discardableResult
    func addAction(_ action: UIAction,or controlEvents: UIControl.Event) -> Self {
        base.addAction(action, for: controlEvents)
        return self
    }
    
    @available(iOS 14.0, *)
    @discardableResult
    func isContextMenuInteractionEnabled(_ isContextMenuInteractionEnabled: Bool) -> Self {
        base.isContextMenuInteractionEnabled = isContextMenuInteractionEnabled
        return self
    }
    
    @available(iOS 14.0, *)
    @discardableResult
    func showsMenuAsPrimaryAction(_ showsMenuAsPrimaryAction: Bool) -> Self {
        base.showsMenuAsPrimaryAction = showsMenuAsPrimaryAction
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func toolTip(_ toolTip: String?) -> Self {
        base.toolTip = toolTip
        return self
    }
    
    @available(iOS 17.0, *)
    @discardableResult
    func isSymbolAnimationEnabled(_ isSymbolAnimationEnabled: Bool) -> Self {
        base.isSymbolAnimationEnabled = isSymbolAnimationEnabled
        return self
    }
}
