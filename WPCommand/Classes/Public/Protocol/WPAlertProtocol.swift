//
//  WPAlertProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/30.
//

import UIKit
import RxSwift


public class WPAlertManager {

    /// 弹窗视图
    fileprivate weak var currentAlert : WPAlertProtocol?
    /// 弹窗弹出的根视图
    fileprivate weak var targetView : UIView? = UIApplication.shared.wp_topWindow{
        willSet{
            
            removeMask()
        }
    }
    /// 当前弹窗的mask
    fileprivate weak var maskView : WPAlertManagerMask?
    /// 弹窗队列
    fileprivate var alerts : [WPAlertProtocol] = []
    /// 当前弹窗开始的frame
    fileprivate var currentAlertBeginFrame : CGRect = .zero
    /// 当前弹窗结束的frame
    fileprivate var currentAlertEndFrame : CGRect = .zero
    /// 当前弹窗的进度
    fileprivate var currentAlertProgress : Progress = .unknown
    
    /// 单例
    public static var  `default` : WPAlertManager = {
        let manager = WPAlertManager()
        return manager
    }()
    
    /// 添加一个弹窗
    public func addAlert(_ alert : WPAlertProtocol){
        alert.updateStatus(status: .cooling)
        alert.tag = WPAlertManager.identification()
        alerts.append(alert)
        alert.alertManager = self
    }
    
    /// 移除一个弹窗
    public func removeAlert(_ alert : WPAlertProtocol){
        
        currentAlert = nil
        alert.alertManager = nil
        alert.removeFromSuperview()
        
        let id = alert.tag
        let index = self.alerts.wp_index { elmt in
            return elmt.tag == id
        }
        
        if let alertIndex = index {
            alerts.remove(at: Int(alertIndex))
        }
        alert.updateStatus(status: .remove)
        
        currentAlert = alerts.first
    }
    
    /// 添加一组弹窗会清除现有的弹窗
    /// - Parameter alerts: 弹窗
    public func setAlerts(_ alerts:[WPAlertProtocol])->WPAlertManager{
        self.alerts = []
        alerts.forEach {[weak self] elmt in
            self?.addAlert(elmt)
        }
        return self
    }
    
    /// 弹出一个弹窗 如果序列里有多个弹窗将会插入到下一个
    /// - Parameters:
    ///   - alert: 弹窗
    public func showNext(_ alert:WPAlertProtocol){
        alert.tag = WPAlertManager.identification()
        alerts.insert(alert, at: 0)
        alert.alertManager = self
        
        if currentAlertProgress == .didShow{
            dismiss()
        }else if currentAlertProgress == .unknown{
            show()
        }else{
            alert.updateStatus(status: .cooling)
        }
    }
    
    /// 弹窗的根视图 在哪个视图上弹出
    /// - Parameter view:
    /// - Returns: 弹窗管理者
    public func target(in view:UIView) -> WPAlertManager {
        targetView = view
        return self
    }
    
    /// 隐藏当前的弹框 如果弹框序列里还有弹窗将会弹出下一个
    public func dismiss(){
        alertAnimate(isShow: false)
    }
    
    /// 显示弹窗
    public func show(){
        
        alertAnimate(isShow: true)
    }
}

extension WPAlertManager{
    
    /// 获取一个唯一标识
    fileprivate static func identification()->Int{
        return Int(arc4random_uniform(100) + arc4random_uniform(100) + arc4random_uniform(100))
    }
    
    /// 添加一个蒙版
    fileprivate func addMask(info:WPAlertManager.Mask){
        var resualt = false

        // 检查是否有蒙版
        targetView?.subviews.forEach({ elmt in
            if elmt.isKind(of: WPAlertManagerMask.self){
                resualt = true
            }
        })

        // 如果没有蒙版 那么添加一个
        if !resualt  {
            let maskView = WPAlertManagerMask(maskInfo: info, action: { [weak self] in
                
                self?.currentAlert?.touchMast()
            })
            self.maskView = maskView
            maskView.alpha = 0
            targetView?.insertSubview(maskView, at: 999)
            maskView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    /// 删除蒙版
    fileprivate func removeMask(){
        maskView?.removeFromSuperview()
        maskView = nil
    }
    
    /// 判断是否还有下一个弹窗
    fileprivate func isNext()->Bool{
        let count = alerts.count
        return (count - 1) > 0
    }

    /// 执行弹窗动画
    fileprivate func alertAnimate(isShow:Bool){
        if let alert = currentAlert{
             
            if isShow {
                addMask(info: alert.maskInfo())
                
                targetView?.insertSubview(alert, at: 1000)
                resetFrame(alert: alert)
                maskView?.maskInfo = alert.maskInfo()
                
                alert.updateStatus(status: .willShow)
                currentAlertProgress = .willShow
            }else{
                alert.updateStatus(status: .willPop)
                currentAlertProgress = .willPop
            }
            
            let duration =  isShow ? alert.beginAnimateDuration : alert.endAnimateDuration

            let animatesBolok : ()->Void = { [weak self] in
                guard let self = self else { return }
                
                alert.transform = CGAffineTransform.identity
                if isShow{
                    alert.frame = self.currentAlertBeginFrame
                    alert.alpha = 1
                    self.maskView?.alpha = 1
                }else{
                    alert.frame = self.currentAlertEndFrame
                    if !self.isNext() {
                        self.maskView?.alpha = 0
                    }
                    if alert.endLocation == .center {
                        alert.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
                    }
                }
            }
            
            let animateCompleteBlock : (Bool)->Void = {[weak self] resualt in
                guard let self = self else { return }
                
                if resualt{
                    if isShow {
                        alert.updateStatus(status: .didShow)
                        self.currentAlertProgress = .didShow
                    }else{
                        self.currentAlertProgress = .didPop
                        alert.updateStatus(status: .didPop)
                        self.removeAlert(alert)
                        self.show()
                    }
                }
            }
            
            if alert.animateType == .default {
                UIView.animate(withDuration: TimeInterval(duration), animations: {
                    animatesBolok()
                }, completion: {resualt in
                    animateCompleteBlock(resualt)
                })
            }else if alert.animateType == .bounces{
                UIView.animate(withDuration: TimeInterval(duration), delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
                    animatesBolok()
                }, completion: {resualt in
                    animateCompleteBlock(resualt)
                })
            }
        }else{
            currentAlert = alerts.first
            if  currentAlert != nil {
                show()
            }else{
                removeMask()
            }
        }
    }
    
    /// 计算弹窗的位置
    fileprivate func resetFrame(alert:WPAlertProtocol){
        
        let alertW : CGFloat = alert.wp_width
        let alertH : CGFloat = alert.wp_height
        let maxW : CGFloat = targetView?.wp_width ?? 0
        let maxH : CGFloat = targetView?.wp_height ?? 0
        let center : CGPoint = .init(x: (maxW - alertW) * 0.5, y: (maxH - alertH) * 0.5)
        
        var beginF : CGRect = .init(x: 0, y: 0, width: alertW, height: alertH)
        var endF : CGRect = .init(x: 0, y: 0, width: alertW, height: alertH)
        
        switch alert.beginLocation {
        case .top:
            beginF.origin.x = center.x
            beginF.origin.y = 0
            alert.wp_x = center.x
            alert.wp_y = -alertH
        case .left:
            beginF.origin.x = 0
            beginF.origin.y = center.y
            alert.wp_x = -alertW
            alert.wp_y = center.y
        case .bottom:
            beginF.origin.x = center.x
            beginF.origin.y = maxH-alertH
            alert.wp_x = center.x
            alert.wp_y = maxH
        case .right:
            
            beginF.origin.y = center.y
            beginF.origin.x = maxW - alertW
            alert.wp_y = center.y
            alert.wp_x = maxW
        case .center:
            beginF.origin = center
            alert.alpha = 0
            alert.frame.origin = center
            alert.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
        }
        
        switch alert.endLocation  {
        case .top:
            endF.origin.x = center.x
            endF.origin.y = -alertH
        case .left:
            endF.origin.x = -alertW
            endF.origin.y = beginF.origin.y
        case .bottom:
            endF.origin.x = beginF.origin.x
            endF.origin.y = maxH
        case .right:
            endF.origin.x = maxW
            endF.origin.y = center.y
        case .center:
            endF.origin = center
        }
        
        currentAlertBeginFrame = beginF
        currentAlertEndFrame = endF
    }
    
}

public extension WPAlertManager{
    struct Mask {
        /// 蒙板颜色
       public let color : UIColor
        /// 是否可以交互点击
       public let enabled : Bool
        /// 是否显示
       public let isHidden : Bool
        
        /// 初始化一个蒙版信息
        /// - Parameters:
        ///   - color: 蒙板颜色
        ///   - enabled: 是否可以交互点击
        ///   - isHidden: 是否隐藏
        public init(color:UIColor,enabled:Bool,isHidden:Bool) {
            self.color = color
            self.enabled = enabled
            self.isHidden = isHidden
        }
    }
    
    enum Progress{
        /// 挂起状态等待被弹出
        case cooling
        /// 将要显示
        case willShow
        /// 已经弹并显示
        case didShow
        /// 将要弹出
        case willPop
        /// 已经弹出完成
        case didPop
        /// 弹窗已经被移除
        case remove
        /// 未知状态
        case unknown
    }
    
    /// 动画类型
    enum AnimateType{
        /// 默认
        case `default`
        /// 弹簧效果
        case bounces
    }
    
    /// 弹窗开始位置
    enum BeginLocation {
        /// 顶部弹出
        case top
        /// 左边弹出
        case left
        /// 底部弹出
        case bottom
        /// 右边弹出
        case right
        /// 中间弹出
        case center
    }
    
    /// 弹出结束位置
    enum EndLocation {
        /// 顶部收回
        case top
        /// 左边收回
        case left
        /// 底部收回
        case bottom
        /// 右边收回
        case right
        /// 中心收回
        case center
    }
}

/// 蒙板视图
class WPAlertManagerMask: UIView {
    /// 垃圾桶
    let disposeBag = DisposeBag()

    /// 蒙板视图
    let contentView = UIButton()

    /// 蒙板info
    var maskInfo : WPAlertManager.Mask{
        didSet{
            contentView.backgroundColor = maskInfo.color
            contentView.isUserInteractionEnabled = !maskInfo.enabled
            isHidden = maskInfo.isHidden
        }
    }
    
    init(maskInfo:WPAlertManager.Mask,action:(()->Void)?) {
        self.maskInfo = maskInfo
        super.init(frame: .zero)
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.rx.tap.subscribe(onNext: { _ in
            action != nil ? action!() : print()
        }).disposed(by: disposeBag)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate var WPAlertProtocolPointer = "WPItemsModelPointer"
/// 弹窗协议
public protocol WPAlertProtocol:UIView {
    
    /// 当前弹窗属于的manager
    var alertManager : WPAlertManager?{ get set}
    /// 弹簧效果
    var animateType : WPAlertManager.AnimateType{ get }
    /// 弹窗开始位置
    var beginLocation : WPAlertManager.BeginLocation { get }
    /// 弹出弹出的时间
    var beginAnimateDuration : CGFloat { get }
    /// 弹窗结束位置
    var endLocation : WPAlertManager.EndLocation { get }
    /// 弹窗结束的时间
    var endAnimateDuration : CGFloat { get }
    /// 弹窗状态变化后执行
    func updateStatus(status: WPAlertManager.Progress)
    /// 蒙板属性
    func maskInfo()->WPAlertManager.Mask
    /// 点击了蒙版
    func touchMast()
}

public extension WPAlertProtocol{
    var alertManager : WPAlertManager? {
        get{
            return objc_getAssociatedObject(self, &WPAlertProtocolPointer) as? WPAlertManager
        }
        set{
            objc_setAssociatedObject(self, &WPAlertProtocolPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func maskInfo()->WPAlertManager.Mask{
        
        return .init(color: UIColor.init(0, 0, 0,255 * 0.15), enabled: false,isHidden: false)
    }
    
    func touchMast(){
        alertManager?.dismiss()
    }
    
    func updateStatus(status: WPAlertManager.Progress){}
}
