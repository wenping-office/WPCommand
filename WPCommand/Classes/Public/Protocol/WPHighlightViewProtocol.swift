//
//  WPHighlightViewProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/10/21.
//

import UIKit

/// 高亮视图协议 实现协议后会持有高亮方法
public protocol WPHighlightViewProtocol:UIView {
    /// 蒙层被点击了
    func highlighMaskTouch(tapGesture:UITapGestureRecognizer)
    /// 设置高亮时的颜色
    func highlighMaskDidSet(color:UIColor)
}

public extension WPHighlightViewProtocol{
    /// 蒙层被点击了
    func highlighMaskTouch(tapGesture:UITapGestureRecognizer){}
    /// 设置高亮时的颜色
    func highlighMaskDidSet(color:UIColor){}
}

/// 高亮蒙层视图内部使用
class WPHighlighMaskView:UIView,WPHighlightViewProtocol {}

public extension UIView{
    
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
        return WPHighlighMaskView()
    }

    /// 显示高亮到某个视图
    /// - Parameter view: 高亮添加到的视图 注：view的frame必须稳定以后才可以调用、否则有可能显示位置不准,并且view必须是self的底层，看起来要比view一般是widow或者view的superView
    func showHighlight(to view:UIView? = nil,
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
            topView.highlighMaskTouch(tapGesture: gesture)
        }).disposed(by: topView.wp_disposeBag)
        bottomTapGesture.rx.event.bind(onNext: { gesture in
            bottomView.highlighMaskTouch(tapGesture: gesture)
        }).disposed(by: topView.wp_disposeBag)
        leftTapGesture.rx.event.bind(onNext: { gesture in
            leftView.highlighMaskTouch(tapGesture: gesture)
        }).disposed(by: topView.wp_disposeBag)
        rightTapGesture.rx.event.bind(onNext: { gesture in
            rightView.highlighMaskTouch(tapGesture: gesture)
        }).disposed(by: topView.wp_disposeBag)

        topView.backgroundColor = color
        bottomView.backgroundColor = color
        leftView.backgroundColor = color
        rightView.backgroundColor = color
        centerView.backgroundColor = color
        topView.highlighMaskDidSet(color: color)
        bottomView.highlighMaskDidSet(color: color)
        leftView.highlighMaskDidSet(color: color)
        rightView.highlighMaskDidSet(color: color)
        centerView.highlighMaskDidSet(color: color)

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
        
        if isAddConstraints {
            centerView.snp.makeConstraints { make in
                make.edges.equalTo(self)
            }
        }else{
            centerView.frame = frame
        }
    }
    
    /// 从某个视图移除高亮视图
    func removeHighlight(of view:UIView? = nil){
        let keyView = view != nil ? view : UIApplication.shared.wp_topWindow
        keyView?.subviews.forEach({ elmt in
            let highView = elmt as? WPHighlightViewProtocol
            highView?.removeFromSuperview()
        })
        
        superview?.subviews.forEach({ elmt in
            let highView = elmt as? WPHighlightViewProtocol
            highView?.removeFromSuperview()
        })
    }
}


