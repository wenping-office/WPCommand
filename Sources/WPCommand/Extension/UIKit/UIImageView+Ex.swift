//
//  UIImageView+Ex.swift
//  WPCommand
//
//  Created by Wen on 2024/1/12.
//

import UIKit

public extension WPSpace where Base: UIImageView{
    
    @discardableResult
    func image(_ image: UIImage?) -> Self {
        base.image = image
        return self
    }
    
    @discardableResult
    func highlightedImage(_ image:UIImage?) -> Self {
        base.highlightedImage = image
        return self
    }
    
    @discardableResult
    func animationImages(_ images:[UIImage]?) -> Self {
        base.animationImages = images
        return self
    }
    
    @discardableResult
    func highlightedAnimationImages(_ images:[UIImage]?) -> Self {
        base.highlightedAnimationImages = images
        return self
    }
    
    @discardableResult
    func animationDuration(_ timeInterval:TimeInterval) -> Self {
        base.animationDuration = timeInterval
        return self
    }
    
    @discardableResult
    func animationRepeatCount(_ count:Int) -> Self {
        base.animationRepeatCount = count
        return self
    }
    
    @discardableResult
    @available(iOS 17.0, *)
    func preferredImageDynamicRange(_ preferredImageDynamicRange:UIImage.DynamicRange) -> Self {
        base.preferredImageDynamicRange = preferredImageDynamicRange
        return self
    }
    
    @discardableResult
    @available(iOS 13.0, *)
    func preferredSymbolConfiguration(_ preferredSymbolConfiguration:UIImage.SymbolConfiguration?) -> Self {
        base.preferredSymbolConfiguration = preferredSymbolConfiguration
        return self
    }

}
