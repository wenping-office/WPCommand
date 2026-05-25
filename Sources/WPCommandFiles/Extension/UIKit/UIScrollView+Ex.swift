//
//  UIScrollView+Ex.swift
//  WPCommand
//
//  Created by Wen on 2024/1/15.
//

import UIKit

public extension WPSpace where Base: UIScrollView {
    @discardableResult
    func contentOffset(_ point: CGPoint) -> Self {
        base.contentOffset = point
        return self
    }
    
    @discardableResult
    func contentSize(_ contentSize: CGSize) -> Self {
        base.contentSize = contentSize
        return self
    }
    
    @discardableResult
    func contentInset(_ contentInset: UIEdgeInsets) -> Self {
        base.contentInset = contentInset
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: UIScrollViewDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func isDirectionalLockEnabled(_ isDirectionalLockEnabled: Bool) -> Self {
        base.isDirectionalLockEnabled = isDirectionalLockEnabled
        return self
    }
    
    @discardableResult
    func bounces(_ bounces: Bool) -> Self {
        base.bounces = bounces
        return self
    }
    
    @discardableResult
    func alwaysBounceVertical(_ alwaysBounceVertical: Bool) -> Self {
        base.alwaysBounceVertical = true
        return self
    }
    
    @discardableResult
    func alwaysBounceHorizontal(_ alwaysBounceHorizontal: Bool) -> Self {
        base.alwaysBounceHorizontal = true
        return self
    }
    
    @discardableResult
    func isPagingEnabled(_ isPagingEnabled: Bool) -> Self {
        base.isPagingEnabled = isPagingEnabled
        return self
    }
    
    @discardableResult
    func isScrollEnabled(_ isScrollEnabled: Bool) -> Self {
        base.isScrollEnabled = isScrollEnabled
        return self
    }
    
    @discardableResult
    func showsVerticalScrollIndicator(_ showsVerticalScrollIndicator: Bool) -> Self {
        base.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        return self
    }
    
    @discardableResult
    func showsHorizontalScrollIndicator(_ showsHorizontalScrollIndicator: Bool) -> Self {
        base.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        return self
    }
    
    @discardableResult
    func indicatorStyle(_ indicatorStyle: UIScrollView.IndicatorStyle) -> Self {
        base.indicatorStyle = indicatorStyle
        return self
    }

    @discardableResult
    func scrollIndicatorInsets(_ scrollIndicatorInsets: UIEdgeInsets) -> Self {
        base.scrollIndicatorInsets = scrollIndicatorInsets
        return self
    }
    
    @discardableResult
    func decelerationRate(_ decelerationRate: UIScrollView.DecelerationRate) -> Self {
        base.decelerationRate = decelerationRate
        return self
    }
    
    @discardableResult
    func indexDisplayMode(_ indexDisplayMode: UIScrollView.IndexDisplayMode) -> Self {
        base.indexDisplayMode = indexDisplayMode
        return self
    }
    
    @discardableResult
    func delaysContentTouches(_ delaysContentTouches: Bool) -> Self {
        base.delaysContentTouches = delaysContentTouches
        return self
    }
    
    @discardableResult
    func canCancelContentTouches(_ canCancelContentTouches: Bool) -> Self {
        base.canCancelContentTouches = canCancelContentTouches
        return self
    }
    
    @discardableResult
    func minimumZoomScale(_ minimumZoomScale: CGFloat) -> Self {
        base.minimumZoomScale = minimumZoomScale
        return self
    }
    
    @discardableResult
    func maximumZoomScale(_ maximumZoomScale: CGFloat) -> Self {
        base.maximumZoomScale = maximumZoomScale
        return self
    }
    
    @discardableResult
    func bouncesZoom(_ bouncesZoom: Bool) -> Self {
        base.bouncesZoom = bouncesZoom
        return self
    }
    
    @discardableResult
    func scrollsToTop(_ scrollsToTop: Bool) -> Self {
        base.scrollsToTop = scrollsToTop
        return self
    }
    
    @discardableResult
    func keyboardDismissMode(_ keyboardDismissMode: UIScrollView.KeyboardDismissMode) -> Self {
        base.keyboardDismissMode = keyboardDismissMode
        return self
    }
    
    @discardableResult
    func refreshControl(_ refreshControl: UIRefreshControl?) -> Self {
        base.refreshControl = refreshControl
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func contentInsetAdjustmentBehavior(_ contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior) -> Self {
        base.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
        return self
    }
    
    @available(iOS 11.1, *)
    @discardableResult
    func verticalScrollIndicatorInsets(_ verticalScrollIndicatorInsets: UIEdgeInsets) -> Self {
        base.verticalScrollIndicatorInsets = verticalScrollIndicatorInsets
        return self
    }
    
    @available(iOS 11.1, *)
    @discardableResult
    func horizontalScrollIndicatorInsets(_ horizontalScrollIndicatorInsets: UIEdgeInsets) -> Self {
        base.horizontalScrollIndicatorInsets = horizontalScrollIndicatorInsets
        return self
    }
    
    @discardableResult
    func automaticallyAdjustsScrollIndicatorInsets(_ automaticallyAdjustsScrollIndicatorInsets: Bool) -> Self {
        base.automaticallyAdjustsScrollIndicatorInsets = automaticallyAdjustsScrollIndicatorInsets
        return self
    }
    
    @available(iOS 17.0, *)
    @discardableResult
    func allowsKeyboardScrolling(_ allowsKeyboardScrolling: Bool) -> Self {
        base.allowsKeyboardScrolling = allowsKeyboardScrolling
        return self
    }
}
