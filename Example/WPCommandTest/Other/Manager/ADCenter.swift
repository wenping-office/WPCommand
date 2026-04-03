//
//  ADCenter.swift
//  WPCommand
//
//  Created by tmb on 2026/4/3.
//

import UIKit
import WPCommand
import Combine

/*
import GoogleMobileAds
import SnapKit

/* 测试ID
开屏广告    ca-app-pub-3940256099942544/5575463023
自适应横幅广告    ca-app-pub-3940256099942544/2435281174
固定尺寸的横幅广告    ca-app-pub-3940256099942544/2934735716
插页式广告    ca-app-pub-3940256099942544/4411468910
激励广告    ca-app-pub-3940256099942544/1712485313
插页式激励广告    ca-app-pub-3940256099942544/6978759866
原生广告    ca-app-pub-3940256099942544/3986624511
原生视频广告    ca-app-pub-3940256099942544/2521693316
*/



extension ADCenter{
    enum ShowState {
       case willShow
       case didShow
       case click
       case userDismissed
       case didDismissed
       case loadError
    }
}


class ADCenter:NSObject {
    static var `default` = ADCenter()

    /// 开屏广告
   static let openAd = AdOpenState()

    /// 插页广告
    static var interstitialAd = AdInterstitialState()

    /// 初始化广告
    func start(){
        MobileAds.shared.start(completionHandler: { status in
            print(status,"初始化结果")
        })
    }

    /// 原生广告池
    private var nativeAds:[NativeAdState] = []
    
    /// 加载原生广告
    func loadNativeAd() -> AnyPublisher<NativeAdState.State,Never> {
        let nativeAd = NativeAdState()
        nativeAds.append(nativeAd)
        return nativeAd.load()
    }
    
    /// 显示插页广告
    func showInterstitialAd(_ viewController:UIViewController? = nil,timeout:Int = 10) -> AnyPublisher<Void,Never> {

       return .create { ob in
           var didFinish = false
           // 启动 timeout 逻辑
           DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout)) {
               guard !didFinish else { return }
               didFinish = true
               ob(.success(()))
           }
           
           Task{
               do{
                   try await ADCenter.interstitialAd.load()
                   // 超时已经触发就不显示广告
                   guard !didFinish else { return }
                   didFinish = true
                   print("加载成功")
                   ADCenter.interstitialAd.show(viewController: viewController)
                   ADCenter.interstitialAd.stateAction = { state in
                       if state == .didDismissed{
                           ob(.success(()))
                           
                       }
                   }
               }catch{
                   print("加载失败")
                   ob(.success(()))
               }
           }

       }
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


/// 原生广告
class NativeAdState: NSObject,NativeAdLoaderDelegate,NativeAdDelegate {
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        nativeAd.delegate = self
        stateAction?(.loadSuccess(nativeAd))
    }
    
    enum State {
       case loadError
       case loadSuccess(NativeAd)
       case loadAllSuccess
    }
    
    // 原生广告加载失败
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: any Error) {
        stateAction?(.loadError)
    }
    // 原生广告加载完成
    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        stateAction?(.loadAllSuccess)
    }
    
    let adLoad:AdLoader!

    private var stateAction:((State)->Void)?

    init(rootViewController:UIViewController? = nil,adTypes:[AdLoaderAdType] = [.native]) {
        self.adLoad = .init(adUnitID: ADCenterTypeID.naivte.id, rootViewController: rootViewController, adTypes: adTypes, options: nil)
        super.init()
        self.adLoad.delegate = self
    }
  
    func load() -> AnyPublisher<State,Never> {
        adLoad.load(Request())
        return .create {[weak self] ob in
            self?.stateAction = { state in
                ob(.success( state))
            }
        }
    }
    
}

class NativeBlockView: UIView {
    enum Style {
      /// 无横幅
      case small
      /// 有横幅
      case middle
        
       func height() -> CGFloat {
            switch self {
            case .small:
                140
            default:
                350
            }
        }
    }
    
    let style:Style
    
    let adView = NativeAdView(frame: .zero)
    
    var nativeAd:NativeAd?{
        didSet{
            (adView.callToActionView as? UIButton)?.setTitle(nativeAd?.callToAction, for: .normal)
            (adView.iconView as? UIImageView)?.image = nativeAd?.icon?.image
            (adView.headlineView as? UILabel)?.text = nativeAd?.headline
            (adView.bodyView as? UILabel)?.text = nativeAd?.body
            adView.nativeAd = nativeAd;
        }
    }

    init(style: Style,nativeAd:NativeAd? = nil) {
        self.style = style
        super.init(frame: .zero)
        
        adView.translatesAutoresizingMaskIntoConstraints = false
        adView.backgroundColor = .clear
//        adView.layer.cornerRadius = 10;
        adView.clipsToBounds = true
        adView.mediaView = nil;
        addSubview(adView)
        let ctaButton = UIButton(type: .system).wp.isUserInteractionEnabled(false).value()
        let iconView = UIImageView().wp.isUserInteractionEnabled(false).value()
        let adTagLabel = UILabel().wp.isUserInteractionEnabled(false).value()
        let headlineLabel = UILabel().wp.isUserInteractionEnabled(false).value()
        let bodyLabel = UILabel().wp.isUserInteractionEnabled(false).value()
        
        adView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
       
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
       
        ctaButton.titleLabel?.font = 17.font()
        ctaButton.backgroundColor = .main
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.layer.cornerRadius = 8
        ctaButton.clipsToBounds = true
        // 添加到 nativeAdView
        adView.addSubview(ctaButton)
        adView.callToActionView = ctaButton
        
        // 2. icon + AD + headline + body
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 0
        iconView.backgroundColor = .white
        adView.addSubview(iconView)
        adView.iconView = iconView
        
        
        adTagLabel.translatesAutoresizingMaskIntoConstraints = false
        adTagLabel.text = "AD"
        adTagLabel.font = 11.font()
        adTagLabel.textColor = .c55586A
//        adTagLabel.backgroundColor = UIColor(white: 0.25, alpha: 1)
        adTagLabel.layer.borderWidth = 1
        adTagLabel.layer.borderColor = UIColor.c55586A.cgColor
        adTagLabel.textAlignment = .center
        adTagLabel.layer.cornerRadius = 2
        adTagLabel.clipsToBounds = true
        adView.addSubview(adTagLabel)

        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.font = 17.font(.bold)
        headlineLabel.textColor = .white
        
        headlineLabel.numberOfLines = 1
        adView.addSubview(headlineLabel)
        adView.headlineView = headlineLabel
        
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = 11.font()
        bodyLabel.textColor = .c55586A
        
        bodyLabel.numberOfLines = 2
        adView.addSubview(bodyLabel)
        adView.bodyView = bodyLabel
        
        ctaButton.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(ctaButton.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 72, height: 72))
            
        }
        
        adTagLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.top.equalTo(iconView).offset(8)
            make.size.equalTo(CGSize(width: 24, height: 14))
        }
        
        headlineLabel.snp.makeConstraints { make in
            make.left.equalTo(adTagLabel.snp.right).offset(6)
            make.centerY.equalTo(adTagLabel)
            make.right.equalToSuperview()
        }
        
        bodyLabel.snp.makeConstraints { make in
            make.left.equalTo(adTagLabel)
            make.top.equalTo(headlineLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-10)
        }
        
        switch style {
        case .small:
            iconView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(0)
            }
        case .middle:
            let mediaView = MediaView()
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            mediaView.contentMode = .scaleAspectFit
            adView.addSubview(mediaView)
            adView.mediaView = mediaView
            mediaView.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.top.equalTo(bodyLabel.snp.bottom).offset(12)
                make.height.equalTo(130)
                make.bottom.equalToSuperview()
            }
        }
         
        
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        stateAction?(.loadError)
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
      print("App open ad recorded an impression.")
        stateAction?(.didShow)
        
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
      print("App open ad recorded a click.")
        stateAction?(.click)
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

            loadTime = Date()
            self.appOpenAd = appOpenAd
            isLoadingAd = false
        } catch {
            print("开屏广告加载失败: \(error.localizedDescription)")
            appOpenAd = nil
            loadTime = nil
            isLoadingAd = false
            throw error
        }
        
    }
    
    func show() {
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

    
    var interstitial: InterstitialAd?
    /// 是否正在加载广告
    var isLoadingAd:Bool = false
    /// 是否已经显示过广告
    var isShowingAd:Bool = false
    
    var stateAction:((ADCenter.ShowState)->Void)?
    
    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        stateAction?(.loadError)
        print("加载失败------")
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
      print("App open ad recorded an impression.")
        stateAction?(.didShow)
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
      print("App open ad recorded a click.")
        stateAction?(.click)
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
        interstitial = nil
        isShowingAd = false
    }
    
    func load() async throws {
        isLoadingAd = true
        print("开始加载插页")
        do {
            let interstitial = try await InterstitialAd.load(
                with: ADCenterTypeID.interstitial.id, request: Request())
            interstitial.fullScreenContentDelegate = self
            self.interstitial = interstitial
            isLoadingAd = false
          } catch {
              print("插页广告加载失败: \(error.localizedDescription)")
              interstitial = nil
              isLoadingAd = false
              throw error
          }

        
    }
    
    func show(viewController:UIViewController?) {
        if isShowingAd {
          return print("App open ad is already showing.广告已经显示过")
        }

        if let interstitial {
            interstitial.present(from: viewController)
            isShowingAd = true
            
            Task{
               try await load()
            }
        }
    }
}


*/
