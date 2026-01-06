//
//  UIView+Rx.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/10/16.
//

import UIKit
import RxCocoa
import RxSwift

public extension WPSpace where Base: UIView {
    /// 点击手势
    var tapGesture: ControlEvent<UITapGestureRecognizer> {
        let ges = UITapGestureRecognizer()
        base.addGestureRecognizer(ges)
        base.isUserInteractionEnabled = true
        return ges.rx.event
    }
}

public extension WPSpace where Base: UIView {
    
    /// 布局方法调用后
    var layoutSubViewsMethod: ControlEvent<Void> {
        let source = base.rx.methodInvoked(#selector(Base.layoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }
    
    /// 毛玻璃效果
    /// - Parameters:
    ///   - style: 样式
    ///   - isInset: 是否插入到底层
    /// - Returns: 结果
    @discardableResult
    func blurEffect(_ style:UIBlurEffect.Style = .light,isInset:Bool = true) -> Self {
        let view = base.subviews.wp.elementFirst(where: { $0.isKind(of: UIVisualEffectView.self)})
        if view != nil{
            return self
        }
        func create()->UIVisualEffectView{
            let blurEffect = UIBlurEffect(style: style)
            let blurEffectView = UIVisualEffectView(frame: base.bounds)
            blurEffectView.effect = blurEffect
            return blurEffectView
        }
        
        let blurEffectView = create()
        if isInset{
            base.insertSubview(blurEffectView, at: 0)
        }else{
            base.addSubview(blurEffectView)
        }
        blurEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return self
    }
}
