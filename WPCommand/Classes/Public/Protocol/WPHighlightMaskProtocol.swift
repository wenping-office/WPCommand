//
//  WPHighlightViewProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/10/21.
//

import UIKit

/// 高亮蒙层协议、实现协议后拥有高亮显示方法
public protocol WPHighlightMaskProtocol:UIView{
    /// 高亮顶部视图
    func highlightTopView() -> WPHighlightViewProtocol
    /// 高亮底部视图
    func highlightBottomView() -> WPHighlightViewProtocol
    /// 高亮左边视图
    func highlightLeftView() -> WPHighlightViewProtocol
    /// 高亮右边视图
    func highlightRightView() -> WPHighlightViewProtocol
    /// 高亮中心视图
    func highlightCenterView() -> WPHighlightViewProtocol
}

public extension WPHighlightMaskProtocol{
    /// 高亮顶部视图
    func highlightTopView() -> WPHighlightViewProtocol {
        return WPHighlighMaskView()
    }
    /// 高亮底部视图
    func highlightBottomView() -> WPHighlightViewProtocol {
        return WPHighlighMaskView()
    }
    /// 高亮左边视图
    func highlightLeftView() -> WPHighlightViewProtocol {
        return WPHighlighMaskView()
    }
    /// 高亮右边视图
    func highlightRightView() -> WPHighlightViewProtocol {
        return WPHighlighMaskView()
    }
    /// 高亮中心视图
    func highlightCenterView()->WPHighlightViewProtocol{
        return WPHighlighMaskCenterView()
    }
    
    /// 显示高亮到某个视图
    /// - Parameter view: 高亮添加到的视图 注：view的frame必须稳定以后才可以调用、否则有可能显示位置不准,并且view必须是self的底层，看起来要比view一般是widow或者view的superView
    func showHighlight(to view:UIView? = nil,
                       touch:((WPHighlightViewProtocol)->Void)? = nil,
                       color : UIColor = UIColor.init(0, 0, 0, 0.4)){
        
        removeHighlight(of: view)

        let keyView = view != nil ? view : UIApplication.shared.wp_topWindow
        let keyViewFrame : CGRect = convert(bounds, to: keyView)

        let topView = highlightTopView()
        let bottomView = highlightBottomView()
        let leftView = highlightLeftView()
        let rightView = highlightRightView()
        let centerView = highlightCenterView()
        
        let centerTapGesture = UITapGestureRecognizer()
        let topTapGesture = UITapGestureRecognizer()
        let bottomTapGesture = UITapGestureRecognizer()
        let leftTapGesture = UITapGestureRecognizer()
        let rightTapGesture = UITapGestureRecognizer()
        topView.addGestureRecognizer(topTapGesture)
        bottomView.addGestureRecognizer(bottomTapGesture)
        leftView.addGestureRecognizer(leftTapGesture)
        rightView.addGestureRecognizer(rightTapGesture)
        centerView.addGestureRecognizer(centerTapGesture)
        topTapGesture.rx.event.bind(onNext: { gesture in
            topView.highlighMaskTouch(tapGesture: gesture,targetView: topView)
            touch?(topView)
        }).disposed(by: topView.wp_disposeBag)
        bottomTapGesture.rx.event.bind(onNext: { gesture in
            bottomView.highlighMaskTouch(tapGesture: gesture,targetView: bottomView)
            touch?(bottomView)
        }).disposed(by: topView.wp_disposeBag)
        leftTapGesture.rx.event.bind(onNext: { gesture in
            leftView.highlighMaskTouch(tapGesture: gesture,targetView: leftView)
            touch?(leftView)
        }).disposed(by: topView.wp_disposeBag)
        rightTapGesture.rx.event.bind(onNext: { gesture in
            rightView.highlighMaskTouch(tapGesture: gesture,targetView: rightView)
            touch?(rightView)
        }).disposed(by: topView.wp_disposeBag)

        topView.backgroundColor = color
        bottomView.backgroundColor = color
        leftView.backgroundColor = color
        rightView.backgroundColor = color
        topView.highlighMaskDidSet(color: color,targetView: topView)
        bottomView.highlighMaskDidSet(color: color,targetView: bottomView)
        leftView.highlighMaskDidSet(color: color,targetView: leftView)
        rightView.highlighMaskDidSet(color: color,targetView: rightView)
        centerView.highlighMaskDidSet(color: color,targetView: centerView)

        keyView?.addSubview(topView)
        keyView?.addSubview(bottomView)
        keyView?.addSubview(leftView)
        keyView?.addSubview(rightView)
        superview?.insertSubview(centerView, belowSubview: self)
   
        topView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(keyViewFrame.minY)
        }
        
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(keyViewFrame.maxY)
        }
        
        leftView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.width.equalTo(keyViewFrame.minX)
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        rightView.snp.makeConstraints { make in
            make.top.bottom.equalTo(leftView)
            make.right.equalToSuperview()
            make.left.equalTo(keyViewFrame.maxX)
        }
        
        centerView.frame = frame
        if layer.cornerRadius != 0 {
            let layer = CAShapeLayer.wp_shapefillet([.allCorners], radius: layer.cornerRadius, in: bounds)
            layer.fillColor = color.cgColor
            centerView.layer.addSublayer(layer)
        }
    }
    
    /// 从某个视图移除高亮视图
    func removeHighlight(of view:UIView? = nil,
                                   completion:((WPHighlightMaskProtocol)->Void)? = nil){
        let keyView = view != nil ? view : UIApplication.shared.wp_topWindow
        keyView?.subviews.forEach({ elmt in
            let highView = elmt as? WPHighlightViewProtocol
            highView?.removeFromSuperview()
        })
        
        superview?.subviews.forEach({ elmt in
            let highView = elmt as? WPHighlightViewProtocol
            highView?.removeFromSuperview()
        })

        completion?(self)
    }
}

/// 高亮视图协议 实现协议后会返回高亮时创建的视图
public protocol WPHighlightViewProtocol:UIView {
    /// 蒙层被点击了
    func highlighMaskTouch(tapGesture:UITapGestureRecognizer,targetView:WPHighlightViewProtocol)
    /// 设置高亮时的颜色
    func highlighMaskDidSet(color:UIColor,targetView:WPHighlightViewProtocol)
}

public extension WPHighlightViewProtocol{
    /// 蒙层被点击了
    func highlighMaskTouch(tapGesture:UITapGestureRecognizer,targetView:WPHighlightViewProtocol){}
    /// 设置高亮时的颜色
    func highlighMaskDidSet(color:UIColor,targetView:WPHighlightViewProtocol){}
}

/// 高亮蒙层视图内部使用
class WPHighlighMaskView:UIView,WPHighlightViewProtocol {}
/// 高亮蒙层视图内部使用
class WPHighlighMaskCenterView:UIView,WPHighlightViewProtocol {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}



