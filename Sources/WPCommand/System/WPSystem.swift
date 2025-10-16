//
//  WPSystem.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CoreMotion
import Photos
import RxCocoa
import RxSwift
import UIKit

open class WPSystem: NSObject {
    /// 键盘相关
    public static let keyboard: WPSystem.KeyBoard = .init()
    
    /// app相关
    public static let application: WPSystem.Appliaction = .init()
    
    /// 屏幕相关
    public static let screen: WPSystem.Screen = .init()
}

public extension WPSystem {
    /// 键盘
    struct KeyBoard {
        /// 键盘将要显示通知
        public var willShow: Observable<Notification> {
            return NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        }
        
        /// 键盘已经显示通知
        public var didShow: Observable<Notification> {
            return NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification)
        }
        
        /// 键盘将要收回通知
        public var willHide: Observable<Notification> {
            return NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        }
        
        /// 键盘已经收回通知
        public var didHide: Observable<Notification> {
            return NotificationCenter.default.rx.notification(UIResponder.keyboardDidHideNotification)
        }
        
        /// 键盘高度改变通知
        public var willChangeFrame: Observable<Notification> {
            return NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
        }
        
        /// 键盘高度已经改变通知
        public var didChangeFrame: Observable<Notification> {
            return NotificationCenter.default.rx.notification(UIResponder.keyboardDidChangeFrameNotification)
        }
        
        /// 获取目标视图与键盘顶部的Y轴差值 0 键盘收回 正数代表被键盘覆盖的差值 负数代表没有被键盘覆盖的差值
        /// - Parameters:
        ///   - veiw: 目标视图
        /// - Returns: 观察者
        public func offsetY(in view: UIView)->Observable<CGFloat> {
              weak var weakView = view
              var targetFrame: CGRect = view.wp.frameInMainWidow
           return Observable.merge(WPSystem.keyboard.willShow.map({ value in
                if targetFrame == .zero {
                    targetFrame = weakView?.wp.frameInMainWidow ?? .zero
                }
                let keyBoardEnd = (value.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect) ?? .zero
                return -(targetFrame.maxY - keyBoardEnd.minY)
            }),WPSystem.keyboard.willHide.map({ _ in
                return 0
            }))
        }
        
        /// 高度变化
        public func height(debounceTime:Int = 100)->Observable<(height:CGFloat,duration:CGFloat)>{
            return Observable.merge(Observable.merge(WPSystem.keyboard.willChangeFrame,WPSystem.keyboard.willShow).map { not in
                let endHeight = ((not.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect) ?? .zero).height
                let duration =  (not.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? CGFloat) ?? 0
                
                return (endHeight,duration)
            },WPSystem.keyboard.willHide.map({ not in
                let duration =  (not.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? CGFloat) ?? 0
                return (0,duration)
            })).debounce(.milliseconds(debounceTime), scheduler: MainScheduler.instance)
        }
    }
    
    /// app相关
    struct Appliaction {
        /// 将要进入前台
        public var willEnterForeground: Observable<Notification> {
            return NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
        }
        
        /// 已经激活app
        public var didBecomeActive: Observable<Notification> {
            return NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
        }
        
        /// 将要挂起
        public var willResignActive: Observable<Notification> {
            return NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification)
        }
        
        /// 已经进入后台
        public var didEnterBackground: Observable<Notification> {
            return NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
        }
        
        /// 将被杀死
        public var willTerminate: Observable<Notification> {
            return NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification)
        }
    }
    
    /// 屏幕相关
    struct Screen {
        /// 自定义相关
        public var custom = Custom()
        /// 系统相关
        public var system = System()
        /// 导航栏高度
        public var navigationHeight : CGFloat{
            return UIApplication.shared.statusBarFrame.size.height + UINavigationController().navigationBar.frame.size.height
        }
        /// 安全内边距
        public var safeArea : UIEdgeInsets{
            if #available(iOS 11.0, *) {
                return UIApplication.shared.delegate!.window??.safeAreaInsets ?? .zero
            } else {
                return .zero
            }
        }
        
        /// 屏幕大小
        public var size : CGSize{
            return UIScreen.main.bounds.size
        }
        
        /// 屏幕宽
        public var maxWidth:CGFloat{
            return size.width
        }
        
        /// 屏幕高
        public var maxHeight:CGFloat{
            return size.height
        }
        
        /// 是否是刘海屏
        public var isFull : Bool{
            if #available(iOS 11, *) {
                if safeArea.left > 0 || safeArea.bottom > 0 {
                    return true
                }
            }
            return false
        }
        
        /// 判断是否是16:9屏
        /// - Returns: true 是 false不是
        public var is16x9: Bool {
            let maxWidth = size.width
            let Sheight = size.height
            let maxHeight = maxWidth / 9 * 16
            let range = Sheight - maxHeight
            return range <= 2
        }
        
        /// 是否是横屏幕 根据系统手机方向判断
        public var isHorizontal: Bool {
            switch UIDevice.current.orientation {
            case .faceDown, .faceUp, .portrait, .portraitUpsideDown, .unknown:
                return false
            default:
                return true
            }
        }
        
        /// 比例
        public enum Proportion {
            /// 4:3屏幕
            case p4x3
            /// 16x9屏幕
            case p16x9
            
            /// 获取一个比例高度
            /// - Returns: 比例高度
            public var height: CGFloat {
                let maxHeight = WPSystem.screen.size.height
                let maxWidth = WPSystem.screen.size.width
                switch self {
                case .p16x9:
                    if WPSystem.screen.is16x9 {
                        return maxHeight
                    } else {
                        return maxWidth / 9 * 16
                    }
                case .p4x3:
                    return maxWidth / 3 * 4
                }
            }
        }
        
        /// 系统屏幕相关
        public struct System {
            /// 屏幕方向
            public var orientation: Observable<UIDeviceOrientation> {
                return NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification).map { _ in
                    UIDevice.current.orientation
                }
            }
        }
        
        /// 自定义屏幕相关
        public struct Custom {
            /// 灵敏度
            public var sensitivity: Double = 0.77
            /// 刷新间隔
            public var updateInterval: TimeInterval = 3
            /// 当前设备方向
            public let orientation: BehaviorRelay<UIDeviceOrientation> = .init(value: .portrait)
            /// 运动管理器
            private let motionManager = CMMotionManager()
            /// 开始捕捉重力方向
            public func openCatch() {
                /// 设置重力感应刷新时间间隔
                motionManager.gyroUpdateInterval = updateInterval
                if motionManager.isDeviceMotionAvailable {
                    // 开始实时获取数据
                    let queue = OperationQueue.current
                    
                    motionManager.startDeviceMotionUpdates(to: queue!) { motion, _ in
                        guard
                            let x = motion?.gravity.x,
                            let y = motion?.gravity.y
                        else { return }
                        
                        if fabs(y) >= fabs(x) { // 竖屏
                            if y < sensitivity { // 正
                                if orientation.value == .portrait { return }
                                orientation.accept(.portrait)
                            } else if y > -sensitivity { // 反
                                if orientation.value == .portraitUpsideDown { return }
                                orientation.accept(.portraitUpsideDown)
                            }
                        } else { // 横屏
                            if x < -sensitivity { // 左
                                if orientation.value == .landscapeLeft { return }
                                orientation.accept(.landscapeLeft)
                            } else if x > sensitivity { // 右
                                if orientation.value == .landscapeRight { return }
                                orientation.accept(.landscapeRight)
                            }
                        }
                    }
                }
            }
            
            /// 结束捕捉重力方向
            public func closeCatch() {
                motionManager.stopDeviceMotionUpdates()
            }
        }
    }
}

public extension WPSystem {
    /// 打开系统设置页面
    static func pushSystemController() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    /// 拨打电话
    /// - Parameters:
    ///   - phone: 电话
    ///   - failed: 拨打失败
    static func call(phone: String?,
                     failed: (()->Void)? = nil) {
        
        let newPhone = phone ?? ""

        let phoneStr = "tel://\(newPhone.wp.filterSpace)"
        if let phoneURL = URL(string: phoneStr), UIApplication.shared.canOpenURL(phoneURL),newPhone.count > 0 {
            UIApplication.shared.open(phoneURL,completionHandler: { res in
                if(!res){
                    failed?()
                }
            })
        } else {
            failed?()
        }
    }
    
    /// 判断是否开启定位权限
    /// - Parameters:
    ///   - open: 开启
    ///   - close: 关闭
    /// - Returns: 是否开启
    @discardableResult
    static func isOpenLocation(open: (()->Void)? = nil, close: (()->Void)? = nil)->Bool {
        let authStatus = CLLocationManager.authorizationStatus()
        let resault = (authStatus != .restricted && authStatus != .denied)
        if resault {
            open?()
        } else {
            close?()
        }
        return resault
    }
    
    /// 检测是否开启定位权限、如果没有开启权限请求授权并且继续执行闭包任务
    /// - Parameters:
    ///   - open: 开启时执行的任务
    ///   - close: 关闭时执行任务
//    static func isOpenLocationAutoTask(open: (()->Void)? = nil, close: (()->Void)? = nil) {
//        
//        let authStatus = CLLocationManager.authorizationStatus()
////        let resault = (authStatus != .restricted && authStatus != .denied)
//        
//        func requestLocation(){
//            
//            locationManager.requestWhenInUseAuthorization()
//
//            locationManager.wp.delegate.didChangeAuthorizationBlock = { _, state in
//                locationManager.wp.disposeBag = DisposeBag()
//                if state == .notDetermined { return }
//                WPGCD.main_Async {
//                    if state == .authorizedAlways || state == .authorizedWhenInUse {
//                        open?()
//                    } else {
//                        close?()
//                    }
//                }
//                locationManager.wp.delegate.didChangeAuthorizationBlock = nil
//            }
//        }
//
//        switch authStatus {
//        case .notDetermined:
//            requestLocation()
//        case .restricted,.denied:
//            close?()
//        default:
//            open?()
//        }
//
//    }
    
    /// 检测是否开启相册权限
    /// - Parameters:
    ///   - open: 开启
    ///   - close: 关闭
    /// - Returns: 是否开启
    @discardableResult
    static func isOpenAlbum(open: (()->Void)? = nil, close: (()->Void)? = nil)->Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        let resault = (authStatus != .restricted && authStatus != .denied)
        
        if authStatus == .notDetermined {
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    WPGCD.main_Async {
                        if status == .authorized || status == .limited {
                            open?()
                        } else {
                            close?()
                        }
                    }
                }
            } else {
                PHPhotoLibrary.requestAuthorization { status in
                    WPGCD.main_Async {
                        if status == .authorized {
                            open?()
                        } else {
                            close?()
                        }
                    }
                }
            }
        } else {
            if resault {
                open?()
            } else {
                close?()
            }
        }
        return resault
    }
    
    /// 判断是否有打开相机权限
    /// - Parameters:
    ///   - open: 打开
    ///   - close: 关闭
    /// - Returns: 结果
    @discardableResult
    static func isOpenCamera(open: (()->Void)? = nil, close: (()->Void)? = nil)->Bool {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        let resault = (authStatus == .authorized)
        
        if resault {
            open?()
        } else if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                WPGCD.main_Async {
                    if granted {
                        open?()
                        
                    } else {
                        close?()
                    }
                }
            })
        } else {
            close?()
        }
        return resault
    }
    
//    /// 是否打开网络
//    /// - Parameters:
//    ///   - open: 打开
//    ///   - close: 关闭
//    @discardableResult
//    static func isOpenNet(open: (()->Void)? = nil, close: (()->Void)? = nil)->Bool {
//        let mainThreeOpen = {
//            WPGCD.main_Async {
//                open?()
//            }
//        }
//        
//        let mainThreeClose = {
//            WPGCD.main_Async {
//                close?()
//            }
//        }
//        
//        let cellularData = CTCellularData()
//        cellularData.cellularDataRestrictionDidUpdateNotifier = { state in
//            if state == CTCellularDataRestrictedState.restrictedStateUnknown || state == CTCellularDataRestrictedState.notRestricted {
//                mainThreeClose()
//            } else {
//                mainThreeOpen()
//            }
//        }
//        let state = cellularData.restrictedState
//        
//        if state == CTCellularDataRestrictedState.restrictedStateUnknown || state == CTCellularDataRestrictedState.notRestricted {
//            mainThreeClose()
//            return false
//        } else {
//            mainThreeOpen()
//            return true
//        }
//    }
}
