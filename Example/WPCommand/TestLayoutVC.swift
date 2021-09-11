//
//  TestLayoutVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/9/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class TestLayoutVC: WPBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let alert = LabTestAlert()
        
        WPAlertManager.default.showNext(alert, option: .default)
        
        WPGCD.main_asyncAfter(.now() + 4, task: {
            let alert2 = LabTestAlert2()
            alert2.wp_size = .init(width: 250, height: 250)
            WPAlertManager.default.showNext(alert2,option: .immediately(keep: true))
        })
    }

}

class LabTestAlert2: WPBaseView,WPAlertProtocol {
    let lab = UILabel()
    
    override func initSubView() {
        lab.text = "弹窗2弹窗2弹窗2弹窗2弹窗2弹窗2弹窗2弹窗2弹窗2弹窗2弹窗2"
        lab.numberOfLines = 0
        addSubview(lab)
        backgroundColor = .yellow
    }
    
    override func initSubViewLayout() {
//        lab.snp.makeConstraints { make in
//            make.top.left.right.bottom.equalToSuperview()
//            make.width.lessThanOrEqualTo(300)
//        }
    }
    
    func alertInfo() -> WPAlertManager.Alert {
        return .init(.bounces, startLocation: .bottom(.zero), startDuration: 2, stopLocation: .bottom, stopDuration: 0.4)
    }
    
    func touchMask() {
        WPAlertManager.default.dismiss()
    }
    
    deinit {
        print("黄色释放了")
    }
}


class LabTestAlert: WPBaseView,WPAlertProtocol {
    let lab = UILabel()
    
    override func initSubView() {
        lab.text = "测试代码测试代码测试代码测试代码测试代码测试代码测试代码测试代码测试代测试代码测试代码测试代码测试代码测试代码测试代码测试代码测试代测试代码测试代码测试代码测试代码测试代码测试代码测试代码测试代测试代码测试代码测试代码测试代码测试代码测试代码测试代码测试代测试代码测试代码测试代码测试代码测试代码测试代码测试代码测试代测试代码测试代码测试代码测试代码测试代码测试代码测试代码测试代测试代码测试代码测试代码测试代码测试代码测试代码测试代码测试代码"
        lab.numberOfLines = 0
        addSubview(lab)
        backgroundColor = .wp_random
    }
    
    
    override func initSubViewLayout() {
        lab.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
            make.width.lessThanOrEqualTo(300)
        }
    }
    
    func alertInfo() -> WPAlertManager.Alert {
        return .init(.default, startLocation: .bottom(.zero), startDuration: 0.3, stopLocation: .bottom, stopDuration: 0.3)
    }

    func touchMask() {
        WPAlertManager.default.dismiss()
    }
    
    func updateStatus(status: WPAlertManager.Progress) {
        print(status,"---")
    }

    deinit {
        print("释放了")
    }
}
