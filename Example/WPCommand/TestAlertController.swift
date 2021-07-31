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
        
        rootView.backgroundColor = .wp_random
        view.addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let alert = testAlert()
        alert.backgroundColor = .wp_random
        alert.wp_width = 200
        alert.wp_height = 200
        view.layoutIfNeeded()
        WPAlertManager.default.setAlerts([alert]).target(in: self.rootView).show()
//        WPAlertManager.default.target(in: self.view).showNext(alert)
        
        alert.leftBtn.rx.tap.subscribe(onNext: {
            WPAlertManager.default.dismiss()
        })
        
        alert.rightBtn.rx.tap.subscribe(onNext: {
            
            let aler2 = testAlert2()
            aler2.backgroundColor = .red
            aler2.wp_width = 200
            aler2.wp_height = 200
            aler2.leftBtn.rx.tap.subscribe(onNext: {
                WPAlertManager.default.dismiss()
            })
            WPAlertManager.default.showNext(aler2)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
}

class rootViw: UIView {
    deinit {
        print("rootView释放了")
    }
}

class testAlert2: WPBaseView,WPAlertProtocol {
    
    deinit {
        print("弹窗释放了")
    }

    func updateStatus(status: WPAlertManager.Progress) {
        
    }
    
    var animateType: WPAlertManager.AnimateType{
        return .bounces
    }
    
    var beginLocation: WPAlertManager.BeginLocation{
        return .center
    }
    
    var beginAnimateDuration: CGFloat{
        
        return 3
    }
    
    var endLocation: WPAlertManager.EndLocation{
        return .bottom
    }
    
    var endAnimateDuration: CGFloat{
        return 3
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
    deinit {
        print("弹窗释放了")
    }
    
    func updateStatus(status: WPAlertManager.Progress) {
        
    }
    
    var animateType: WPAlertManager.AnimateType{
        return .default
    }
    
    var beginLocation: WPAlertManager.BeginLocation{
        return .left
    }
    
    var beginAnimateDuration: CGFloat{
        return 2
    }
    
    var endLocation: WPAlertManager.EndLocation{
        return .bottom
    }
    
    var endAnimateDuration: CGFloat{
        return 0.3
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
