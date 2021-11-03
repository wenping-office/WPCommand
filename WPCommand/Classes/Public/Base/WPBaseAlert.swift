//
//  WPBaseAlert.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class WPBaseAlert: UIView {
    /// 显示的根视图
    open var rootView : UIView?{
        didSet{
            if let rootView = rootView{
                rootView.addSubview(self)
                
                snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                superview?.layoutIfNeeded()
            }
        }
    }
    /// 蒙板
    open var grayView = UIButton()
    /// 开始动画时间
    open var startDuration : CGFloat { return 0.3}
    /// 结束动画时间
    open var endDuration : CGFloat { return 0.3}
    /// 蒙板颜色
    open var maskColor : UIColor {return UIColor.init(0, 0, 0, 0.15)}
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
        initSubViewLayout()
        observeSubViewEvent()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 初始化试图
    open func initSubView(){
        grayView.backgroundColor = .clear
        addSubview(grayView)
    }
    /// 初始化视图布局
    open func initSubViewLayout(){
        grayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    /// 监听子控件事件
    open func observeSubViewEvent(){
        grayView.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
            self?.dismiss()
        }).disposed(by: wp_disposeBag)
    }
    /// 显示弹窗
    open func show(){
        willShow()
        if self.rootView == nil{
            rootView = UIApplication.shared.keyWindow ?? UIView()
        }
        showToLoacton()
        UIView.animate(withDuration: TimeInterval(startDuration), animations: {[weak self]in
            self?.showToAnimates()
            self?.grayView.backgroundColor = self?.maskColor
            self?.superview?.layoutIfNeeded()
        }, completion: {[weak self] complete in
            if complete{
                self?.didShow()
            }
        })
    }
    /// 隐藏弹窗
    open func dismiss(completeAnimate:(()->Void)?=nil){
        willDismiss()
        dismissToLocation()
        UIView.animate(withDuration: TimeInterval(endDuration), animations: {[weak self]in
            self?.grayView.backgroundColor = .clear
            self?.dismissToAnimates()
            self?.superview?.layoutIfNeeded()
        }, completion: {[weak self] complete in
            if complete,let self = self{
                completeAnimate?()
                self.didDismiss()
                self.removeFromSuperview()
            }
        })
    }
    /// 子类重写弹出的结束位置
    open func showToLoacton(){}
    /// 子类重写收回的结束位置
    open func dismissToLocation(){}
    /// 子类重写 将要收回回掉
    open func willDismiss(){}
    /// 子类重写收回回掉
    open func didDismiss(){}
    /// 子类重写 将要显示回调
    open func willShow(){}
    /// 子类重写弹出后回掉
    open func didShow(){}
    /// 子类重写动画正在执信
    open func showToAnimates(){}
    /// 子类重写动画正在执行
    open func dismissToAnimates(){}
}

