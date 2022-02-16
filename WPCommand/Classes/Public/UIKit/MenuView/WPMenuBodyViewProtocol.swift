//
//  WPMenuBodyViewProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/18.
//

import UIKit

private var MenuBodyViewScrollPointer = "MenuBodyViewScrollPointer"
private var MenuBodyViewScrollHandlerPointer = "MenuBodyViewScrollHandlerPointer"
private var MenuBodyViewWillBeginDraggingPointer = "MenuBodyViewWillBeginDraggingPointer"
private var MenuBodyViewWillEndDraggingPointer = "MenuBodyViewWillEndDraggingPointer"

public protocol WPMenuBodyViewProtocol: WPMenuViewChildViewProtocol {
    /// 滚动处理
    typealias ScrollHandler = ((UIScrollView)->Void)?
    /// 触碰屏幕
    typealias WillBeginDragging = ((UIScrollView)->Void)?
    /// 结束触碰屏幕
    typealias WillEndDragging = ((UIScrollView)->Void)?
    
    /// 需要展示的视图
    func menuBodyView() -> UIView?
}

public extension WPMenuBodyViewProtocol{
    
    /// 滚动的视图解决手势冲突使用
    var targetViewDidScroll : ScrollHandler{
        get {
            return WPRunTime.get(self, &MenuBodyViewScrollHandlerPointer)
        }
        set {
            return WPRunTime.set(self, newValue, &MenuBodyViewScrollHandlerPointer, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    /// 触碰屏幕
    var targetViewWillBeginDragging : ScrollHandler{
        get {
            return WPRunTime.get(self, &MenuBodyViewWillBeginDraggingPointer)
        }
        set {
            return WPRunTime.set(self, newValue, &MenuBodyViewWillBeginDraggingPointer, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    /// 离开触碰屏幕
    var targetViewWillEndDragging : ScrollHandler{
        get {
            return WPRunTime.get(self, &MenuBodyViewWillEndDraggingPointer)
        }
        set {
            return WPRunTime.set(self, newValue, &MenuBodyViewWillEndDraggingPointer, .OBJC_ASSOCIATION_COPY)
        }
    }
}


