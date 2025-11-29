//
//  AlertProtocol.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/24.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import ObjectiveC
import WPCommand

private var backgroundKey: UInt8 = 0

struct AlertMaskInfo {
    /// 是否需要蒙层
    var isAlertMask:Bool = true
    /// 蒙层颜色
    var backgroundColor:UIColor = UIColor.black.withAlphaComponent(0.7)
}

struct AlertInfo {
    /// 弹窗弹出方向
    var direction:Direction = .center
    /// 可选自动消失时间为nil时将不会自动消失
    var autoDismissDuration:TimeInterval? = nil
    /// 动画时间
    var animationDuration:TimeInterval = 0.3
    
    
    enum Direction {
        case top, bottom, left, right, center
    }
}

protocol AlertProtocol: UIView {
    func alertMaskInfo() -> AlertMaskInfo
    func alertInfo() -> AlertInfo

    func touchAlertMask()
    func show(in parent: UIView?)
    func dismiss()
}


extension AlertProtocol {
    
    func alertMaskInfo() -> AlertMaskInfo {
        return .init()
    }
    func alertInfo() -> AlertInfo{
        return .init()
    }
    
    func touchAlertMask(){}
}

extension AlertProtocol {
    
    private var backgroundMaskView: UIView {
        get {
            if let bg = objc_getAssociatedObject(self, &backgroundKey) as? UIView {
                return bg
            }
            let bg = UIView()
            objc_setAssociatedObject(self, &backgroundKey, bg, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bg
        }
    }
    
    func initStartLayout(){
        snp.makeConstraints { make in
            switch alertInfo().direction {
            case .top:
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(0)
            case .bottom:
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(0)
            case .left:
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(0)
            case .right:
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(0)
            case .center:
                make.center.equalToSuperview()
            }
        }
    }
    
    func resetStartLayout(){
        snp.updateConstraints { make in
            switch alertInfo().direction {
            case .top:
                make.top.equalToSuperview().offset(-frame.size.height)
            case .bottom:
                make.bottom.equalToSuperview().offset(frame.size.height)
            case .left:
                make.left.equalToSuperview().offset(-frame.size.width)
            case .right:
                make.right.equalToSuperview().offset(frame.size.width)
            case .center:
                make.center.equalToSuperview()
            }
        }
    }
    
    func resetEndLayout(){
        snp.updateConstraints({ make in
            switch alertInfo().direction {
            case .top:
                make.top.equalToSuperview().offset(0)
            case .bottom:
                make.bottom.equalToSuperview().offset(0)
            case .left:
                make.left.equalToSuperview().offset(0)
            case .right:
                make.right.equalToSuperview().offset(0)
            case .center:
                make.center.equalToSuperview()
            }
        })
    }

    func show(in parent: UIView? = nil) {
        let container = parent ?? UIApplication.wp.keyWindow!
        
        if alertMaskInfo().isAlertMask{
            backgroundMaskView.backgroundColor = alertMaskInfo().backgroundColor
            backgroundMaskView.isUserInteractionEnabled = true
            container.addSubview(backgroundMaskView)
            let tap = UITapGestureRecognizer()
            backgroundMaskView.addGestureRecognizer(tap)
            
            backgroundMaskView.wp.tapGesture.bind(onNext: {[weak self] _ in
                self?.touchAlertMask()
            }).disposed(by: wp.disposeBag)
            
            backgroundMaskView.alpha = 0
            backgroundMaskView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        container.addSubview(self)
        initStartLayout()
        layoutIfNeeded()
        resetStartLayout()
        container.layoutIfNeeded()
        
        // center 弹出从 0 → 1
        if alertInfo().direction == .center {
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }
        
        // 弹性动画
        UIView.animate(withDuration: alertInfo().animationDuration,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut,
                       animations: {
            if self.alertMaskInfo().isAlertMask{
                self.backgroundMaskView.alpha = 1
            }
            
            if self.alertInfo().direction == .center {
                self.transform = .identity
            } else {
                self.resetEndLayout()
                container.layoutIfNeeded()
                
            }
        }, completion: { _ in
            if let duration = self.alertInfo().autoDismissDuration {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.dismiss()
                }
            }
        })
    }
    
    func dismiss() {
        guard let container = self.superview else { return }
        
        UIView.animate(withDuration: alertInfo().animationDuration, animations: {
            switch self.alertInfo().direction {
            case .center:
                self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            default:
                self.resetStartLayout()
            }
            container.layoutIfNeeded()
            if self.alertMaskInfo().isAlertMask{
                self.backgroundMaskView.alpha = 0
            }
        }, completion: { _ in
            if self.alertMaskInfo().isAlertMask{
                self.backgroundMaskView.removeFromSuperview()
            }
            self.removeFromSuperview()
        })
    }
    
}
