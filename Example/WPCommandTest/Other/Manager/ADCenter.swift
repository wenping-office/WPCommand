//
//  ADCenter.swift
//  CineMate
//
//  Created by tmb on 2026/3/27.
//

import UIKit
/*
import WPCommand
import Combine
import GoogleMobileAds
import SnapKit
import CombineExt
import FBSDKCoreKit

extension ADCenter{
    enum ShowState {
       case willShow
       case didShow
       case click
       case userDismissed
       case didDismissed
        /// 已经显示过
       case alreadyShow
       case loading
       case loadSuccess
       case loadError
       case timeOut
    }
}


class ADCenter:NSObject {
    static var `default` = ADCenter()

    /// 开屏广告
    static let openAd = AdOpenState()

    /// 初始化广告
    func start(){
        Settings.shared.isAdvertiserIDCollectionEnabled = true
        Settings.shared.isAutoLogAppEventsEnabled = true
        
        MobileAds.shared.start(completionHandler: { status in
            status.adapterStatusesByClassName.forEach { info in
                print("初始广告平台----\(info.key)\n 广告厂商状态\(info.value)\n")
            }
        })
    }

    /// 原生广告池
    private var nativeAds:[NativeAdState] = []
    
    /// 插页广告池
    private var interstitiaAds:[AdInterstitialState] = []
    
    /// 加载原生广告
    func loadNativeAd(scene:SceneType) -> AnyPublisher<NativeAdState.State,Never> {
       if let nativeAd = nativeAds.first(where: { adState in
            switch adState.state {
            case .loadSuccess:
                return true
            default:
                return false
            }
       }){
           print("使用原生广告缓存--")
           nativeAd.scene = scene
           return nativeAd.$state.handleEvents(receiveOutput: {[weak self] _ in
               self?.nativeAds.wp_filter(exclude: { $0.id == nativeAd.id})
           }).eraseToAnyPublisher()
       }else{
           let nativeAd = NativeAdState()
           nativeAd.scene = scene
           nativeAds.append(nativeAd)
           return nativeAd.load().handleEvents(receiveOutput: {[weak self] _ in
               self?.nativeAds.wp_filter(exclude: { $0.id == nativeAd.id})
           }).eraseToAnyPublisher()
       }
    }
    
    /// 缓存原生广告
    func cacheNativeAd(count:Int = 1){
        for _ in 0..<count {
            let nativeAd = NativeAdState()
            nativeAds.append(nativeAd)
            nativeAd.normalLoad()
            nativeAd.$state.sink(receiveValue: { state in
                print("缓存原生广告状态\(state)")
            }).store(in: &nativeAd.wp.cancellables.set)
        }
    }
    
    /// 显示插页广告
    func showInterstitialAd(scene:SceneType,
                            _ viewController:UIViewController? = nil,
                            willShow:(()->Void)? = nil,
                            loading:(()->Void)? = nil,
                            otherState:(()->Void)? = nil,
                            timeout:Int = 99) -> AnyPublisher<ShowState,Never> {
//#if Test // 测试代码
//        return .create { ob in
//            ob(.success(.userDismissed))
//        }
//#elseif Pro
        
        var interAd:AdInterstitialState!
        let cachad = interstitiaAds.first(where: { $0.state == .loadSuccess })
        if cachad == nil {
            interAd = AdInterstitialState()
        }else{
            interAd = cachad
            print("使用插页缓存广告")
        }

        
        if !(interstitiaAds.contains(where: { $0.id == interAd.id })){
            interstitiaAds.append(interAd)
        }
        var didFinsh = false
        
        return interAd.$state.prepend(interAd.state).removeDuplicates().flatMap({ output in
            
            return AnyPublisher<ADCenter.ShowState,Never>.create { ob in
                if output == .loading {
                    // 超时逻辑：只在加载阶段生效
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout)) {
                        if didFinsh { return }
                        didFinsh = true
                        ob(.success(.timeOut))
                        print("加载插页超时----\(interAd.id)")
                    }
                }else if output == .loadSuccess || output == .loadError{
                    if didFinsh { return }
                    ob(.success(output))
                    didFinsh = true
                }else{
                    ob(.success(output))
                }
                
                switch output {
                case .loading:
                    loading?()
                case .willShow:
                    willShow?()
                default:
                    otherState?()
                }
            }
        }).handleEvents(receiveOutput: { state in
            if state == .loadSuccess {
                interAd.show(scene: scene, viewController: nil)
            }
            if state == .didShow {
                let cachInterAd = AdInterstitialState()
                self.interstitiaAds.append(cachInterAd)
//                print("加载缓存广告---")
//                cachInterAd.$state.sink(receiveValue: { state in
//                    print("缓存插页广告状态-\(state)----\(cachInterAd.id)")
//                }).store(in: &interAd.wp.cancellables.set)
            }

        }).eraseToAnyPublisher()
//#endif
    }
}


extension Publisher where Self.Output == NativeAdState.State {
    
    func success() -> AnyPublisher<NativeAd,Failure> {
        return compactMap({ value in
            switch value {
            case .loadSuccess(let ad):
                return ad
            default:
                return nil
            }
        }).eraseToAnyPublisher()
    }
}

extension Publisher where Self.Output == ADCenter.ShowState {
    
    func success() -> AnyPublisher<ADCenter.ShowState,Failure> {
        return filter({ state in
            return state == .loadError || state == .didDismissed || state == .timeOut
        }).eraseToAnyPublisher()
    }
}


/// 原生广告
class NativeAdState: NSObject,NativeAdLoaderDelegate,NativeAdDelegate {
    let id = UUID()
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        nativeAd.delegate = self
        state = .loadSuccess(nativeAd)
        nativeAd.paidEventHandler = {[weak self] adValue in
            guard let self = self else { return }
            guard let scene = scene else { return }
            Event.native_revenue(scene, adValue).track()
        }
    }
    
    enum State {
       case loading
       case loadError
       case loadSuccess(NativeAd)
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        guard let scene = scene else { return }
        Event.native_show(scene).track()
    }
    
    func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        guard let scene = scene else { return }
        Event.native_click(scene).track()
    }
    
    // 原生广告加载失败
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: any Error) {
        state = .loadError
    }
    // 原生广告加载完成
    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {

    }
    
    let adLoad:AdLoader!
    var scene:SceneType?
    
    @Published
    var state:State = .loading

    init(rootViewController:UIViewController? = nil,
         adTypes:[AdLoaderAdType] = [.native]) {
        self.adLoad = .init(adUnitID: ADCenterTypeID.naivte.id, rootViewController: rootViewController, adTypes: adTypes, options: nil)
        super.init()
        self.adLoad.delegate = self
    }
  
    func load() -> AnyPublisher<State,Never> {
        adLoad.load(Request())
        return $state.eraseToAnyPublisher()
    }
    
    func normalLoad(){
        adLoad.load(Request())
    }
    
}

/// 开屏广告状态
class AdOpenState:NSObject,FullScreenContentDelegate {

    var appOpenAd:AppOpenAd? = nil
    /// 是否正在加载广告
    var isLoadingAd:Bool = false
    /// 广告是否已显示
    var isShowingAd:Bool = false
    
    var loadTime:Date? = nil
    
    let timeoutInterval:TimeInterval = 14400

    /// 广告场景
    var scene:SceneType?

    var stateAction:((ADCenter.ShowState)->Void)?
    
    func wasLoadTimeLessThanNHoursAgo(timeoutInterval: TimeInterval) -> Bool {
        if let loadTime = loadTime {
        return Date().timeIntervalSince(loadTime) < timeoutInterval
      }
      return false
    }
    
    func isAdAvailable() -> Bool {
        return appOpenAd != nil && wasLoadTimeLessThanNHoursAgo(timeoutInterval: timeoutInterval)
    }

    override init() {}
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
      print("App open ad recorded an impression.")
        stateAction?(.didShow)
        guard let scene = scene else { return }
        Event.appOpen_show(scene).track()
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
      print("App open ad recorded a click.")
        stateAction?(.click)
        guard let scene = scene else { return }
        Event.appOpen_click(scene).track()
    }

    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("App open ad will be dismissed.")
        stateAction?(.userDismissed)
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("App open ad will be presented.")
        stateAction?(.willShow)
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("App open ad was dismissed.")
        stateAction?(.didDismissed)
        appOpenAd = nil
        isShowingAd = false
    }
    
    func load() async throws {
        isLoadingAd = true
        do {
            let appOpenAd = try await AppOpenAd.load(
                with: ADCenterTypeID.open.id, request: Request())
            appOpenAd.fullScreenContentDelegate = self
            appOpenAd.paidEventHandler = {[weak self] advalue in
                guard let self = self else { return }
                guard let scene = self.scene else {
                    return
                }
                Event.appOpen_revenue(scene, advalue).track()
            }
            loadTime = Date()
            self.appOpenAd = appOpenAd
            isLoadingAd = false
        } catch {
            print("开屏广告加载失败: \(error.localizedDescription)")
            stateAction?(.loadError)
            appOpenAd = nil
            loadTime = nil
            isLoadingAd = false
            throw error
        }
        
    }
    
    func show(scene:SceneType) {
        self.scene = scene
        if isShowingAd {
          return print("App open ad is already showing.")
        }
        if !isAdAvailable() {
            Task{
                try? await load()
            }
          return
        }

        if let appOpenAd {
          appOpenAd.present(from: nil)
          isShowingAd = true
            Task{
               try await load()
            }
        }
    }
}

class AdInterstitialState: NSObject, FullScreenContentDelegate {
    let id = UUID()

    var interstitial: InterstitialAd?
    var isShowingAd = false
    /// 广告场景
    var scene:SceneType?
    
    @Published var state = ADCenter.ShowState.loading
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        guard let scene = scene else {
            return
        }

        state = .didShow
        Event.inter_show(scene).track()
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        state = .click
        guard let scene = scene else {
            return
        }
        Event.inter_click(scene).track()
    }

    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        state = .userDismissed
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        state = .willShow
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        state = .didDismissed
    }
    
   override init() {
       super.init()
        Task{
           try? await load()
        }
    }

    private func load() async throws {
        do {
            let interstitial = try await InterstitialAd.load(
                with: ADCenterTypeID.interstitial.id, request: Request())
            interstitial.fullScreenContentDelegate = self
            self.interstitial = interstitial
            state = .loadSuccess

            interstitial.paidEventHandler = {[weak self] adValue in
                guard let self = self else { return }
                guard let scene = self.scene else { return }
                Event.inter_revenue(scene, adValue).track()
            }
          } catch {
              state = .loadError
              throw error
          }
    }
    
    func show(scene:SceneType, viewController:UIViewController?) {
        self.scene = scene
        interstitial?.present(from: viewController)
    }
}
*/
