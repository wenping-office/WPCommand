//
//  WPAlertManager.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/2.
//

import RxSwift
import UIKit

public extension WPQueueAlertCenter {
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

public extension WPQueueAlertCenter {
    struct Alert {
        /// 动画类型
        public let animationType: AnimationType
        /// 弹窗显示的位置
        public let location: ShowLocation
        /// 弹窗显示的时间
        public let showDuration: TimeInterval
        /// 弹窗dismiss的方向
        public let direction: DismissDirection
        /// 弹窗dismiss的时间
        public let dismissDuration: TimeInterval
        
        /// 初始化一个弹窗信息
        /// - Parameters:
        ///   - animationType: 动画类型
        ///   - location: 开始弹出的位置
        ///   - showDuration: 开始动画时间
        ///   - direction: 结束弹出的位置
        ///   - dismissDuration: 结束动画时间
        public init(_ animationType: AnimationType,
                    location: ShowLocation,
                    showDuration: TimeInterval,
                    direction: DismissDirection,
                    dismissDuration: TimeInterval)
        {
            self.animationType = animationType
            self.location = location
            self.showDuration = showDuration
            self.direction = direction
            self.dismissDuration = dismissDuration
        }
    }
    
    struct Mask {
        /// 蒙板颜色
        public let color: UIColor
        /// 是否可以交互点击
        public let enabled: Bool
        /// 是否显示
        public let hidden: Bool
        
        /// 初始化一个蒙层信息
        /// - Parameters:
        ///   - color: 蒙板颜色
        ///   - enabled: 是否可以交互点击
        ///   - hidden: 是否隐藏
        public init(color: UIColor,
                    enabled: Bool,
                    hidden: Bool) {
            self.color = color
            self.enabled = enabled
            self.hidden = hidden
        }
    }
    
    enum State {
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
    enum AnimationType {
        /// 默认
        case `default`
        /// 弹簧效果 damping 阻尼系数: 取值(0~1)默认0.5  velocity初始速度:  取值(0~1)默认0.5  options: 动画选择
        case bounces(damping: CGFloat = 0.5,
                     velocity: CGFloat = 0.5,
                     options: UIView.AnimationOptions = .curveLinear)
    }
    
    /// 显示位置
    enum ShowLocation {
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
        /// 顶部弹出 并且width填充至弹窗TargetView的width
        case topToFill(_ offsetY: CGFloat = 0)
        /// 左边弹出 并且height填充至弹窗TargetView的height
        case leftToFill(_ offsetX: CGFloat = 0)
        /// 底部弹出 并且width填充至弹窗TargetView的width
        case bottomToFill(_ offsetY: CGFloat = 0)
        /// 右边弹出 并且height填充至弹窗TargetView的height
        case rightToFill(_ offsetY: CGFloat = 0)
    }
    
    /// 弹出方向
    enum DismissDirection {
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

/// 可弹出一组弹窗或插入式弹窗，也可自定义一个manager自己管理一组弹窗
public class WPQueueAlertCenter {
    /// 弹窗
    private class Item {
        /// 弹窗
        let alert: WPQueueAlertable
        /// 弹窗等级
        let level: Int
        /// 是否被中断动画并且被插入到当前位置
        var isInterruptInset = false
        /// 目标视图
        weak var target: UIView?
        /// 布局方式
        var layoutOption: LayoutOption?
        /// 弹窗状态
        var state: State = .unknown {
            didSet {
                alert.stateHandler?(state)
                alert.stateDidUpdate(state: state)
                alert.currentAlertState = state
                stateChange?(state)
            }
        }

        /// 弹窗的偏移量
        var offset: CGPoint = .zero
        /// 状态变化
        var stateChange: ((State)->Void)?
        
        init(alert: WPQueueAlertable, level: Int) {
            self.alert = alert
            self.level = level
        }
    }

    /// 弹窗视图
    private weak var current: Item?
    /// 弹窗的根视图
    private weak var target: UIView? {
        willSet {
            removeMask()
        }
    }

    /// 弹窗弹出的根视图
    private var targetView: UIView {
        if target == nil {
            return UIApplication.wp.keyWindow!
        } else {
            return target!
        }
    }

    /// 当前弹窗的mask
    private weak var maskView: WPAlertManagerMask?
    /// 弹窗队列
    private var alerts: [Item] = [] {
        didSet {
            alerts.sort { elmt1, elmt2 in
                elmt1.level < elmt2.level
            }
        }
    }

    /// 当前弹窗开始的frame
    private var showFrame: CGRect = .zero
    /// 当前弹窗结束的frame
    private var dismissFrame: CGRect = .zero
    /// 自动布局下的block
    private var layoutShowBlock: (()->Void)?

    /// 单例
    public static var `default`: WPQueueAlertCenter = {
        let manager = WPQueueAlertCenter()
        return manager
    }()

    public init() {}

    /// 添加一个弹窗
    public func add(alert: WPQueueAlertable) {
        alert.tag = WPQueueAlertCenter.identification()
        let alertItem: Item = .init(alert: alert, level: Int(alert.alertLevel()))
        alertItem.state = .cooling
        alerts.append(alertItem)
    }
    
    /// 移除一个弹窗
    public func remove(alert: WPQueueAlertable) {
        current = nil
        (alert as UIView).wp.removeFromSuperview()
        alerts.wp_filter(exclude: { $0.alert.tag == alert.tag})
        alert.stateDidUpdate(state: .remove)
        alert.stateHandler?(.remove)

        let keepAlerts = alerts.wp.elements(where: { $0.isInterruptInset})
        let normalAlerts = alerts.wp.elements(where: {!$0.isInterruptInset})
        let allAlerts = keepAlerts + normalAlerts
        current = allAlerts.first
    }
    
    /// 移除所有弹窗
    public func removeAllAlert() {
        current?.alert.removeFromSuperview()
        
        alerts.forEach { item in
            item.state = .remove
        }
        alerts = []
        
        target = nil
    }

    /// 添加一组弹窗会清除现有的弹窗
    /// - Parameter alerts: 弹窗
    @discardableResult
    public func set(alerts: [WPQueueAlertable])->WPQueueAlertCenter {
        self.alerts = []
        alerts.forEach { [weak self] elmt in
            self?.add(alert: elmt)
        }
        return self
    }
    
    /// 弹出一个弹窗 如果序列里有多个弹窗将会插入到下一个
    /// - Parameters:
    ///   - alert: 弹窗
    ///   - option: 选择条件
    public func show(next alert: WPQueueAlertable, option: Option = .insert(keep: true)) {
        alert.tag = WPQueueAlertCenter.identification()
        let level = (current?.level ?? 0) - 1
        let alertItem: Item = .init(alert: alert, level: level)
        alertItem.target = alert.targetView
        
        switch option {
        case .add:
            alerts.append(alertItem)
        case .insert(_):
            alerts.insert(alertItem, at: 0)
        }

        alertItem.state = .cooling

        if current == nil {
            show()
        } else {
            switch option {
            case .add:
                break
            case .insert(let keep):
                switch current!.state {
                case .willShow:
                    current?.stateChange = { [weak self] state in
                        if state == .didShow {
                            self?.current?.isInterruptInset = keep
                            self?.alertAnimation(isShow: false, option: option)
                        }
                        self?.current?.stateChange = nil
                    }
                case .didShow:
                    current?.stateChange = nil
                    current?.isInterruptInset = keep
                    alertAnimation(isShow: false, option: option)
                default: break
                }
            }
        }
//        if currentAlertProgress == .didShow, alerts.count >= 1 {
//            switch option {
//            case .insert(let keep):
//                current?.isInterruptInset = keep
//                alertAnimate(isShow: false, option: option)
//            default: break
//            }
//        } else {
//            alertAnimate(isShow: true, option: .add)
//        }
    }
    
    /// 隐藏当前的弹框 如果弹框序列里还有弹窗将会弹出下一个
    public func dismiss() {
        alertAnimation(isShow: false, option: .add)
    }
    
    /// 显示弹窗
    public func show() {
        alertAnimation(isShow: true, option: .add)
    }
    
    /// 更新当前弹窗的size 如果更新后view 被截断请检查是否设置了layer.mask 如果设置了需要手动重新绘制
    /// - Parameters:
    ///   - duration: 动画时间
    ///   - size: 如果是frame布局的弹窗才需要填
    public func update(size:CGSize = .zero,
                       _ animationType: AnimationType = .default,
                       _ duration:TimeInterval = 0.2){
        guard
            let alertItem = current,
            let layoutOption = alertItem.layoutOption
        else { return }

        switch layoutOption {
        case .frame(let alertSize):
            let alertOrgin = alertItem.alert.wp_orgin
            var newSize = alertSize
            newSize.width += size.width
            newSize.height += size.height
            alertItem.layoutOption = .frame(size: newSize)
            resetFrame(alertItem)
            alertItem.alert.wp_orgin = alertOrgin
        case .layout: break
        }

        animation(animationType, duration: duration, animation: {[weak self] in
            guard
                let self = self
            else { return }
            switch layoutOption {
            case .frame(_):
                alertItem.alert.frame = self.showFrame
            case .layout:
                alertItem.alert.superview?.layoutIfNeeded()
            }
        }, completion: { [weak self] resualt in
            self?.resetEndFrame(alertItem)
        })
    }
    
    /// 更新偏移量  如果更新后view 被截断请检查是否设置了layer.mask 如果设置了需要手动重新绘制
    /// - Parameters:
    ///   - animateType: 动画类型
    ///   - duration: 动画时间
    ///   - offset: 偏移量 注：如果是tofill 那么只有x或者y生效
    public func update(offset:CGPoint,
                       _ animateType: AnimationType = .default,
                       _ duration:TimeInterval = 0.2){
        guard
            let alertItem = current,
            let layoutOption = alertItem.layoutOption
        else { return }

        switch layoutOption {
        case .frame(_):
            let alertFrame = alertItem.alert.frame
            resetFrame(alertItem)
            alertItem.alert.transform = CGAffineTransform.identity
            alertItem.alert.alpha = 1
            var newFrame = showFrame
            newFrame.origin.y = newFrame.origin.y + offset.y
            newFrame.origin.x = newFrame.origin.x + offset.x
            newFrame.size = alertFrame.size
            showFrame = newFrame
            alertItem.alert.frame = alertFrame
        case .layout:
            switch alertItem.alert.alertInfo().location {
            case .top(let normalOffset):
                alertItem.alert.snp.updateConstraints({ make in
                    make.centerX.equalToSuperview().offset(offset.x + normalOffset.x)
                    make.top.equalToSuperview().offset(offset.y + normalOffset.y)
                })
            case .topToFill(let normalOffsetY):
                alertItem.alert.snp.updateConstraints ({ make in
                    make.top.equalToSuperview().offset(offset.y + normalOffsetY)
                    make.left.right.equalToSuperview()
                })
            case .left(let normalOffset):
                alertItem.alert.snp.updateConstraints( { make in
                    make.centerY.equalToSuperview().offset(offset.y + normalOffset.y)
                    make.left.equalToSuperview().offset(offset.x + normalOffset.x)
                })
            case .leftToFill(let normalOffsetX):
                alertItem.alert.snp.updateConstraints( { make in
                    make.top.bottom.equalToSuperview()
                    make.left.equalToSuperview().offset(offset.x + normalOffsetX)
                })
            case .bottom(let normalOffset):
                alertItem.alert.snp.updateConstraints( { make in
                    make.bottom.equalToSuperview().offset(offset.y + normalOffset.y)
                    make.centerX.equalToSuperview().offset(offset.x + normalOffset.x)
                })
            case .bottomToFill(let normalOffsetY):
                alertItem.alert.snp.updateConstraints( { make in
                    make.bottom.equalToSuperview().offset(offset.y + normalOffsetY)
                    make.left.right.equalToSuperview()
                })
            case .right(let normalOffset):
                alertItem.alert.snp.updateConstraints( { make in
                    make.right.equalToSuperview().offset(offset.x + normalOffset.x)
                    make.centerY.equalToSuperview().offset(offset.y + normalOffset.y)
                })
            case .rightToFill(let normalOffsetX):
                alertItem.alert.snp.updateConstraints( { make in
                    make.right.equalToSuperview().offset(offset.x + normalOffsetX)
                    make.top.bottom.equalToSuperview()
                })
            case .center(let normalOffset):
                alertItem.alert.snp.updateConstraints( { make in
                    make.centerX.equalToSuperview().offset(offset.x + normalOffset.x)
                    make.centerY.equalToSuperview().offset(offset.y + normalOffset.y)
                })
            }
        }

        animation(animateType, duration: duration, animation:{[weak self] in
            self?.animateActuator(alertItem,
                                  isShow: true,
                                  layoutOption: layoutOption)
        }, completion: { [weak self] resualt in
            self?.resetEndFrame(alertItem)
        })
    }
}

extension WPQueueAlertCenter {
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
    
    /// 添加一个蒙层
    private func addMask(info: WPQueueAlertCenter.Mask) {
        let resualt = targetView.subviews.contains(where: { $0.isKind(of: WPAlertManagerMask.self)})

        // 如果没有蒙层 那么添加一个
        if !resualt {
            let maskView = WPAlertManagerMask(maskInfo: info, action: { [weak self] in
                if self?.current?.state == .didShow {
                    self?.current?.alert.touchMask()
                }
            })
            self.maskView = maskView
            maskView.contentView.alpha = 0
            targetView.insertSubview(maskView, at: 999)
            maskView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    /// 动画节点
    /// - Parameters:
    ///   - item: alert
    ///   - isShow: 是否是显示
    ///   - layoutOption: 布局方式
    private func animateActuator(_ item:Item,
                                 isShow:Bool,
                                 layoutOption:LayoutOption){
        item.alert.transform = CGAffineTransform.identity
        if isShow {
            switch layoutOption {
            case .layout:
                item.alert.superview?.layoutIfNeeded()
            case .frame:
                item.alert.frame = showFrame
            }
            item.alert.alpha = 1
            self.maskView?.contentView.alpha = 1
        } else {
            switch layoutOption {
            case .layout: // 这样做是零时解决办法
                item.alert.frame = dismissFrame
            case .frame:
                item.alert.frame = dismissFrame
            }
            if !self.isNext() {
                self.maskView?.contentView.alpha = 0
            }
            
            if item.alert.alertInfo().direction == .center {
                item.alert.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }
        }
    }
    
    /// 动画执行结果
    /// - Parameters:
    ///   - item: alert
    ///   - resualt: 结果
    ///   - isShow: 是否是显示
    private func animationActuatorComplete(_ item:Item,
                                           resualt:Bool,
                                           isShow:Bool){
        if resualt {
            if isShow {
                item.isInterruptInset = false
                layoutShowBlock = nil
                resetEndFrame(item)
                current?.state = .didShow
            } else {
                if !item.isInterruptInset { // 正常弹出才更新状态
                    current?.state = .didPop
                    remove(alert: item.alert)
                } else {
                    moveItemToFist(item)
                }
                show()
            }
        } else {
            current?.state = .unknown
        }
    }
    
    /// 执行动画
    private func animation(_ type:AnimationType,
                           duration:TimeInterval,
                           checkTranslatesAuto:Bool = false,
                           animation:@escaping ()->Void,
                           completion:@escaping(Bool)->Void){
        
//        let translatesAutoresizingMaskIntoConstraints = current?.alert.translatesAutoresizingMaskIntoConstraints
//        var isChange = false
//        
//        if translatesAutoresizingMaskIntoConstraints == false && checkTranslatesAuto{
//            current?.alert.translatesAutoresizingMaskIntoConstraints = true
//            isChange = true
//        }

        switch type {
        case .default:
            UIView.animate(withDuration: duration, animations: {
                animation()
            }, completion: {[weak self] resualt in
                completion(resualt)
//                if isChange && checkTranslatesAuto{
//                    self?.current?.alert.translatesAutoresizingMaskIntoConstraints = false
//                }
            })
        case .bounces(let damping, let velocity, let options):
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: options, animations: {
                animation()
            }, completion: {[weak self] resualt in
                completion(resualt)
//                if isChange && checkTranslatesAuto{
//                    self?.current?.alert.translatesAutoresizingMaskIntoConstraints = false
//                }
            })
        }
    }

    /// 删除蒙层
    private func removeMask() {
        maskView?.wp.removeFromSuperview()
        maskView = nil
    }
    
    /// 判断是否还有下一个弹窗
    private func isNext()->Bool {
        let count = alerts.count
        return (count - 1) > 0
    }
    
    /// 移动一个item并插入到插入队列的第一个
    private func moveItemToFist(_ item: Item) {
        current = nil
        (item.alert as UIView).wp.removeFromSuperview()
        alerts.wp_filter(exclude: { $0.alert.tag == item.alert.tag})
        
        current = alerts.first
        
        item.alert.wp_size = .zero
        alerts.append(item)
    }

    /// 执行弹窗动画
    /// - Parameters:
    ///   - isShow: 是显示还是移除
    ///   - option: 选择
    private func alertAnimation(isShow: Bool, option: Option) {
        if let item = current {
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
                    layoutShowBlock?()
                default: break
                }

                maskView?.maskInfo = item.alert.maskInfo()
                current?.state = .willShow
                item.target = target
            } else {
                current?.state = .willPop
            }
            
            // 动画时间
            var duration: TimeInterval = 0
            switch option {
            case .add:
                duration = (isShow ? item.alert.alertInfo().showDuration : item.alert.alertInfo().dismissDuration)
            case .insert:
                duration = 0
            }
            
            animation(item.alert.alertInfo().animationType,
                      duration: duration, checkTranslatesAuto: !isShow) {[weak self] in
                self?.animateActuator(item,
                                      isShow: isShow,
                                      layoutOption: layoutOption)
            } completion: {[weak self] resualt in
                self?.animationActuatorComplete(item,
                                                resualt: resualt,
                                                isShow: isShow)
            }

        } else {
            current = alerts.first
            if current != nil {
                show()
            } else {
                removeMask()
            }
        }
    }
    
    /// 计算弹窗的位置
    @discardableResult
    private func resetFrame(_ item: Item)->LayoutOption {
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
        
        switch item.alert.alertInfo().location {
        case .top(let offset):
            item.offset = offset
            switch item.layoutOption! {
            case .layout:
                item.alert.snp.remakeConstraints { make in
                    make.centerX.equalToSuperview().offset(offset.x)
                    make.bottom.equalTo(targetView.snp.top)
                }
                layoutShowBlock = {
                    item.alert.snp.remakeConstraints { make in
                        make.centerX.equalToSuperview().offset(offset.x).priority(.medium)
                        make.top.equalToSuperview().offset(offset.y).priority(.medium)
                    }
                }
            case .frame:
                beginF.origin.x = center.x + offset.x
                beginF.origin.y = 0 + offset.y
                item.alert.wp_x = center.x + offset.x
                item.alert.wp_y = -alertH + offset.y
            }
        case .topToFill(let offsetY):
            item.offset = .init(x: 0, y: offsetY)
            item.alert.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(targetView.snp.top)
            }
            layoutShowBlock = {
                item.alert.snp.remakeConstraints { make in
                    make.top.equalToSuperview().offset(offsetY).priority(.medium)
                    make.left.right.equalToSuperview().priority(.medium)
                }
            }
        case .left(let offset):
            item.offset = offset
            
            switch item.layoutOption! {
            case .layout:
                item.alert.snp.remakeConstraints { make in
                    make.right.equalTo(targetView.snp.left)
                    make.centerY.equalToSuperview().offset(offset.y)
                }
                layoutShowBlock = {
                    item.alert.snp.remakeConstraints { make in
                        make.centerY.equalToSuperview().offset(offset.y).priority(.medium)
                        make.left.equalToSuperview().offset(offset.x).priority(.medium)
                    }
                }
            case .frame:
                beginF.origin.x = 0 + offset.x
                beginF.origin.y = center.y + offset.y
                item.alert.wp_x = -alertW + offset.x
                item.alert.wp_y = center.y + offset.y
            }

        case .leftToFill(let offsetX):
            item.offset = .init(x: offsetX, y: 0)
            item.alert.snp.remakeConstraints { make in
                make.right.equalTo(targetView.snp.left)
                make.top.bottom.equalToSuperview()
            }
            layoutShowBlock = {
                item.alert.snp.remakeConstraints { make in
                    make.top.bottom.equalToSuperview().priority(.medium)
                    make.left.equalToSuperview().offset(offsetX).priority(.medium)
                }
            }
        case .bottom(let offset):
            item.offset = offset
            switch item.layoutOption! {
            case .layout:
                item.alert.snp.remakeConstraints { make in
                    make.top.equalTo(targetView.snp.bottom)
                    make.centerX.equalToSuperview().offset(offset.x)
                }
                layoutShowBlock = {
                    item.alert.snp.remakeConstraints { make in
                        make.bottom.equalToSuperview().offset(offset.y).priority(.medium)
                        make.centerX.equalToSuperview().offset(offset.x).priority(.medium)
                    }
                }
            case .frame:
                beginF.origin.x = center.x + offset.x
                beginF.origin.y = maxH - alertH + offset.y
                item.alert.wp_x = center.x + offset.x
                item.alert.wp_y = maxH + offset.y
            }

        case .bottomToFill(let offsetY):
            item.offset = .init(x: 0, y: offsetY)
            item.alert.snp.remakeConstraints { make in
                make.top.equalTo(targetView.snp.bottom)
                make.left.right.equalToSuperview()
            }
            layoutShowBlock = {
                item.alert.snp.remakeConstraints { make in
                    make.bottom.equalToSuperview().offset(offsetY).priority(.medium)
                    make.left.right.equalToSuperview().priority(.medium)
                }
            }
        case .right(let offset):
            item.offset = offset
            switch item.layoutOption! {
            case .layout:
                item.alert.snp.remakeConstraints { make in
                    make.left.equalTo(targetView.snp.right)
                    make.centerY.equalToSuperview().offset(offset.y)
                }
                layoutShowBlock = {
                    item.alert.snp.remakeConstraints { make in
                        make.right.equalToSuperview().offset(offset.x).priority(.medium)
                        make.centerY.equalToSuperview().offset(offset.y).priority(.medium)
                    }
                }
            case .frame:
                beginF.origin.x = maxW - alertW + offset.x
                beginF.origin.y = center.y + offset.y
                item.alert.wp_y = center.y + offset.y
                item.alert.wp_x = maxW + offset.x
            }
        case .rightToFill(let offsetY):
            item.offset = .init(x: 0, y: offsetY)
            item.alert.snp.remakeConstraints { make in
                make.left.equalTo(targetView.snp.right)
                make.top.bottom.equalToSuperview()
            }
            layoutShowBlock = {
                item.alert.snp.remakeConstraints { make in
                    make.right.equalToSuperview().offset(offsetY).priority(.medium)
                    make.top.bottom.equalToSuperview()
                }
            }
        case .center(let offset):
            item.offset = offset
            switch item.layoutOption! {
            case .layout:
                item.alert.snp.remakeConstraints { make in
                    make.centerX.equalToSuperview().offset(offset.x)
                    make.centerY.equalToSuperview().offset(offset.y)
                }
            case .frame:
                beginF.origin.x = center.x + offset.x
                beginF.origin.y = center.y + offset.y
                item.alert.alpha = 0
                item.alert.wp_orgin = beginF.origin
            }
            item.alert.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }
        
        showFrame = beginF
        
        return item.layoutOption!
    }
    
    /// 计算弹窗结束位置
    private func resetEndFrame(_ item: Item) {
        let alertW: CGFloat = item.alert.wp_width
        let alertH: CGFloat = item.alert.wp_height
        let maxW: CGFloat = targetView.wp_width
        let maxH: CGFloat = targetView.wp_height
        var endF: CGRect = .init(x: 0, y: 0, width: alertW, height: alertH)
        
        switch item.alert.alertInfo().direction {
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
        
        dismissFrame = endF
    }
}

/// 蒙层视图
class WPAlertManagerMask: UIView {
    /// 蒙板视图
    let contentView = UIButton()
    /// 蒙板info
    var maskInfo: WPQueueAlertCenter.Mask {
        didSet {
            contentView.backgroundColor = maskInfo.color
            contentView.isUserInteractionEnabled = !maskInfo.enabled
            isHidden = maskInfo.hidden
        }
    }
    
    init(maskInfo: WPQueueAlertCenter.Mask, action: (()->Void)?) {
        self.maskInfo = maskInfo
        super.init(frame: .zero)

        addSubview(contentView)
        contentView.rx.controlEvent(.touchUpInside).subscribe(onNext: {
            action?()
        }).disposed(by: wp.disposeBag)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
}
