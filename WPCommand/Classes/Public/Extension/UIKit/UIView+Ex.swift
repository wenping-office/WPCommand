//
//  UIImageView.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxCocoa

public extension UIView{
    /// 从xib加载
    static func initWithXibName(xib: String) -> Any? {
        guard let nibs = Bundle.main.loadNibNamed(xib, owner: nil, options: nil) else {
            return nil
        }
        return nibs[0]
    }
}

public extension UIView {

    /// 在keyWindow中的位置
     var wp_frameInWidow : CGRect{
        return convert(bounds, to: UIApplication.shared.windows.last)
    }

    ///将当前视图转为UIImage
    var wp_image : UIImage{
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

public extension UIView{
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
    
    /// 选择性圆角处理，需要设置frame后调用，如果是约束需要layout后调用才能生效
    func wp_corner(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
    /// 设置边框
    func wp_boardLine(color: UIColor, top: Bool, right: Bool, bottom: Bool, left: Bool, width: CGFloat) {
        let nameKey = "setBoardLine"
        layer.sublayers?.forEach { if $0.name == nameKey { $0.removeFromSuperlayer() } }
        
        let boolList = [top, right, bottom, left]
        let rectList = [CGRect(x: 0, y: 0, width: self.wp_width, height: wp_width),
                        CGRect(x: wp_width - width, y: 0, width: width, height: wp_height),
                        CGRect(x: 0, y: wp_height - width, width: self.wp_width, height: wp_width),
                        CGRect(x: 0, y: 0, width: width, height: wp_height)]

        for (idx, bo) in boolList.enumerated() {
            if bo {
                let layer: CALayer = CALayer()
                layer.name = nameKey
                layer.frame = rectList[idx]
                layer.backgroundColor = color.cgColor
                self.layer.addSublayer(layer)
            }
        }
    }
    
    ///设置渐变背景色，需在设置frame或约束后调用
    func wp_layerColors(_ startPoint: CGPoint, _ endPoint: CGPoint, _ colors: [CGColor]) {
        let layer = CAGradientLayer()
        let sKey = "c-p-p"
        layer.name = sKey
        layer.frame = bounds
        layer.colors = colors
        layer.endPoint = endPoint
        layer.startPoint = startPoint
        layer.cornerRadius = self.layer.cornerRadius
        for oldLayer in self.layer.sublayers ?? [] {
            if oldLayer.name == sKey {
                self.layer.replaceSublayer(oldLayer, with: layer)
                return
            }
        }
        self.layer.insertSublayer(layer, at: 0)
    }
}

public extension UIView {
    /// 子试图随机色
    func wp_subViewRandomColor(){
        subviews.forEach { subView in
            subView.backgroundColor = .wp_random
            backgroundColor = .wp_random
        }
    }

    /// 绘制虚线
    /// - Parameters:
    ///   - strokeColor: 颜色
    ///   - lineWidth: 线宽
    ///   - lineLength: 长度
    ///   - lineSpacing: 虚线间隔
    ///   - isBottom: 是否是底部
    func wp_drawDashLine(strokeColor: UIColor,
                         lineWidth: CGFloat = 1,
                         lineLength: Int = 10,
                         lineSpacing: Int = 5,
                         isBottom: Bool = true) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = self.bounds
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        
        //每一段虚线长度 和 每两段虚线之间的间隔
        shapeLayer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]
        
        let path = CGMutablePath()
        let y = isBottom == true ? self.layer.bounds.height - lineWidth : 0
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: self.layer.bounds.width, y: y))
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
    
    /// 显示占位视图
    /// - Parameters:
    ///   - offSetY: 偏移量
    ///   - config: 配置项
    func wp_showPlaceholder(offSetY:CGFloat=0,
                            config:(WPPlaceholderView)->Void){
        let tag = 10086
        var contetnView : UIView?
        // 先查询是否有占位视图
        subviews.forEach { elmt in
            if elmt.tag == tag{
                contetnView = elmt
            }
        }
        if contetnView == nil {
            contetnView = UIView()
        }
        contetnView?.tag = tag
        addSubview(contetnView!)
        
        contetnView?.snp.remakeConstraints({ make in
            make.edges.equalToSuperview()
        })
        
        let placeholderView = WPPlaceholderView()
        config(placeholderView)
        contetnView?.addSubview(placeholderView)
        placeholderView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(offSetY)
        }
    }
    
    /// 移除占位视图
    func wp_removePlaceholder(){
        let tag = 10086
        var contetnView : UIView?
        subviews.forEach { elmt in
            if elmt.tag == tag{
                contetnView = elmt
            }
        }
        contetnView?.removeFromSuperview()
    }
    
    /// 显示加载小菊花
    /// - Parameter show: 是否显示
    func loading(is show:Bool) {
        let tag = 10087
        var resualt = false
        for subView in subviews {
            if subView.tag == tag {
                resualt = true
            }
        }
       
        if show && !resualt {
            let lodingView = UIActivityIndicatorView()
            lodingView.tag = tag
            lodingView.startAnimating()
            addSubview(lodingView)
            lodingView.snp.makeConstraints { (make) in
                make.center.equalTo(self)
                make.width.height.equalTo(20)
            }
            
        }else if !show && resualt{
            var subLoding : UIView?
            for subView in subviews {
                if subView.tag == tag {
                    subLoding = subView
                }
            }
            subLoding?.removeFromSuperview()
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
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
