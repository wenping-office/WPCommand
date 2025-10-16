//
//  UIView+Rx.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/10/16.
//

import UIKit
import RxCocoa
import RxSwift

private var wp_isDeleteAutoBackgroundsPointer = "wp_isDeleteAutoBackgroundsBag"
private var wp_isDeleteAutoRadiusPointer = "wp_isRemoveAutoRadiusBag"

fileprivate extension UIView {
    /// 是否删除背景色标记
    var wp_isRemoveAutoBackgroundsBag: DisposeBag {
        set {
            WPRunTime.set(self, newValue, withUnsafePointer(to: &wp_isDeleteAutoBackgroundsPointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let disposeBag: DisposeBag = WPRunTime.get(self, withUnsafePointer(to: &wp_isDeleteAutoBackgroundsPointer, {$0})) else {
                let bag = DisposeBag()
                self.wp_isRemoveAutoBackgroundsBag = bag
                return bag
            }
            return disposeBag
        }
    }
    
    /// 是否删除自动圆角
    var wp_isRemoveAutoRadiusBag: DisposeBag {
        set {
            WPRunTime.set(self, newValue, withUnsafePointer(to: &wp_isDeleteAutoRadiusPointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let disposeBag: DisposeBag = WPRunTime.get(self, withUnsafePointer(to: &wp_isDeleteAutoRadiusPointer, {$0})) else {
                let bag = DisposeBag()
                self.wp_isRemoveAutoRadiusBag = bag
                return bag
            }
            return disposeBag
        }
    }
}

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
    
    /// 选择性圆角
    /// - Parameters:
    ///   - corners: 圆角点
    ///   - radius: 圆角
    /// - Returns: 语法糖
    @discardableResult
    func autoRadius(_ corners: [UIRectCorner], radius: CGFloat) -> Self {
        weak var v = base
        _ = v?.wp.corner(corners, radius: radius)
        layoutSubViewsMethod.map({ _ in
            return base.frame.size
        }).distinctUntilChanged().bind(onNext: { _ in
            v?.wp.corner(corners, radius: radius)
        }).disposed(by: base.wp_isRemoveAutoRadiusBag)
        return self
    }
    
    /// 移除自动圆角
    @discardableResult
    func removeAutoRadius()->Self{
        base.wp_isRemoveAutoRadiusBag = DisposeBag()
        base.layer.mask = nil
        return self
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
    
    /// 背景渐变色
    /// - Parameters:
    ///   - point: 开始点
    ///   - colors: 结束点
    /// - Returns: 颜色
    @discardableResult
    func autoBackgroundColors(_ startPoint: CGPoint, _ endPoint: CGPoint,_ colors:[UIColor]) -> Self {
        weak var v = base
        v?.wp.backgroundColors(startPoint, endPoint, colors)
        layoutSubViewsMethod.map({
            return base.frame.size
        }).distinctUntilChanged().bind(onNext: { _ in
            v?.wp.backgroundColors(startPoint, endPoint, colors)
        }).disposed(by: base.wp_isRemoveAutoBackgroundsBag)
        return self
    }
    
    /// 移除渐变色背景 如果不准可以延迟再次执行
    @discardableResult
    func removeBackgroundColors() -> Self {
        base.wp_isRemoveAutoBackgroundsBag = DisposeBag()
        for layer in base.layer.sublayers ?? [] {
            if layer.isKind(of: CAGradientLayer.self) && layer.name == "WPGradientLayerTag" {
                layer.removeFromSuperlayer()
                break
            }
        }
        return self
    }
}
