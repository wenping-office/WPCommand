//
//  TestAlertController.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class TestAlertController: WPBaseVC {

    let rootView = rootViw()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let alert = testAlert()

        alert.backgroundColor = .wp_random
        alert.wp_width = 200
        alert.wp_height = 200
        view.layoutIfNeeded()

        WPAlertManager.default.addAlert(alert)
        WPAlertManager.default.show()

//        manager.addAlert(alert)
//        manager.show()

//        WPAlertManager.default.setAlerts([alert]).target(in: self.rootView).show()
////        WPAlertManager.default.target(in: self.view).showNext(alert)
//
        alert.leftBtn.rx.tap.subscribe(onNext: {
            WPAlertManager.default.dismiss()
        })
        
//
//        alert.rightBtn.rx.tap.subscribe(onNext: {
//
//            let aler2 = testAlert2()
//            aler2.backgroundColor = .red
//            aler2.wp_width = 200
//            aler2.wp_height = 200
//            aler2.leftBtn.rx.tap.subscribe(onNext: {
//                WPAlertManager.default.dismiss()
//            })
//            WPAlertManager.default.target(in: self.view).showNext(aler2,immediately: true)
//        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
}

class rootViw: WPBaseView {
    let btn = UIButton()
    
    override func initSubView() {
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("按钮点击", for: .normal)
        addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(150)
        }
        
        btn.rx.tap.subscribe(onNext: {
            print("底层视图点击")
        })
    }

    deinit {
        print("rootView释放了")
    }
}

class testAlert2: WPBaseView,WPAlertProtocol {
    var alert: WPAlertManager?
    
    
    deinit {
        print("弹窗释放了")
    }
    
    func alertInfo() -> WPAlertManager.Alert {
        return .init(type: .bounces, startLocation: .center(), startDuration: 0.3, stopLocation: .center, stopDuration: 3)
    }
    
//    func touchMask() {
//        print("testAlert2 点击了蒙版")
//    }
    
    func maskInfo() -> WPAlertManager.Mask {
        return .init(color: .blue, enabled: true, isHidden: false)
    }
    
    let leftBtn = UIButton()
    let rightBtn = UIButton()
    
    override func initSubView() {
        
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        leftBtn.setTitle("左边", for: .normal)
        rightBtn.setTitle("右边", for: .normal)
        leftBtn.setTitleColor(.black, for: .normal)
        rightBtn.setTitleColor(.black, for: .normal)
        
        leftBtn.snp.makeConstraints { make in
            make.left.equalToSuperview()
        }
        
        rightBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
        }

        wp_subViewRandomColor()
    }
    
}

class testAlert: WPBaseView,WPAlertProtocol {
    var alert: WPAlertManager?
    
    deinit {
        print("弹窗释放了")
    }
    
    func touchMask() {
        print("testAlert 点击了蒙版")
    }

    func alertInfo() -> WPAlertManager.Alert {
        return .init(type: .default, startLocation: .left(offset: .init(x: 30, y: -100)), startDuration: 0.3, stopLocation: .bottom, stopDuration: 0.3)
    }

    func maskInfo() -> WPAlertManager.Mask {
        return .init(color: .red, enabled: false, isHidden: false)
    }
    
    let leftBtn = UIButton()
    let rightBtn = UIButton()
    
    override func initSubView() {
        
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        leftBtn.setTitle("左边", for: .normal)
        rightBtn.setTitle("右边", for: .normal)
        leftBtn.setTitleColor(.black, for: .normal)
        rightBtn.setTitleColor(.black, for: .normal)
        
        leftBtn.snp.makeConstraints { make in
            make.left.equalToSuperview()
        }
        
        rightBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
        }

        wp_subViewRandomColor()
    }
    
}
