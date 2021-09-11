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
        return .init(.default, startLocation: .bottom(.zero), startDuration: 0.7, stopLocation: .top, stopDuration: 0.8)
    }

    func touchMask() {
        WPAlertManager.default.dismiss()
    }
    
    deinit {
        print(self,"释放了")
    }
}
