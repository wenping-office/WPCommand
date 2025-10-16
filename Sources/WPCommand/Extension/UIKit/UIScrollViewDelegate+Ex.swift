//
//  UIScrollView+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/18.
//

import UIKit

private var WPScrollViewDelegatePointer = "WPScrollViewSourcePointer"

public extension UIScrollView {
//    /// 代理
//    @objc var wp_delegate : WPScrollViewDelegate{
//        set{
//            WPRunTime.set(self, newValue, &WPScrollViewDelegatePointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            delegate = newValue
//        }
//        get{
//            guard let wp_delegate : WPScrollViewDelegate = WPRunTime.get(self, &WPScrollViewDelegatePointer) else {
//                let wp_delegate = WPScrollViewDelegate()
//                self.wp_delegate = wp_delegate
//                return wp_delegate
//            }
//            return wp_delegate
//        }
//    }
}

open class WPScrollViewDelegate: NSObject {
    /// 正在滚动
    public var didScroll: (UIScrollView)->Void = { _ in }
    /// 正在缩放
    public var didZoom: (UIScrollView)->Void = { _ in }
    /// 当开始滚动视图时，执行该方法。一次有效滑动（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动
    public var willBeginDragging: (UIScrollView)->Void = { _ in }
    /// 滑动scrollView，并且手指离开时执行。一次有效滑动，只执行一次。当pagingEnabled属性为YES时，不调用，该方法
    public var willEndDragging: (UIScrollView,
                                 CGPoint,
                                 UnsafeMutablePointer<CGPoint>)->Void = { _, _, _ in }
    /// 滑动视图，当手指离开屏幕那一霎那，调用该方法。一次有效滑动，只执行一次。
    /// decelerate,指代，当我们手指离开那一瞬后，视图是否还将继续向前滚动
    public var didEndDragging: (UIScrollView,
                                Bool)->Void = { _, _ in }
    /// 滑动减速时调用该方法
    public var willBeginDecelerating: (UIScrollView)->Void = { _ in }
    /// 滚动视图减速完成，滚动将停止时，调用该方法。一次有效滑动，只执行一次。
    public var didEndDecelerating: (UIScrollView)->Void = { _ in }
    /// 当滚动视图动画完成后，调用该方法，如果没有动画，那么该方法将不被调用
    public var didEndScrollingAnimation: (UIScrollView)->Void = { _ in }
    /// 返回将要缩放的UIView对象。要执行多次
    public var viewForZooming: (UIScrollView)->UIView? = { _ in nil }
    /// 当将要开始缩放时，执行该方法。一次有效缩放，就只执行一次。
    public var willBeginZooming: (UIScrollView,
                                  UIView?)->Void = { _, _ in }
    /// 当缩放结束后，并且缩放大小回到minimumZoomScale与maximumZoomScale之间后（我们也许会超出缩放范围），调用该方法。
    public var didEndZooming: (UIScrollView,
                               UIView?,
                               CGFloat)->Void = { _, _, _ in }
    /// 指示当用户点击状态栏后，滚动视图是否能够滚动到顶部。需要设置滚动视图的属性：_scrollView.scrollsToTop=YES
    public var shouldScrollToTop: (UIScrollView)->Bool = { _ in false }
    /// 当滚动视图滚动到最顶端后，执行该方法
    public var didScrollToTop: (UIScrollView)->Void = { _ in }
    ///
    public var didChangeAdjustedContentInset: (UIScrollView)->Void = { _ in }
}

extension WPScrollViewDelegate: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        didZoom(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        willBeginDragging(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        willEndDragging(scrollView, velocity, targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didEndDragging(scrollView, decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        willBeginDecelerating(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndDecelerating(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        didEndScrollingAnimation(scrollView)
    }
    
    public func viewForZooming(in scrollView: UIScrollView)->UIView? {
        return viewForZooming(scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        willBeginZooming(scrollView, view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        didEndZooming(scrollView, view, scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView)->Bool {
        return shouldScrollToTop(scrollView)
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        didScrollToTop(scrollView)
    }
    
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        didChangeAdjustedContentInset(scrollView)
    }
}
