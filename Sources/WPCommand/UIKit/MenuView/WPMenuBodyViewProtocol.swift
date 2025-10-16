//
//  WPMenuBodyViewProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/18.
//

import UIKit

private var MenuBodyViewScrollHandlerPointer = "MenuBodyViewScrollHandlerPointer"


public protocol WPMenuBodyViewProtocol: WPMenuViewChildViewProtocol {
    /// 滚动处理
    typealias ScrollHandler = ((UIScrollView)->Void)?
    
    /// 需要展示的视图
    func menuBodyView() -> UIView?
    
    /// 需要适配垂直手势下拉的scrollView
    func menuBodyViewAdaptationScrollView() -> UIScrollView?
}

public extension WPMenuBodyViewProtocol{
    /// 需要适配垂直手势下拉的scrollView
    func menuBodyViewAdaptationScrollView() -> UIScrollView? { nil }
}

public extension WPMenuBodyViewProtocol{

    /// 滚动的视图解决手势冲突使用
    var targetViewDidScroll : ScrollHandler{
        get {
            return WPRunTime.get(self, withUnsafePointer(to: &MenuBodyViewScrollHandlerPointer, {$0}))
        }
        set {
            return WPRunTime.set(self, newValue, withUnsafePointer(to: &MenuBodyViewScrollHandlerPointer, {$0}), .OBJC_ASSOCIATION_COPY)
        }
    }
}


