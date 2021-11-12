//
//  WPSystem.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import AVFoundation
import CoreLocation
import CoreMotion
import CoreTelephony
import Photos
import RxCocoa
import RxSwift
import UIKit

/// 默认View边距
public let wp_viewEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16)
/// 屏幕尺寸
public var wp_Screen: CGRect {
    return UIScreen.main.bounds
}

/// 导航栏高度
public var wp_navigationHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height + UINavigationController().navigationBar.frame.size.height
/// 安全距离
public let wp_safeArea = wp_isFullScreen ? UIEdgeInsets(top: 44.0, left: 0.0, bottom: 34.0, right: 0.0) : UIEdgeInsets.zero
/// 是否是刘海屏
public var wp_isFullScreen: Bool {
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

public extension WPSystem {
    /// 当前设备类型
    static var deviceType: DeviceType {
        let modelStr = WPSystem.modelStr
        if modelStr.wp.isContent("iPhone") {
            return .iPhone
        } else if modelStr.wp.isContent("iPod") {
            return .iPod
        } else if modelStr.wp.isContent("iPad") {
            return .iPad
        } else if modelStr.wp.isContent("i386") || modelStr.wp.isContent("x86_64") {
            return .simulator
        } else {
            return .unknown
        }
    }
    
    /// 当前设备型号
    static var deviceModel: DeviceModel {
        switch WPSystem.deviceType {
        case .iPhone:
            return DeviceModel(modelNumber: WPSystem.DeviceModel.modelPhoneNum)
        case .iPod:
            return DeviceModel(modelNumber: WPSystem.DeviceModel.modeliPodNum)
        case .iPad:
            return DeviceModel(modelNumber: WPSystem.DeviceModel.modeliPadNum)
        case .simulator:
            return .simulator
        case .unknown:
            return .unknown
        }
    }
    
    /// 型号
    static var modelStr: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

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
        ///   - bag: 垃圾桶 使用rxSwift实现
        /// - Returns: 观察者
        public func offsetY(in view: UIView, bag: DisposeBag)->Observable<CGFloat> {
            var obServer: AnyObserver<CGFloat>?
            let ob: Observable<CGFloat> = .create { ob in
                obServer = ob
                return Disposables.create()
            }
            var targetFrame: CGRect = view.wp.frameInWidow
            
            WPSystem.keyboard.willShow.subscribe(onNext: { value in
                if targetFrame == .zero {
                    targetFrame = view.wp.frameInWidow
                }
                let keyBoardEnd = (value.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect) ?? .zero
                let of = -(targetFrame.maxY - keyBoardEnd.minY)
                obServer?.onNext(of)
            }).disposed(by: bag)
            
            WPSystem.keyboard.willHide.subscribe(onNext: { _ in
                obServer?.onNext(0)
            }).disposed(by: bag)
            return ob
        }
    }
    
    /// app相关
    struct Appliaction {
        /// 将要进入前台台
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
        /// 判断是否是16:9屏
        /// - Returns: true 是 false不是
        public var is16x9: Bool {
            let maxWidth = wp_Screen.width
            let Sheight = wp_Screen.height
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
                let maxHeight = wp_Screen.height
                let maxWidth = wp_Screen.width
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

let locationManager = CLLocationManager()

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
    static func callPhone(phone: String, failed: (()->Void)? = nil) {
        let phoneStr = "tel://" + phone.wp.filterSpace
        if let phoneURL = URL(string: phoneStr), UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.openURL(phoneURL)
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
    static func isOpenLocationAutoTask(open: (()->Void)? = nil, close: (()->Void)? = nil) {
        let authStatus = CLLocationManager.authorizationStatus()
        let resault = (authStatus != .restricted && authStatus != .denied)
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            locationManager.wp.delegate.didChangeAuthorizationBlock = { _, state in
                WPGCD.main_Async {
                    if state == .authorizedAlways || state == .authorizedWhenInUse {
                        open?()
                    } else {
                        close?()
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
    }
    
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
    
    /// 是否打开网络
    /// - Parameters:
    ///   - open: 打开
    ///   - close: 关闭
    @discardableResult
    static func isOpenNet(open: (()->Void)? = nil, close: (()->Void)? = nil)->Bool {
        let mainThreeOpen = {
            WPGCD.main_Async {
                open?()
            }
        }
        
        let mainThreeClose = {
            WPGCD.main_Async {
                close?()
            }
        }
        
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { state in
            if state == CTCellularDataRestrictedState.restrictedStateUnknown || state == CTCellularDataRestrictedState.notRestricted {
                mainThreeClose()
            } else {
                mainThreeOpen()
            }
        }
        let state = cellularData.restrictedState
        
        if state == CTCellularDataRestrictedState.restrictedStateUnknown || state == CTCellularDataRestrictedState.notRestricted {
            mainThreeClose()
            return false
        } else {
            mainThreeOpen()
            return true
        }
    }
}

public extension WPSystem {
    enum DeviceType {
        /// iTouch
        case iPod
        /// iPad
        case iPad
        /// 手机
        case iPhone
        /// 模拟器
        case simulator
        /// 未知
        case unknown
    }
    
    enum DeviceModel {
        case iPhone4
        case iPhone4S
        case iPhone5
        case iPhone5c
        case iPhone5s
        case iPhone6
        case iPhone6s
        case iPhone6Plus
        case iPhone6SPlus
        case iPhoneSE
        case iPhone7
        case iPhone7Plus
        case iPhone8
        case iPhone8Plus
        case iPhoneX
        case iPhoneXS
        case iPhoneXSMax
        case iPhoneXR
        case iPhone11
        case iPhone11Pro
        case iPhone11ProMax
        case iPhoneSE2
        case iPhone12Mini
        case iPhone12
        case iPhone12Pro
        case iPhone12ProMax
        case iPhone13Mini
        case iPhone13
        case iPhone13Pro
        case iPhone13ProMax
        case iPodTouch1G
        case iPodTouch2G
        case iPodTouch3G
        case iPodTouch4G
        case iPodTouch5G
        case iPodTouch6G
        case iPodTouch7G
        case iPad
        case iPad3G
        case iPad2
        case iPadMini
        case iPad3
        case iPad4
        case iPadAir
        case iPadMini2
        case iPadMini3
        case iPadMini4
        case iPadAir2
        case iPadPro_9_7
        case iPadPro_12_9
        case iPad5
        case iPadPro_12_9inch_2nd_gen
        case iPadPro_10_5inch
        case iPad6
        case iPad7
        case iPadPro_11inch
        case iPadPro_12_9inch_3rd_gen
        case iPadPro_11inch_2nd_gen
        case iPadPro_12_9inch_4th_gen
        case iPadMini5
        case unknown
        case simulator
        public init(modelNumber: Int) {
            switch WPSystem.deviceType {
            case .iPhone:
                switch modelNumber {
                case 31, 32, 33:
                    self = .iPhone4
                case 41:
                    self = .iPhone4S
                case 51, 52:
                    self = .iPhone5
                case 53, 55:
                    self = .iPhone5c
                case 61, 62:
                    self = .iPhone5s
                case 71:
                    self = .iPhone6Plus
                case 72:
                    self = .iPhone6
                case 81:
                    self = .iPhone6s
                case 82:
                    self = .iPhone6SPlus
                case 84:
                    self = .iPhoneSE
                case 91, 93:
                    self = .iPhone7
                case 92, 94:
                    self = .iPhone7Plus
                case 101, 104:
                    self = .iPhone8
                case 102, 105:
                    self = .iPhone8Plus
                case 103, 106:
                    self = .iPhoneX
                case 112:
                    self = .iPhoneXS
                case 114, 116:
                    self = .iPhoneXSMax
                case 118:
                    self = .iPhoneXR
                case 121:
                    self = .iPhone11
                case 123:
                    self = .iPhone11Pro
                case 125:
                    self = .iPhone11ProMax
                case 128:
                    self = .iPhoneSE2
                case 131:
                    self = .iPhone12Mini
                case 132:
                    self = .iPhone12
                case 133:
                    self = .iPhone12Pro
                case 134:
                    self = .iPhone12ProMax
                case 144:
                    self = .iPhone13Mini
                case 145:
                    self = .iPhone13
                case 142:
                    self = .iPhone13Pro
                case 143:
                    self = .iPhone13ProMax
                default:
                    self = .unknown
                }
            case .iPad:
                switch modelNumber {
                case 11:
                    self = .iPad
                case 12:
                    self = .iPad3G
                case 21, 22, 23, 24:
                    self = .iPad2
                case 25, 26, 27:
                    self = .iPadMini
                case 31, 32, 33:
                    self = .iPad3
                case 34, 35, 36:
                    self = .iPad4
                case 41, 42:
                    self = .iPadAir
                case 44, 45, 46:
                    self = .iPadMini2
                case 47, 48, 49:
                    self = .iPadMini3
                case 51, 52:
                    self = .iPadMini4
                case 53, 54:
                    self = .iPadAir2
                case 63, 64:
                    self = .iPadPro_9_7
                case 67, 68:
                    self = .iPadPro_12_9
                case 611, 612:
                    self = .iPad5
                case 71, 72:
                    self = .iPadPro_12_9inch_2nd_gen
                case 73, 74:
                    self = .iPadPro_10_5inch
                case 75, 76:
                    self = .iPad6
                case 711, 712:
                    self = .iPad7
                case 81, 82, 83, 84:
                    self = .iPadPro_11inch
                case 85, 86, 87, 88:
                    self = .iPadPro_12_9inch_3rd_gen
                case 89, 810:
                    self = .iPadPro_11inch_2nd_gen
                case 811, 812:
                    self = .iPadPro_12_9inch_4th_gen
                case 111:
                    self = .iPadMini5
                default:
                    self = .unknown
                }
            case .iPod:
                switch modelNumber {
                case 11:
                    self = .iPodTouch1G
                case 21:
                    self = .iPodTouch2G
                case 31:
                    self = .iPodTouch3G
                case 41:
                    self = .iPodTouch4G
                case 51:
                    self = .iPodTouch5G
                case 71:
                    self = .iPodTouch6G
                case 91:
                    self = .iPodTouch7G
                default:
                    self = .unknown
                }
            case .simulator:
                self = .simulator
            default:
                self = .unknown
            }
        }
        
        /// 判断是否是目标设备 如果当前设备是目标设备返回true 否则false
        /// - Returns: 结果
        public func isTarget(_ devices: [DeviceModel])->Bool {
            let resualt = devices.wp_isContent { elmt in
                elmt == self
            }
            return resualt
        }
        
        /// iPhone架构号码
        static var modelPhoneNum: Int {
            let num = WPSystem.modelStr.wp.filter("iPhone").wp.filter(",")
            return Int(num) ?? 0
        }
        
        /// iPod架构号
        static var modeliPodNum: Int {
            let num = WPSystem.modelStr.wp.filter("iPod").wp.filter(",")
            return Int(num) ?? 0
        }
        
        /// iPad架构号
        static var modeliPadNum: Int {
            let num = WPSystem.modelStr.wp.filter("iPad").wp.filter(",")
            return Int(num) ?? 0
        }
    }
}
