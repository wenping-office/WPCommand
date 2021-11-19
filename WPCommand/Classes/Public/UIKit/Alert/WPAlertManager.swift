//
//  WPAlertManager.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/2.
//

import RxSwift
import UIKit

public extension WPAlertManager {
    enum Option {
        /// 插入式强制立马弹出 keep == true 插入弹窗消失后弹出被插入的弹窗
        /// keep == false 干掉被插入的弹窗
        case insert(keep: Bool)
        /// 添加到下一个弹窗
        case add
    }

    /// 布局方式
    enum LayoutOption {
        case frame(size: CGSize)
        case layout
    }
}

/// 弹窗队列弹出实现WPAlertProtocol协议的弹窗，可弹出一组弹窗或插入式弹窗，也可自定义一个manager自己管理一组弹窗
public class WPAlertManager {
    /// 弹窗
    private class AlertItem {
        /// 弹窗
        let alert: WPAlertProtocol
        /// 弹窗等级
        let level: Int
        /// 是否被中断动画并且被插入到当前位置
        var isInterruptInset = false
        /// 目标视图
        weak var target: UIView?
        /// 布局方式
        var layoutOption: LayoutOption?
        init(alert: WPAlertProtocol, level: Int) {
            self.alert = alert
            self.level = level
        }
    }

    /// 弹窗视图
    private weak var currentAlert: AlertItem?
    /// 弹窗的根视图
    private weak var target: UIView? {
        willSet {
            removeMask()
        }
    }

    /// 弹窗弹出的根视图
    private var targetView: UIView {
        if target == nil {
            return UIApplication.shared.wp.topWindow
        } else {
            return target!
        }
    }

    /// 当前弹窗的mask
    private weak var maskView: WPAlertManagerMask?
    /// 弹窗队列
    private var alerts: [AlertItem] = [] {
        didSet {
            alerts.sort { elmt1, elmt2 in
                elmt1.level < elmt2.level
            }
        }
    }

    /// 当前弹窗开始的frame
    private var currentAlertBeginFrame: CGRect = .zero
    /// 当前弹窗结束的frame
    private var currentAlertEndFrame: CGRect = .zero
    /// 自动布局下的block
    private var autoLayoutBeginBlock: (()->Void)?
    /// 当前弹窗的进度
    private var currentAlertProgress: Progress = .unknown
    
    /// 单例
    public static var `default`: WPAlertManager = {
        let manager = WPAlertManager()
        return manager
    }()

    /// 添加一个弹窗
    public func addAlert(_ alert: WPAlertProtocol) {
        alert.updateStatus(status: .cooling)
        alert.tag = WPAlertManager.identification()
        alerts.append(.init(alert: alert, level: Int(alert.alertLevel())))
    }
    
    /// 移除一个弹窗
    public func removeAlert(_ alert: WPAlertProtocol) {
        currentAlert = nil
        alert.removeFromSuperview()
        
        alerts.wp_filter { elmt in
            elmt.alert.tag == alert.tag
        }
        alert.updateStatus(status: .remove)
        
        currentAlert = alerts.first
    }
    
    /// 添加一组弹窗会清除现有的弹窗
    /// - Parameter alerts: 弹窗
    @discardableResult
    public func setAlerts(_ alerts: [WPAlertProtocol])->WPAlertManager {
        self.alerts = []
        alerts.forEach { [weak self] elmt in
            self?.addAlert(elmt)
        }
        return self
    }
    
    /// 弹出一个弹窗 如果序列里有多个弹窗将会插入到下一个
    /// - Parameters:
    ///   - alert: 弹窗
    ///   - option: 选择条件
    public func showNext(_ alert: WPAlertProtocol, option: Option = .insert(keep: true)) {
        alert.tag = WPAlertManager.identification()
        let level = (currentAlert?.level ?? 0) - 1
        let alertItem: WPAlertManager.AlertItem = .init(alert: alert, level: level)
        alertItem.target = alert.targetView
        alerts.insert(alertItem, at: 0)
        alert.updateStatus(status: .cooling)
        
        if currentAlertProgress == .didShow, alerts.count >= 1 {
            switch option {
            case .insert(let keep):
                currentAlert?.isInterruptInset = keep
                alertAnimate(isShow: false, option: option)
            default: break
            }
        } else {
            alertAnimate(isShow: true, option: .add)
        }
    }
    
    /// 隐藏当前的弹框 如果弹框序列里还有弹窗将会弹出下一个
    public func dismiss() {
        alertAnimate(isShow: false, option: .add)
    }
    
    /// 显示弹窗
    public func show() {
        alertAnimate(isShow: true, option: .add)
    }
}

extension WPAlertManager {
    /// 获取一个唯一标识
    private static func identification()->Int {
        return Int(
            arc4random_uniform(100) +
                arc4random_uniform(100) +
                arc4random_uniform(100) +
                arc4random_uniform(100) +
                arc4random_uniform(100)
        )
    }
    
    /// 添加一个蒙版
    private func addMask(info: WPAlertManager.Mask) {
        // 检查是否有蒙版
        let resualt = targetView.subviews.wp_isContent { elmt in
            elmt.isKind(of: WPAlertManagerMask.self)
        }
        
        // 如果没有蒙版 那么添加一个
        if !resualt {
            let maskView = WPAlertManagerMask(maskInfo: info, action: { [weak self] in
                if self?.currentAlertProgress == .didShow {
                    self?.currentAlert?.alert.touchMask()
                }
            })
            self.maskView = maskView
            maskView.alpha = 0
            targetView.insertSubview(maskView, at: 999)
            maskView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    /// 删除蒙版
    private func removeMask() {
        maskView?.removeFromSuperview()
        maskView = nil
    }
    
    /// 判断是否还有下一个弹窗
    private func isNext()->Bool {
        let count = alerts.count
        return (count - 1) > 0
    }
    
    /// 判断下一个弹窗是否是插入进来的
    private func nextAlertIsInset()->Bool {
        guard
            let nextItem = alerts.wp_get(of: 1)
        else { return false }
        if nextItem.level <= 0 {
            return true
        }
        return false
    }
    
    /// 移动一个item并插入到插入数组的第一个
    private func moveItemToFist(_ item: AlertItem) {
        currentAlert = nil
        item.alert.removeFromSuperview()
        
        self.alerts.wp_filter { elmt in
            elmt.alert.tag == item.alert.tag
        }
        currentAlert = alerts.first
        
        item.alert.wp_size = .zero
        alerts.append(item)
    }
    
    /// 执行弹窗动画
    /// insert 是否强制
    private func alertAnimate(isShow: Bool, option: Option) {
        if let item = currentAlert {
            var layoutOption: LayoutOption = .layout
            if isShow {
                if target == nil, item.target == nil {
                } else {
                    target = item.target
                }
                addMask(info: item.alert.maskInfo())
                targetView.insertSubview(item.alert, at: 1000)
                layoutOption = resetFrame(item)
                
                switch layoutOption {
                case .layout:
                    item.alert.superview?.layoutIfNeeded()
                    autoLayoutBeginBlock?()
                default: break
                }

                maskView?.maskInfo = item.alert.maskInfo()
                item.alert.updateStatus(status: .willShow)
                currentAlertProgress = .willShow
                item.target = target
            } else {
                item.alert.updateStatus(status: .willPop)
                currentAlertProgress = .willPop
            }
            
            // 动画时间
            var duration: TimeInterval = 0
            switch option {
            case .add:
                duration = (isShow ? item.alert.alertInfo().startDuration : item.alert.alertInfo().stopDuration)
            case .insert:
                duration = 0
            }
            
            let animatesBolok: ()->Void = { [weak self] in
                guard let self = self else { return }
                item.alert.transform = CGAffineTransform.identity
                if isShow {
                    switch layoutOption {
                    case .layout:
                        item.alert.superview?.layoutIfNeeded()
                    case .frame:
                        item.alert.frame = self.currentAlertBeginFrame
                    }
                    item.alert.alpha = 1
                    self.maskView?.alpha = 1
                } else {
                    item.alert.frame = self.currentAlertEndFrame
                    if !self.isNext() {
                        self.maskView?.alpha = 0
                    }
                    if item.alert.alertInfo().stopLocation == .center {
                        item.alert.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    }
                }
            }
            
            let animateCompleteBlock: (Bool)->Void = { [weak self] resualt in
                if resualt {
                    if isShow {
                        item.isInterruptInset = false
                        self?.autoLayoutBeginBlock = nil
                        self?.resetEndFrame(item)
                        item.alert.updateStatus(status: .didShow)
                        self?.currentAlertProgress = .didShow
                    } else {
                        if !item.isInterruptInset { // 正常弹出才更新状态
                            self?.currentAlertProgress = .didPop
                            item.alert.updateStatus(status: .didPop)
                            self?.removeAlert(item.alert)
                        } else {
                            self?.moveItemToFist(item)
                        }
                        self?.show()
                    }
                } else {
                    item.alert.updateStatus(status: .unknown)
                    self?.currentAlertProgress = .unknown
                }
            }
            
            if item.alert.alertInfo().animateType == .default {
                UIView.animate(withDuration: TimeInterval(duration), animations: {
                    animatesBolok()
                }, completion: { resualt in
                    animateCompleteBlock(resualt)
                })
            } else if item.alert.alertInfo().animateType == .bounces {
                UIView.animate(withDuration: TimeInterval(duration), delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
                    animatesBolok()
                }, completion: { resualt in
                    animateCompleteBlock(resualt)
                })
            }
        } else {
            currentAlert = alerts.first
            if currentAlert != nil {
                show()
            } else {
                removeMask()
            }
        }
    }
    
    /// 计算弹窗的位置
    private func resetFrame(_ item: AlertItem)->LayoutOption {
        switch item.layoutOption {
        case .frame(let size):
            item.alert.transform = CGAffineTransform.identity
            item.alert.frame = .init(x: 0, y: 0, width: size.width, height: size.height)
        default: break
        }

        let alertW: CGFloat = item.alert.wp_width
        let alertH: CGFloat = item.alert.wp_height
        let maxW: CGFloat = targetView.wp_width
        let maxH: CGFloat = targetView.wp_height
        let center: CGPoint = .init(x: (maxW - alertW) * 0.5, y: (maxH - alertH) * 0.5)
        var beginF: CGRect = .init(x: 0, y: 0, width: alertW, height: alertH)
        
        if item.layoutOption == nil {
            item.layoutOption = (item.alert.wp_size == .zero) ? .layout : .frame(size: item.alert.wp_size)
        }
        
        switch item.alert.alertInfo().startLocation {
        case .top(let offset):
            switch item.layoutOption! {
            case .layout:
                item.alert.snp.remakeConstraints { make in
                    make.centerX.equalToSuperview().offset(offset.x)
                    make.bottom.equalTo(targetView.snp.top)
                }
                autoLayoutBeginBlock = {
                    item.alert.snp.remakeConstraints { make in
                        make.centerX.equalToSuperview().offset(offset.x)
                        make.top.equalToSuperview().offset(offset.y)
                    }
                }
            case .frame:
                beginF.origin.x = center.x + offset.x
                beginF.origin.y = 0 + offset.y
                item.alert.wp_x = center.x + offset.x
                item.alert.wp_y = -alertH + offset.y
            }
        case .topWidthToFill(let offsetY):
            item.alert.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(targetView.snp.top)
            }
            autoLayoutBeginBlock = {
                item.alert.snp.remakeConstraints { make in
                    make.top.equalToSuperview().offset(offsetY)
                }
            }
        case .left(let offset):

            switch item.layoutOption! {
            case .layout:
                item.alert.snp.remakeConstraints { make in
                    make.right.equalTo(targetView.snp.left)
                    make.centerY.equalToSuperview().offset(offset.y)
                }
                autoLayoutBeginBlock = {
                    item.alert.snp.remakeConstraints { make in
                        make.centerY.equalToSuperview().offset(offset.y)
                        make.left.equalToSuperview().offset(offset.x)
                    }
                }
            case .frame:
                beginF.origin.x = 0 + offset.x
                beginF.origin.y = center.y + offset.y
                item.alert.wp_x = -alertW + offset.x
                item.alert.wp_y = center.y + offset.y
            }

        case .leftHeightToFill(let offsetX):
            item.alert.snp.remakeConstraints { make in
                make.right.equalTo(targetView.snp.left)
                make.top.bottom.equalToSuperview()
            }
            autoLayoutBeginBlock = {
                item.alert.snp.remakeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.left.equalToSuperview().offset(offsetX)
                }
            }
        case .bottom(let offset):
            switch item.layoutOption! {
            case .layout:
                item.alert.snp.remakeConstraints { make in
                    make.top.equalTo(targetView.snp.bottom)
                    make.centerX.equalToSuperview().offset(offset.x)
                }
                autoLayoutBeginBlock = {
                    item.alert.snp.remakeConstraints { make in
                        make.bottom.equalToSuperview().offset(offset.y)
                        make.centerX.equalToSuperview().offset(offset.x)
                    }
                }
            case .frame:
                beginF.origin.x = center.x + offset.x
                beginF.origin.y = maxH - alertH + offset.y
                item.alert.wp_x = center.x + offset.x
                item.alert.wp_y = maxH + offset.y
            }

        case .bottomWidthToFill(let offsetY):
            item.alert.snp.remakeConstraints { make in
                make.top.equalTo(targetView.snp.bottom)
                make.left.right.equalToSuperview()
            }
            autoLayoutBeginBlock = {
                item.alert.snp.remakeConstraints { make in
                    make.bottom.equalToSuperview().offset(offsetY)
                    make.left.right.equalToSuperview()
                }
            }
        case .right(let offset):
            
            switch item.layoutOption! {
            case .layout:
                item.alert.snp.remakeConstraints { make in
                    make.left.equalTo(targetView.snp.right)
                    make.centerY.equalToSuperview().offset(offset.y)
                }
                autoLayoutBeginBlock = {
                    item.alert.snp.remakeConstraints { make in
                        make.right.equalToSuperview().offset(offset.x)
                        make.centerY.equalToSuperview().offset(offset.y)
                    }
                }
            case .frame:
                beginF.origin.x = maxW - alertW + offset.x
                beginF.origin.y = center.y + offset.y
                item.alert.wp_y = center.y + offset.y
                item.alert.wp_x = maxW + offset.x
            }
        case .rightHeightToFill(let offsetY):
            item.alert.snp.remakeConstraints { make in
                make.left.equalTo(targetView.snp.right)
                make.top.bottom.equalToSuperview()
            }
            autoLayoutBeginBlock = {
                item.alert.snp.remakeConstraints { make in
                    make.right.equalToSuperview().offset(offsetY)
                    make.top.bottom.equalToSuperview()
                }
            }
        case .center(let offSet):
            switch item.layoutOption! {
            case .layout:
                item.alert.snp.remakeConstraints { make in
                    make.centerX.equalToSuperview().offset(offSet.x)
                    make.centerY.equalToSuperview().offset(offSet.y)
                }
            case .frame:
                beginF.origin.x = center.x + offSet.x
                beginF.origin.y = center.y + offSet.y
                item.alert.alpha = 0
                item.alert.wp_orgin = beginF.origin
            }
            item.alert.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }
        
        currentAlertBeginFrame = beginF
        
        return item.layoutOption!
    }
    
    /// 计算弹窗结束位置
    private func resetEndFrame(_ item: AlertItem) {
        let alertW: CGFloat = item.alert.wp_width
        let alertH: CGFloat = item.alert.wp_height
        let maxW: CGFloat = targetView.wp_width
        let maxH: CGFloat = targetView.wp_height
        var endF: CGRect = .init(x: 0, y: 0, width: alertW, height: alertH)
        
        switch item.alert.alertInfo().stopLocation {
        case .top:
            endF.origin.x = item.alert.wp_x
            endF.origin.y = -alertH
        case .left:
            endF.origin.x = -alertW
            endF.origin.y = item.alert.wp_y
        case .bottom:
            endF.origin.x = item.alert.wp_x
            endF.origin.y = maxH
        case .right:
            endF.origin.x = maxW
            endF.origin.y = item.alert.wp_y
        case .center:
            endF.origin = item.alert.wp_orgin
        }
        
        currentAlertEndFrame = endF
    }
}

public extension WPAlertManager {
    struct Alert {
        /// 动画类型
        let animateType: WPAlertManager.AnimateType
        /// 弹窗开始位置
        let startLocation: WPAlertManager.BeginLocation
        /// 弹窗弹出的时间
        let startDuration: TimeInterval
        /// 弹窗结束位置
        let stopLocation: WPAlertManager.EndLocation
        /// 弹窗结束的时间
        let stopDuration: TimeInterval
        
        /// 初始化一个弹窗信息
        /// - Parameters:
        ///   - animateType: 动画类型
        ///   - startLocation: 开始弹出的位置
        ///   - startDuration: 开始动画时间
        ///   - stopLocation: 结束弹出的位置
        ///   - stopDuration: 结束动画时间
        public init(_ animateType: WPAlertManager.AnimateType,
                    startLocation: WPAlertManager.BeginLocation,
                    startDuration: TimeInterval,
                    stopLocation: WPAlertManager.EndLocation,
                    stopDuration: TimeInterval)
        {
            self.animateType = animateType
            self.startLocation = startLocation
            self.startDuration = startDuration
            self.stopLocation = stopLocation
            self.stopDuration = stopDuration
        }
    }
    
    struct Mask {
        /// 蒙板颜色
        public let color: UIColor
        /// 是否可以交互点击
        public let enabled: Bool
        /// 是否显示
        public let isHidden: Bool
        
        /// 初始化一个蒙版信息
        /// - Parameters:
        ///   - color: 蒙板颜色
        ///   - enabled: 是否可以交互点击
        ///   - isHidden: 是否隐藏
        public init(color: UIColor, enabled: Bool, isHidden: Bool) {
            self.color = color
            self.enabled = enabled
            self.isHidden = isHidden
        }
    }
    
    enum Progress {
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
    enum AnimateType {
        /// 默认
        case `default`
        /// 弹簧效果
        case bounces
    }
    
    /// 弹窗开始位置
    enum BeginLocation {
        /// 顶部弹出
        case top(_ offset: CGPoint = .zero)
        /// 左边弹出
        case left(_ offset: CGPoint = .zero)
        /// 底部弹出
        case bottom(_ offset: CGPoint = .zero)
        /// 右边弹出
        case right(_ offset: CGPoint = .zero)
        /// 中间弹出
        case center(_ offset: CGPoint = .zero)
        /// 顶部弹出 layout模式下width填充至弹窗的width
        case topWidthToFill(_ offsetY: CGFloat = 0)
        /// 左边弹出 layout模式下height填充至弹窗的height
        case leftHeightToFill(_ offsetX: CGFloat = 0)
        /// 底部弹出 layout模式下width填充至弹窗的width
        case bottomWidthToFill(_ offsetY: CGFloat = 0)
        /// 右边弹出 layout模式下height填充至弹窗的height
        case rightHeightToFill(_ offsetY: CGFloat = 0)
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
    /// 蒙板视图
    let contentView = UIButton()
    /// 蒙板info
    var maskInfo: WPAlertManager.Mask {
        didSet {
            contentView.backgroundColor = maskInfo.color
            contentView.isUserInteractionEnabled = !maskInfo.enabled
            isHidden = maskInfo.isHidden
        }
    }
    
    init(maskInfo: WPAlertManager.Mask, action: (()->Void)?) {
        self.maskInfo = maskInfo
        super.init(frame: .zero)

        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.rx.controlEvent(.touchUpInside).subscribe(onNext: {
            action?()
        }).disposed(by: wp.disposeBag)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
