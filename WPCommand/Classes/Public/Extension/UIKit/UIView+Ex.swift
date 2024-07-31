//
//  UIImageView.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

public extension WPSpace where Base: UIView {
    /// 从xib加载
    static func initXibName(_ xibName: String,_ config:((Base)->Void)? = nil) -> Base? {
        guard let nibs = Bundle.main.loadNibNamed(xibName, owner: nil, options: nil) else {
            return nil
        }
        
        let obj = nibs.first as? Base
        weak var weakObj = obj

        if  weakObj != nil {
            config?(weakObj!)
        }
        return obj
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
    /// 快速创建内边距
    /// - Parameters:
    ///   - padding: 内边距
    ///   - priority: 约束登记
    /// - Returns: 结果
    func padding(_ padding: UIEdgeInsets = .zero, priority: ConstraintPriority = .medium) -> WPPaddingView<Base> {
        return WPPaddingView(base, padding: padding, priority: priority)
    }
    
    /// 快速创建内边距
    /// - Parameter customLayout: 自定义布局
    /// - Returns: 结果
    func padding(customLayout: @escaping ((Base) -> Void)) -> WPPaddingView<Base> {
        return WPPaddingView(base, customLayout: customLayout)
    }
}

public extension WPSpace where Base: UIView {
    /// 在keyWindow中的位置
    var frameInMainWidow: CGRect {
        return base.convert(bounds, to: UIApplication.wp.mainWindow)
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
    
    /// 子视图是否全部隐藏
    var subViewsAllHidden: Bool {
        return !base.subviews.wp_isContent(in: { !$0.isHidden })
    }
    
    /// 父类视图所有节点
    /// - Returns:
    func nodeViews(_ option: (UIView) -> Bool) -> [UIView] {
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
    func backgroundColors(_ startPoint: CGPoint, _ endPoint: CGPoint, _ colors: [CGColor]) -> CAGradientLayer {
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
    func removeAllSubView() {
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
        base.layer.sublayers?.forEach { elmt in
            (elmt as? WPDashLineLayer)?.removeFromSuperlayer()
        }
        
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
    func toast(_ str: NSAttributedString?, _ delaySecond: DispatchTime = .now() + 2, offSetY: CGFloat = 0) {
        WPGCD.main_Async {
            let toastView = WPToastView()
            toastView.titleL.attributedText = str
            toastView.alpha = 0
            
            base.addSubview(toastView)

            toastView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(offSetY)
                make.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 0.9)
                make.height.lessThanOrEqualTo(UIScreen.main.bounds.height * 0.9)
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

class WPDashLineLayer: CAShapeLayer {}

class WPToastView: UIView {
    /// 内容视图
    let titleL = UILabel()
    /// 背景视图
    let backgroundV = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundV)
        addSubview(titleL)
        titleL.textAlignment = .center
        backgroundV.backgroundColor = .wp.initWith(0, 0, 0, 0.6)
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

public extension WPSpace where Base: UIView {
    @discardableResult
    func isUserInteractionEnabled(_ isUserInteractionEnabled: Bool) -> Self {
        base.isUserInteractionEnabled = isUserInteractionEnabled
        return self
    }

    @discardableResult
    func tag(_ tag: Int) -> Self {
        base.tag = tag
        return self
    }
    
    @discardableResult
    func frame(_ frame: CGRect) -> Self {
        base.frame = frame
        return self
    }
    
    @discardableResult
    func bounds(_ bounds: CGRect) -> Self {
        base.bounds = bounds
        return self
    }
    
    @discardableResult
    func center(_ center: CGPoint) -> Self {
        base.center = center
        return self
    }
    
    @discardableResult
    func transform(_ transform: CGAffineTransform) -> Self {
        base.transform = transform
        return self
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func transform3D(_ transform3D: CATransform3D) -> Self {
        base.transform3D = transform3D
        return self
    }
    
    @discardableResult
    func contentScaleFactor(_ contentScaleFactor: CGFloat) -> Self {
        base.contentScaleFactor = contentScaleFactor
        return self
    }

    @discardableResult
    func clipsToBounds(_ clipsToBounds: Bool) -> Self {
        base.clipsToBounds = clipsToBounds
        return self
    }

    @discardableResult
    func backgroundColor(_ color: UIColor?) -> Self {
        base.backgroundColor = color
        return self
    }

    @discardableResult
    func alpha(_ alpha: CGFloat) -> Self {
        base.alpha = alpha
        return self
    }

    @discardableResult
    func isOpaque(_ isOpaque: Bool) -> Self {
        base.isOpaque = isOpaque
        return self
    }
    
    @discardableResult
    func semanticContentAttribute(_ semanticContentAttribute:UISemanticContentAttribute) -> Self {
        base.semanticContentAttribute = semanticContentAttribute
        return self
    }

    @discardableResult
    func clearsContextBeforeDrawing(_ clearsContextBeforeDrawing: Bool) -> Self {
        base.clearsContextBeforeDrawing = clearsContextBeforeDrawing
        return self
    }
    
    @discardableResult
    func isHidden(_ isHidden: Bool) -> Self {
        base.isHidden = isHidden
        return self
    }

    @discardableResult
    func contentMode(_ contentMode: UIView.ContentMode) -> Self {
        base.contentMode = contentMode
        return self
    }
    
    @discardableResult
    func mask(_ mask: UIView?) -> Self {
        base.mask = mask
        return self
    }
    
    @discardableResult
    func tintColor(_ tintColor: UIColor) -> Self {
        base.tintColor = tintColor
        return self
    }
    
    @discardableResult
    func tintAdjustmentMode(_ tintAdjustmentMode: UIView.TintAdjustmentMode) -> Self {
        base.tintAdjustmentMode = tintAdjustmentMode
        return self
    }
    
    @available(iOS 14.0, *)
    @discardableResult
    func focusGroupIdentifier(_ focusGroupIdentifier:String?) -> Self {
        base.focusGroupIdentifier = focusGroupIdentifier
        return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func focusGroupPriority(_ focusGroupPriority:UIFocusGroupPriority) -> Self {
        base.focusGroupPriority = focusGroupPriority
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func focusEffect(_ focusEffect:UIFocusEffect) -> Self {
        base.focusEffect = focusEffect
        return self
    }
    
    @discardableResult
    func contentHugging(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
        base.setContentHuggingPriority(priority, for: axis)
        return self
    }
    
    @discardableResult
    func contentCompressionResistance(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
        base.setContentCompressionResistancePriority(priority, for: axis)
        return self
    }
}

public extension WPSpace where Base: UIView{
    
    @discardableResult
    func borderWidth(_ borderWidth:CGFloat) -> Self {
        base.layer.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    func borderColor(_ borderColor:UIColor?) -> Self {
        base.layer.borderColor = borderColor?.cgColor
        return self
    }
    
    /// layer的透明度
    @discardableResult
    func opacity(_ opacity:Float) -> Self {
        base.layer.opacity = opacity
        return self
    }
    
    @discardableResult
    func cornerRadius(_ cornerRadius:CGFloat)->Self{
        base.layer.cornerRadius = cornerRadius
        return self
    }
    
    @discardableResult
    func shadowColor(_ shadowColor:UIColor?) -> Self {
        base.layer.shadowColor = shadowColor?.cgColor
        return self
    }
    
    @discardableResult
    func masksToBounds(_ masksToBounds:Bool) -> Self {
        base.layer.masksToBounds = masksToBounds
        return self
    }
    
    @discardableResult
    func shadowOpacity(_ shadowOpacity:Float) -> Self {
        base.layer.shadowOpacity = shadowOpacity
        return self
    }
    
    @discardableResult
    func shadowOffset(_ shadowOffset:CGSize) -> Self {
        base.layer.shadowOffset = shadowOffset
        return self
    }
    
    @discardableResult
    func shadowRadius(_ shadowRadius:CGFloat) -> Self{
        base.layer.shadowRadius = shadowRadius
        return self
    }
    
    @discardableResult
    func shadowPath(_ shadowPath:CGPath?) ->Self{
        base.layer.shadowPath = shadowPath
        return self
    }
    
    @discardableResult
    func layoutWidth(_ width:CGFloat,priority:ConstraintPriority = .required) ->Self{
        base.snp.makeConstraints { make in
            make.width.equalTo(width).priority(priority)
        }
        return self
    }
    
    @discardableResult
    func layoutGreaterThanOrEqualWidth(_ width:CGFloat,priority:ConstraintPriority = .required) ->Self{
        base.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(width).priority(priority)
        }
        return self
    }
    
    @discardableResult
    func layoutLessThanOrEqualToWidth(_ width:CGFloat,priority:ConstraintPriority = .required) ->Self{
        base.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(width).priority(priority)
        }
        return self
    }
    
    @discardableResult
    func layoutHeight(_ height:CGFloat,priority:ConstraintPriority = .required) ->Self{
        base.snp.makeConstraints { make in
            make.height.equalTo(height).priority(priority)
        }
        return self
    }
    
    @discardableResult
    func layoutGreaterThanOrEqualToHeight(_ height:CGFloat,priority:ConstraintPriority = .required) ->Self{
        base.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(height).priority(priority)
        }
        return self
    }
    
    @discardableResult
    func layoutLessThanOrEqualToHeight(_ height:CGFloat,priority:ConstraintPriority = .required) ->Self{
        base.snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(height).priority(priority)
        }
        return self
    }
    
    @discardableResult
    func layoutSize(_ size:CGSize,priority:ConstraintPriority = .required) ->Self{
        base.snp.makeConstraints { make in
            make.size.equalTo(size).priority(priority)
        }
        return self
    }
    
    @discardableResult
    func layoutGreaterThanOrEqualToSize(_ size:CGSize,priority:ConstraintPriority = .required) ->Self{
        base.snp.makeConstraints { make in
            make.size.greaterThanOrEqualTo(size).priority(priority)
        }
        return self
    }
    
    @discardableResult
    func layoutLessThanOrEqualToSize(_ size:CGSize,priority:ConstraintPriority = .required) ->Self{
        base.snp.makeConstraints { make in
            make.size.lessThanOrEqualTo(size).priority(priority)
        }
        return self
    }
}
