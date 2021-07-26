//
//  WPSystem.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import Photos
import CoreTelephony
import RxCocoa
import RxSwift
import CoreMotion

/// 默认View边距
public let wp_viewEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16)
/// 屏幕尺寸
public let wp_Screen = UIScreen.main.bounds
/// 导航栏高度
public var wp_navigationHeight : CGFloat =  UIApplication.shared.statusBarFrame.size.height + UINavigationController().navigationBar.frame.size.height
/// 安全距离
public let wp_safeArea = wp_isFullScreen ? UIEdgeInsets(top: 44.0, left: 0.0, bottom: 34.0, right: 0.0) : UIEdgeInsets.zero
/// 是否是刘海屏
public var wp_isFullScreen: Bool{
    if #available(iOS 11, *) {
        guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
            return false
        }
        
        if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
            print(unwrapedWindow.safeAreaInsets)
            return true
        }
    }
    return false
}


open class WPSystem: NSObject {
    
    /// 垃圾桶
    let disposeBag = DisposeBag()
    
    /// 单例
    public static var share : WPSystem = {
        let manager = WPSystem()
        return manager
    }()
    
    /// 键盘相关
    public let keyboard : WPSystem.KeyBoard = .init()
    
    /// app相关
    public let app : WPSystem.App = .init()
    
    /// 屏幕相关
    public let screen : WPSystem.Screen = .init()
}

public extension WPSystem{
    /// 键盘
    struct KeyBoard {
        /// 键盘将要显示通知
        public var willShow : Observable<Notification>{
            return NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        }
        /// 键盘已经显示通知
        public var didShow : Observable<Notification>{
            return NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification)
        }
        /// 键盘将要收回通知
        public var willHide : Observable<Notification>{
            return NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        }
        /// 键盘已经收回通知
        public var didHide : Observable<Notification>{
            return NotificationCenter.default.rx.notification(UIResponder.keyboardDidHideNotification)
        }
        /// 键盘高度改变通知
        public var willChangeFrame : Observable<Notification>{
            return NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
        }
        /// 键盘高度已经改变通知
        public var didChangeFrame : Observable<Notification>{
            return NotificationCenter.default.rx.notification(UIResponder.keyboardDidChangeFrameNotification)
        }
        
        /// 基于window中心Y获取键盘和目标视图的Y轴差值
        /// - Parameters:
        ///   - targetView: 目标view
        /// - Returns: 返回差值
        public func frameOffset(in targetView:UIView) -> Observable<CGFloat> {
            return  WPSystem.share.keyboard.didChangeFrame.map { value in
                guard
                    let endFrame = value.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
                else { return 0}
                
                let targetFrame = targetView.wp_frameInWidow
                return endFrame.origin.y - ((targetFrame.height + UIScreen.main.bounds.height) * 0.5)
            }
            
        }
    }
    
    /// app相关
    struct App {
        
        /// 将要进入前台台
        public var willEnterForeground : Observable<Notification>{
            return NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
        }
        
        /// 已经激活app
        public var  didBecomeActive : Observable<Notification>{
            return NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
        }
        
        /// 将要挂起
        public var willResignActive : Observable<Notification>{
            return NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification)
        }
        
        /// 已经进入后台
        public var didEnterBackground : Observable<Notification>{
            return NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
        }
        
        /// 将被杀死
        public var willTerminate : Observable<Notification>{
            return NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification)
        }
    }
    
    /// 屏幕相关
    struct Screen {
        /// 自定义相关
        public var custom = Custom()
        /// 系统相关
        public var system = System()
        /// 判断是否是16:9屏
        /// - Returns: true 是 false不是
        public var is16x9:Bool{
            let maxWidth = wp_Screen.width
            let Sheight = wp_Screen.height
            let maxHeight = maxWidth / 9 * 16
            let range = Sheight - maxHeight
            return range <= 2
        }
        
        /// 比例
        public enum Proportion {
            /// 4:3屏幕
            case p4x3
            /// 16x9屏幕
            case p16x9
            
            /// 获取一个比例高度
            /// - Returns: 比例高度
            public var height: CGFloat{
                let maxHeight = wp_Screen.height
                let maxWidth = wp_Screen.width
                switch self {
                case .p16x9:
                    if WPSystem.share.screen.is16x9{
                        return maxHeight
                    }else{
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
            public var orientation : Observable<UIDeviceOrientation>{
                return NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification).map { value in
                    return UIDevice.current.orientation
                }
            }
        }
        
        /// 自定义屏幕相关
        public struct Custom {
            /// 灵敏度
            public var sensitivity : Double  = 0.77
            /// 刷新间隔
            public var updateInterval : TimeInterval = 3
            /// 当前设备方向
            public let orientation : BehaviorRelay<UIDeviceOrientation> = .init(value: .portrait)
            /// 运动管理器
            private let motionManager = CMMotionManager()
            /// 开始捕捉重力方向
            public func openCatch(){
                ///设置重力感应刷新时间间隔
                motionManager.gyroUpdateInterval = updateInterval
                if motionManager.isDeviceMotionAvailable{
                    //开始实时获取数据
                    let queue = OperationQueue.current
                    
                    motionManager.startDeviceMotionUpdates(to: queue!) { motion, error in
                        guard
                            let x = motion?.gravity.x,
                            let y = motion?.gravity.y
                        else { return }
                        
                        if (fabs(y) >= fabs(x)) {// 竖屏
                            if (y < sensitivity) { // 正
                                if orientation.value == .portrait { return }
                                orientation.accept(.portrait)
                            }else if y > -sensitivity { // 反
                                if orientation.value == .portraitUpsideDown { return }
                                orientation.accept(.portraitUpsideDown)
                            }
                        }else { // 横屏
                            if (x < -sensitivity) { // 左
                                if orientation.value == .landscapeLeft { return }
                                orientation.accept(.landscapeLeft)
                            }else if x > sensitivity { // 右
                                if orientation.value == .landscapeRight { return }
                                orientation.accept(.landscapeRight)
                            }
                        }
                    }
                }
            }
            /// 结束捕捉重力方向
            public func closeCatch(){
                motionManager.stopDeviceMotionUpdates()
            }
            
        }
    }
}

public extension WPSystem{
    
    /// 打开系统设置页面
    func pushSystemController(){
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
    func callPhone(phone:String,failed:(()->Void)? = nil){
        let phoneStr = "tel://" + phone.wp_filterSpace
        if let phoneURL = URL(string: phoneStr), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.openURL(phoneURL)
        }else{
            failed != nil ? failed!() : print("")
        }
    }
    
    /// 检测是否开启定位权限
    /// - Parameters:
    ///   - open: 开启
    ///   - close: 关闭
    /// - Returns: 是否开启
    func isOpenLocation(open:(()->Void)?=nil,close:(()->Void)?=nil){
        let authStatus = CLLocationManager.authorizationStatus()
        let resault = (authStatus != .restricted && authStatus != .denied)
        if resault {
            open != nil ? open!() : print()
        }else{
            close != nil ? close!() : print()
        }
    }
    
    /// 检测是否开启相册权限
    /// - Parameters:
    ///   - open: 开启
    ///   - close: 关闭
    /// - Returns: 是否开启
    func isOpenAlbum(open:(()->Void)?=nil,close:(()->Void)?=nil){
        let authStatus = PHPhotoLibrary.authorizationStatus()
        let resault = (authStatus != .restricted && authStatus != .denied)
        
        if authStatus == .notDetermined {
            if #available(iOS 14, *){
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    
                    DispatchQueue.main.async {
                        if status == .authorized || status == .limited{
                            open != nil ? open!() : print()
                        }else{
                            close != nil ? close!() : print()
                        }
                    }
                }
            }  else{
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        if status == .authorized{
                            open != nil ? open!() : print()
                        }else{
                            close != nil ? close!() : print()
                        }
                    }
                }
            }
        }else{
            if resault {
                open != nil ? open!() : print()
            }else{
                close != nil ? close!() : print()
            }
        }
    }
    
    /// 判断是否有打开相机权限
    /// - Parameters:
    ///   - open: 打开
    ///   - close: 关闭
    /// - Returns: 结果
    func isOpenCamera(open:(()->Void)?=nil,close:(()->Void)?=nil){
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        let resault = (authStatus == .authorized)
        
        if resault {
            open != nil ? open!() : print("")
        }else if authStatus == .notDetermined{
            AVCaptureDevice .requestAccess(for: .video, completionHandler: { granted in
                if granted{
                    DispatchQueue.main.async {
                        open != nil ? open!() : print("")
                    }
                }else{
                    DispatchQueue.main.async {
                        close != nil ? close!() : print("")
                    }
                }
            })
        }else{
            close != nil ? close!() : print("")
        }
    }
    
    /// 是否打开网络
    /// - Parameters:
    ///   - open: 打开
    ///   - close: 关闭
    func isOpenNet(open:(()->Void)?=nil,close:(()->Void)?=nil){
        let mainThreeOpen = {
            DispatchQueue.main.sync {
                open != nil ? open!() : print()
            }
        }
        
        let mainThreeClose = {
            DispatchQueue.main.sync {
                close != nil ? close!() : print()
            }
        }
        
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { (state) in
            if state == CTCellularDataRestrictedState.restrictedStateUnknown ||  state == CTCellularDataRestrictedState.notRestricted {
                mainThreeClose()
            } else {
                mainThreeOpen()
            }
        }
        let state = cellularData.restrictedState
        if state == CTCellularDataRestrictedState.restrictedStateUnknown ||  state == CTCellularDataRestrictedState.notRestricted {
            mainThreeClose()
        } else {
            mainThreeOpen()
        }
    }
}

