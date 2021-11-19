//
//  TestLayoutVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/9/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand
import RxSwift

class TestLayoutVC: WPBaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel ()
        label.textColor = .black
        label.text = "测试代码"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(120)
        }

        WPGCD.main_asyncAfter(.now() + 3, task: {
            FrameAlert().show(in: self.view)
            
        })
    }

}

class FrameAlert:WPBaseView,WPAlertProtocol {
    
    let btn = UIButton()
    let field = UITextView()

    override init(frame: CGRect) {
        super.init(frame: .init(x: 0, y: 0, width: 250, height: 250))
    }
    
    override func initSubView() {
        btn.backgroundColor = .wp.random
        btn.setTitle("frame", for: .normal)
        addSubview(btn)
        addSubview(field)

        btn.rx.controlEvent(.touchUpInside).subscribe(onNext: { _ in
            let layoutAlert = LayoutAlert()
            layoutAlert.show(option: .insert(keep: true))
        }).disposed(by: wp.disposeBag)
        field.backgroundColor = .red
    }
    
    override func initSubViewLayout() {
        btn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        field.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            make.centerY.equalToSuperview().offset(50)
        }
    }
    
    func updateStatus(status: WPAlertManager.Progress) {
        if status == .willShow {
            field.becomeFirstResponder()
        }
    }

    func touchMask() {
        field.resignFirstResponder()
        dismiss()
    }
    
    func alertInfo() -> WPAlertManager.Alert {
        return .init(.default, startLocation: .bottom(.zero), startDuration: 0.5, stopLocation: .bottom, stopDuration: 0.5)
    }
    
    func maskInfo() -> WPAlertManager.Mask {
        return .init(color: .red, enabled: false, isHidden: true)
    }
}

class LayoutAlert:WPBaseView,WPAlertProtocol{

    let btn = UIButton()
    
    override func initSubView() {
        btn.backgroundColor = .wp.random
        btn.setTitle("Layout", for: .normal)
        addSubview(btn)
        
        btn.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            self?.dismiss()
        }).disposed(by: wp.disposeBag)
    }
    
    override func initSubViewLayout() {
        btn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 200, height: 200))
        }
    }
}
