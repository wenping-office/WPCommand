//
//  TestUIController.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/24.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class obj:YPSelecteAlertItem {
    var selecteAlertTitle: String?{
        return testStr
    }
    
    
    var testStr : String = "skafja"
}

extension UIView:YPSelecteAlertItem{
    var selecteAlertTitle: String? {
        return description
    }
}

class TestUIController: WPBaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addBtn()
//        let dateView = YPDateView.init(dateStyle: .yearMonthDayHourMinute, forScroll: Date())
//        dateView?.dateLabelColor = .clear
//        dateView?.maxLimitDate = Date() + 366.wp.day
//        dateView?.minLimitDate = Date() - 366.wp.day
//        view.addSubview(dateView!)
//        dateView?.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.centerY.equalToSuperview()
//            make.height.equalTo(200)
//        }
//
////        dateView?.backgroundColor = .wp.random
//        let strs = ["",""]
//
//        test([(strs,\.description)])

    }
    
    func addBtn(){
        let btn = UIButton()
        btn.setTitle("按钮", for: .normal)
        btn.setTitleColor(.wp.random, for: .normal)
        btn.rx.controlEvent(.touchUpInside).bind {[weak self] _ in
            self?.showAlert()
        }.disposed(by: wp.disposeBag)
        view.addSubview(btn)
        
        btn.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func showAlert() {
        
//        let alert = YPSelecteAlert(showType: .date(type: .yearMonthDay, normalDate: Date()))
        
//        let alert = YPSelecteAlert(showType: .custom)
//
//        alert.wp.show()
        
//        YPSelecteAlert.showDate(in: nil, style: .yearMonthDay, normalDate: Date()) { alert in
//            alert.topBar.titleLabel.text = "测试代码"
//        }
        
        let source = [UIView(),UIView()]
        let source2 = [obj(),obj(),obj()]
        YPSelecteAlert.showCustom(in: nil,
                                  source: [source,
                                           source2]) { alert in
            alert.topBar.titleLabel.text = "自定义"
        } callBack: { resualt in
            
        }

    }

    func test<E,P:KeyPath<E,String>>(_ other:[([E],P)]) {
        
    }
}


