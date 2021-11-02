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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        WPAlertManager.default.setAlerts([alert1()]).show()

    }
    
    func alert1() -> testAlert {
        let alert = testAlert()
        alert.leftBtn.rx.tap.subscribe(onNext: {
            WPAlertManager.default.dismiss()
        })

        alert.rightBtn.rx.tap.subscribe(onNext: {
            WPAlertManager.default.showNext(self.alert2(),option: .insert(keep: true))
        })
        return alert
    }
    
    func alert2() -> testAlert2 {
        var aler2 = testAlert2()
        aler2.backgroundColor = .yellow
        aler2.wp.width = 200
        aler2.wp.height = 200
        aler2.leftBtn.rx.tap.subscribe(onNext: {
            WPAlertManager.default.dismiss()
        })
        return aler2
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
        return .init(.default, startLocation: .center(), startDuration: 0.3, stopLocation: .center, stopDuration: 0.3)
    }

    
    func maskInfo() -> WPAlertManager.Mask {
        return .init(color: .blue, enabled: true, isHidden: false)
    }
    
    var leftBtn = UIButton()
    var rightBtn = UIButton()
    
    override func initSubView() {
        
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        leftBtn.setTitle("左边", for: .normal)
        rightBtn.setTitle("右边", for: .normal)
        leftBtn.setTitleColor(.black, for: .normal)
        rightBtn.setTitleColor(.black, for: .normal)
        
        leftBtn.wp.x = 0
        rightBtn.wp.x = 100
        leftBtn.sizeToFit()
        rightBtn.sizeToFit()
        wp.subViewRandomColor()
    }
    
}

class testAlert: WPBaseView,WPAlertProtocol {
    
    let leftBtn = UIButton()
    let rightBtn = UIButton()
    
    func alertInfo() -> WPAlertManager.Alert {
        return .init(.bounces, startLocation: .bottom(.zero), startDuration: 0.3, stopLocation: .right, stopDuration: 0.5)
    }

    override func initSubView() {
        
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        leftBtn.setTitle("左边", for: .normal)
        rightBtn.setTitle("右边", for: .normal)
        leftBtn.setTitleColor(.black, for: .normal)
        rightBtn.setTitleColor(.black, for: .normal)
        
        leftBtn.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalTo(150)
            make.bottom.equalToSuperview()
        }
        
        rightBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.equalTo(150)
            make.left.equalTo(leftBtn.snp.right)
        }
        
        backgroundColor = UIColor.wp.random
    }
    
}
