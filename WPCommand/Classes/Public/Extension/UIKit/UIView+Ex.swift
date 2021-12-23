//
//  UIImageView.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import RxCocoa
import UIKit

public extension WPSpace where Base: UIView {
    /// 从xib加载
    static func initWithXibName(xib: String) -> Any? {
        guard let nibs = Bundle.main.loadNibNamed(xib, owner: nil, options: nil) else {
            return nil
        }
        return nibs[0]
    }
}

public extension WPSpace where Base: UIView {
    /// 在keyWindow中的位置
    var frameInWidow: CGRect {
        return base.convert(bounds, to: UIApplication.shared.keyWindow)
    }
    
    /// 将当前视图转为UIImage
    var image: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            base.layer.render(in: rendererContext.cgContext)
        }
    }
    
    var x: CGFloat {
        get { return base.frame.origin.x }
        set { base.frame.origin.x = newValue }
    }
    
    var y: CGFloat {
        get { return base.frame.origin.y }
        set { base.frame.origin.y = newValue }
    }
    
    var width: CGFloat {
        get { return base.frame.size.width }
        set { base.frame.size.width = newValue }
    }
    
    var height: CGFloat {
        get { return base.frame.size.height }
        set { base.frame.size.height = newValue }
    }
    
    var maxX: CGFloat {
        get { return x + width }
        set { x = newValue - width }
    }
    
    var maxY: CGFloat {
        get { return y + height }
        set { y = newValue - height }
    }
    
    var centerX: CGFloat {
        get { return base.center.x }
        set { base.center.x = newValue }
    }
    
    var centerY: CGFloat {
        get { return base.center.y }
        set { base.center.y = newValue }
    }
    
    var midX: CGFloat {
        return width * 0.5
    }
    
    var wp_midY: CGFloat {
        return height * 0.5
    }
    
    var size: CGSize {
        get { return base.frame.size }
        set { base.frame.size = newValue }
    }
    
    var orgin: CGPoint {
        get { return base.frame.origin }
        set { base.frame.origin = newValue }
    }
    
    var bounds: CGRect {
        get { return base.bounds }
        set { base.bounds = newValue }
    }
    
    /// 是否有添加约束
    var isAddConstraints: Bool {
        return base.constraints.count > 0
    }
    
    /// 父类视图所有节点
    /// - Returns:
    func nodeViews(_ option:(UIView)->Bool) -> [UIView]{
        let view = base as UIView
        var notes = Array<Any>.wp_recursion(view, topPath: \.superview, path: \.subviews, option: option)
        notes.wp_repeat(retain: .fist, path: \.wp.memoryAddress)
        return notes
    }
}

public extension WPSpace where Base: UIView {
    /// 平面旋转
    /// - Parameter angle: 角度
    func rotation2D(angle: CGFloat) {
        base.transform = CGAffineTransform(rotationAngle: angle)
    }
    
    @discardableResult
    /// 自身约束
    func equalLayout(_ attribute: NSLayoutConstraint.Attribute,
                     constant: CGFloat) -> NSLayoutConstraint
    {
        let layout = NSLayoutConstraint(item: self,
                                        attribute: attribute,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 0.0,
                                        constant: constant)
        base.addConstraint(layout)
        return layout
    }
    
    /// 选择性圆角处理，需要设置frame后调用，如果是约束需要layout后调用才能生效
    /// - Parameters:
    ///   - corners: 原角点
    ///   - radius: 圆角弧度
    ///   - force: 是否强制 true的话在自身宽高都等于0的时候会调用一次layoutIfNeed
    func corner(_ corners: [UIRectCorner], radius: CGFloat, force: Bool = false) {
        if corners.count <= 0 { return }
        
        if force, bounds.size == .zero {
            base.layoutIfNeeded()
        }
        
        let maskPath = UIBezierPath.wp.corner(corners, radius: radius, in: bounds)
        
        var maskLayer = base.layer.mask
        if base.layer.mask == nil {
            maskLayer = CAShapeLayer()
        }
        maskLayer!.frame = bounds
        (maskLayer as? CAShapeLayer)?.path = maskPath.cgPath
        base.layer.mask = maskLayer
    }
    
    /// 设置边框
    func boardLine(color: UIColor, top: Bool, right: Bool, bottom: Bool, left: Bool, width: CGFloat) {
        let nameKey = "setBoardLine"
        base.layer.sublayers?.forEach { if $0.name == nameKey { $0.removeFromSuperlayer() } }
        
        let boolList = [top, right, bottom, left]
        let rectList = [CGRect(x: 0, y: 0, width: self.width, height: self.width),
                        CGRect(x: self.width - width, y: 0, width: width, height: self.height),
                        CGRect(x: 0, y: self.height - width, width: self.self.width, height: self.width),
                        CGRect(x: 0, y: 0, width: width, height: self.height)]
        
        for (idx, bo) in boolList.enumerated() {
            if bo {
                let layer = CALayer()
                layer.name = nameKey
                layer.frame = rectList[idx]
                layer.backgroundColor = color.cgColor
                base.layer.addSublayer(layer)
            }
        }
    }
    
    /// 设置渐变背景色，需在设置frame或约束后调用
    @discardableResult
    func layerColors(_ startPoint: CGPoint, _ endPoint: CGPoint, _ colors: [CGColor]) -> CAGradientLayer {
        let layer = CAGradientLayer()
        let sKey = "c-p-p"
        layer.name = sKey
        layer.frame = bounds
        layer.colors = colors
        layer.endPoint = endPoint
        layer.startPoint = startPoint
        layer.cornerRadius = base.layer.cornerRadius
        for oldLayer in base.layer.sublayers ?? [] {
            if oldLayer.name == sKey {
                base.layer.replaceSublayer(oldLayer, with: layer)
                return layer
            }
        }
        base.layer.insertSublayer(layer, at: 0)
        return layer
    }
    
    /// 子视图随机色
    func subViewRandomColor() {
        base.subviews.forEach { subView in
            subView.backgroundColor = UIColor.wp.random
            base.backgroundColor = UIColor.wp.random
        }
    }
    
    /// 移除所有子视图
    func removeAllSubViewFromSuperview() {
        base.subviews.forEach { elmt in
            elmt.removeFromSuperview()
        }
    }
    
    /// 绘制虚线
    /// - Parameters:
    ///   - strokeColor: 颜色
    ///   - lineWidth: 线宽
    ///   - lineLength: 长度
    ///   - lineSpacing: 虚线间隔
    ///   - isBottom: 是否是底部
    func drawDashLine(strokeColor: UIColor,
                      lineWidth: CGFloat = 1,
                      lineLength: Int = 10,
                      lineSpacing: Int = 5,
                      isBottom: Bool = true)
    {
        base.layer.sublayers?.forEach({ elmt in
            (elmt as? WPDashLineLayer)?.removeFromSuperlayer()
        })
        
        let shapeLayer = WPDashLineLayer()
        shapeLayer.bounds = self.bounds
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        
        // 每一段虚线长度 和 每两段虚线之间的间隔
        shapeLayer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]
        
        let path = CGMutablePath()
        let y = isBottom == true ? base.layer.bounds.height - lineWidth : 0
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: base.layer.bounds.width, y: y))
        shapeLayer.path = path
        base.layer.addSublayer(shapeLayer)
    }
    
    /// 显示占位视图
    /// - Parameters:
    ///   - offSetY: 偏移量
    ///   - config: 配置项
    func showPlaceholder(offSetY: CGFloat = 0,
                         config: @escaping (WPPlaceholderView) -> Void)
    {
        WPGCD.main_Async {
            let tag = 10086
            var contetnView: UIView?
            // 先查询是否有占位视图
            base.subviews.forEach { elmt in
                if elmt.tag == tag {
                    contetnView = elmt
                }
            }
            if contetnView == nil {
                contetnView = UIView()
            }
            
            contetnView?.tag = tag
            base.addSubview(contetnView!)
            
            contetnView?.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            let placeholderView = WPPlaceholderView()
            config(placeholderView)
            contetnView?.addSubview(placeholderView)
            placeholderView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(offSetY)
            }
        }
    }
    
    /// 移除占位视图
    func removePlaceholder() {
        WPGCD.main_Async {
            let tag = 10086
            let contentView = base.subviews.wp_elmt(of: { elmt in
                elmt.tag == tag
            })
            contentView?.removeFromSuperview()
        }
    }
    
    /// 显示加载小菊花
    /// - Parameter show: 是否显示
    func loading(is show: Bool, offSetY: CGFloat = 0) {
        WPGCD.main_Async {
            let tag = 10087
            let resualt = base.subviews.wp_isContent { elmt in
                elmt.tag == tag
            }
            if show, !resualt {
                let lodingView = UIActivityIndicatorView()
                lodingView.tag = tag
                lodingView.startAnimating()
                base.addSubview(lodingView)
                lodingView.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview().offset(offSetY)
                    make.width.height.equalTo(20)
                }
                
            } else if !show, resualt {
                let subLoding = base.subviews.wp_elmt { elmt in
                    elmt.tag == tag
                }
                subLoding?.removeFromSuperview()
            }
        }
    }
    
    /// 显示一个简单的toast
    /// - Parameters:
    ///   - str: 内容
    ///   - delaySecond: 延迟时间
    func toast(_ str: String, _ delaySecond: DispatchTime = .now() + 2, offSetY: CGFloat = 0) {
        WPGCD.main_Async {
            let toastView = WPToastView()
            toastView.titleL.text = str
            toastView.alpha = 0
            
            base.addSubview(toastView)
            
            toastView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(offSetY)
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                toastView.alpha = 1
            }, completion: { isRes in
                if isRes {
                    DispatchQueue.main.asyncAfter(deadline: delaySecond) {
                        UIView.animate(withDuration: 0.5, animations: {
                            toastView.alpha = 0
                        }, completion: { _ in
                            toastView.removeFromSuperview()
                        })
                    }
                } else {
                    toastView.removeFromSuperview()
                }
            })
        }
    }
}

open class WPPlaceholderView: UIView {
    /// 标题
    public let titleL = UILabel()
    /// 描述
    public let descL = UILabel()
    /// 图片
    public let imgV = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleL)
        addSubview(descL)
        addSubview(imgV)
        
        imgV.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().priority(.medium)
        }
        
        titleL.snp.makeConstraints { make in
            make.top.equalTo(imgV.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
        }
        
        descL.snp.makeConstraints { make in
            make.top.equalTo(titleL.snp.bottom).offset(6)
            make.bottom.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class WPDashLineLayer : CAShapeLayer{}

class WPToastView: UIView {
    /// 内容视图
    let titleL = UILabel()
    /// 背景视图
    let backgroundV = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundV)
        addSubview(titleL)
        backgroundV.backgroundColor = .init(0, 0, 0, 255 * 0.6)
        titleL.numberOfLines = 0
        titleL.textColor = .white
        layer.cornerRadius = 8
        clipsToBounds = true
        
        backgroundV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleL.snp.makeConstraints { make in
            make.left.top.equalTo(20)
            make.bottom.right.equalTo(-20)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension UIView {
    var wp_x: CGFloat {
        get { return frame.origin.x }
        set { frame.origin.x = newValue }
    }
    
    var wp_y: CGFloat {
        get { return frame.origin.y }
        set { frame.origin.y = newValue }
    }
    
    var wp_width: CGFloat {
        get { return frame.size.width }
        set { frame.size.width = newValue }
    }
    
    var wp_height: CGFloat {
        get { return frame.size.height }
        set { frame.size.height = newValue }
    }
    
    var wp_maxX: CGFloat {
        get { return wp_x + wp_width }
        set { wp_x = newValue - wp_width }
    }
    
    var wp_maxY: CGFloat {
        get { return wp_y + wp_height }
        set { wp_y = newValue - wp_height }
    }
    
    var wp_centerX: CGFloat {
        get { return center.x }
        set { center.x = newValue }
    }
    
    var wp_centerY: CGFloat {
        get { return center.y }
        set { center.y = newValue }
    }
    
    var wp_midX: CGFloat {
        return wp_width * 0.5
    }
    
    var wp_midY: CGFloat {
        return wp_height * 0.5
    }
    
    var wp_size: CGSize {
        get { return frame.size }
        set { frame.size = newValue }
    }
    
    var wp_orgin: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }
}
