//
//  CLLocationManager+Ex.swift
//  MJRefresh
//
//  Created by WenPing on 2021/11/12.
//

import UIKit
import CoreLocation
import RxSwift

public class WPLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    /// 位置已经刷新Rx
    public let didUpdateLocationsSubject: PublishSubject<(manager: CLLocationManager, locations: [CLLocation])> = .init()
    /// 位置已经刷新
    public var didUpdateLocationsBlock: ((CLLocationManager, [CLLocation])->Void)?
    /// 方向已经刷新Rx
    public let didUpdateHeadingSubject: PublishSubject<(manager: CLLocationManager, heading: CLHeading)> = .init()
    /// 方向已经刷新
    public var didUpdateHeadingBlock: ((CLLocationManager, CLHeading)->Void)?
    
    public let didDetermineStateSubject: PublishSubject<(manager: CLLocationManager, state: CLRegionState, region: CLRegion)> = .init()
    public var didDetermineStateBlock: ((CLLocationManager, CLRegionState, CLRegion)->Void)?
    
    public let didRangeBeaconsSubject: PublishSubject<(manager: CLLocationManager, beacons: [CLBeacon], region: CLBeaconRegion)> = .init()
    public var didRangeBeaconsBlock: ((CLLocationManager, [CLBeacon], CLBeaconRegion)->Void)?
    
    public let rangingBeaconsDidFailForSubject: PublishSubject<(manager: CLLocationManager, region: CLBeaconRegion, error: Error)> = .init()
    public var rangingBeaconsDidFailForBlock: ((CLLocationManager, CLBeaconRegion, Error)->Void)?
    
    /// 进入指定区域
    public let didEnterRegionSubject: PublishSubject<(manager: CLLocationManager, region: CLRegion)> = .init()
    /// 进入指定区域
    public var didEnterRegionBlock: ((CLLocationManager, CLRegion)->Void)?
    /// 离开指定区域
    public let didExitRegionSubject: PublishSubject<(manager: CLLocationManager, region: CLRegion)> = .init()
    /// 离开指定区域
    public var didExitRegionBlock: ((CLLocationManager, CLRegion)->Void)?
    
    public let didFailWithErrorSubject: PublishSubject<(manager: CLLocationManager, error: Error)> = .init()
    public var didFailWithErrorBlock: ((CLLocationManager, Error)->Void)?
    
    /// 区域定位失败
    public let monitoringDidFailForSubject: PublishSubject<(manager: CLLocationManager, region: CLRegion?, error: Error)> = .init()
    /// 区域定位失败
    public let monitoringDidFailForBlock: ((CLLocationManager, CLRegion?, Error)->Void)? = nil
    /// 授权状态改变
    public let didChangeAuthorizationSubject: PublishSubject<(manager: CLLocationManager, state: CLAuthorizationStatus)> = .init()
    /// 授权状态改变
    public var didChangeAuthorizationBlock: ((CLLocationManager, CLAuthorizationStatus)->Void)?
        = nil
    public let locationManagerDidChangeAuthorizationSubject: PublishSubject<CLLocationManager> = .init()
    public var locationManagerDidChangeAuthorizationBlock: ((CLLocationManager)->Void)?
    /// 开始控制指定区域
    public let didStartMonitoringForSubject: PublishSubject<(manager: CLLocationManager, region: CLRegion)> = .init()
    /// 开始控制指定区域
    public let didStartMonitoringForBlock: ((CLLocationManager, CLRegion)->Void)? = nil
    /// 已经停止位置更新
    public let didPauseLocationUpdatesSubject: PublishSubject<CLLocationManager> = .init()
    /// 已经停止位置更新
    public var didPauseLocationUpdatesBlock: ((CLLocationManager)->Void)?
    /// 位置定位重新开始定位位置的更新
    public let didResumeLocationUpdatesSubject: PublishSubject<CLLocationManager> = .init()
    /// 位置定位重新开始定位位置的更新
    public var didResumeLocationUpdatesBlock: ((CLLocationManager)->Void)?
    /// 已经完成了推迟的更新
    public let didFinishDeferredUpdatesWithErrorSubject: PublishSubject<(manager: CLLocationManager, error: Error?)> = .init()
    /// 已经完成了推迟的更新
    public var didFinishDeferredUpdatesWithErrorBlock: ((CLLocationManager, Error?)->Void)?
    /// 已经访问过的位置
    public let didVisitSubject: PublishSubject<(manager: CLLocationManager, visit: CLVisit)> = .init()
    /// 已经访问过的位置
    public var didVisitBlock: ((CLLocationManager, CLVisit)->Void)?
    
    /// 位置即将更新
    /// - Parameters:
    ///   - manager: manager
    ///   - locations: 位置
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocationsBlock?(manager, locations)
        didUpdateLocationsSubject.onNext((manager, locations))
    }
    
    /// 方向即将更新
    /// - Parameters:
    ///   - manager: manager
    ///   - newHeading: 方向
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        didUpdateHeadingBlock?(manager, newHeading)
        didUpdateHeadingSubject.onNext((manager, newHeading))
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        didDetermineStateBlock?(manager, state, region)
        didDetermineStateSubject.onNext((manager, state, region))
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        didRangeBeaconsBlock?(manager, beacons, region)
        didRangeBeaconsSubject.onNext((manager, beacons, region))
    }
    
    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        rangingBeaconsDidFailForBlock?(manager, region, error)
        rangingBeaconsDidFailForSubject.onNext((manager, region, error))
    }
    
    @available(iOS 13.0, *)
    public func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
    }
    
    @available(iOS 13.0, *)
    public func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
    }
    
    /// 进入指定区域
    /// - Parameters:
    ///   - manager: manager
    ///   - region: 区域
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        didEnterRegionBlock?(manager, region)
        didEnterRegionSubject.onNext((manager, region))
    }
    
    /// 离开指定区域
    /// - Parameters:
    ///   - manager: manager
    ///   - region: 区域
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        didExitRegionBlock?(manager, region)
        didExitRegionSubject.onNext((manager, region))
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailWithErrorBlock?(manager, error)
        didFailWithErrorSubject.onNext((manager, error))
    }
    
    /// 区域定位失败
    /// - Parameters:
    ///   - manager: manager
    ///   - region: 区域
    ///   - error: 错误
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        monitoringDidFailForBlock?(manager, region, error)
        monitoringDidFailForSubject.onNext((manager, region, error))
    }
    
    /// 授权状态改变
    /// - Parameters:
    ///   - manager: manager
    ///   - status: 授权状态改变
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorizationBlock?(manager, status)
        didChangeAuthorizationSubject.onNext((manager, status))
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManagerDidChangeAuthorizationBlock?(manager)
        locationManagerDidChangeAuthorizationSubject.onNext(manager)
    }
    
    /// 开始控制指定区域
    /// - Parameters:
    ///   - manager: manager
    ///   - region: 区域
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        didStartMonitoringForBlock?(manager, region)
        didStartMonitoringForSubject.onNext((manager, region))
    }
    
    /// 已经停止位置更新
    /// - Parameter manager: manager
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        didPauseLocationUpdatesBlock?(manager)
        didPauseLocationUpdatesSubject.onNext(manager)
    }
    
    /// 位置定位重新开始定位位置的更新
    /// - Parameter manager: manager
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        didResumeLocationUpdatesBlock?(manager)
        didResumeLocationUpdatesSubject.onNext(manager)
    }
    
    /// 已经完成了推迟更新
    /// - Parameters:
    ///   - manager: manager
    ///   - error: 错误
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        didFinishDeferredUpdatesWithErrorBlock?(manager, error)
        didFinishDeferredUpdatesWithErrorSubject.onNext((manager, error))
    }
    
    /// 已经访问过的位置
    /// - Parameters:
    ///   - manager: manager
    ///   - visit: visit
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        didVisitBlock?(manager, visit)
        didVisitSubject.onNext((manager, visit))
    }
}

private var WPLocationManagerDelegatePointer = "WPLocationManagerDelegatePointer"

public extension CLLocationManager {
    /// 桥接代理
    var wp_delegate: WPLocationManagerDelegate {
        set {
            WPRunTime.set(self, newValue, &WPLocationManagerDelegatePointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = newValue
        }
        get {
            guard let wp_delegate: WPLocationManagerDelegate = WPRunTime.get(self, &WPLocationManagerDelegatePointer) else {
                let wp_delegate = WPLocationManagerDelegate()
                self.wp_delegate = wp_delegate
                return wp_delegate
            }
            return wp_delegate
        }
    }
}

public extension WPSpace where Base: CLLocationManager {
    /// 桥接代理
    var delegate: WPLocationManagerDelegate {
        return base.wp_delegate
    }
}
