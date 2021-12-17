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

    let manager = WPAlertManager()
    
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

        LayoutAlert("疯狂大叫弗兰克大家的反馈啦就是大福利卡技术的饭卡老大积分卡拉的就是发老大积分啦的").show()
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

        btn.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            self?.dismiss()
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
        
        switch status {
        case .cooling:
            print("frame cooling")
        case.willShow:
            print("frame willShow")
            
        case .didShow:
            print("frame didShow")
        case .willPop:
            print("frame willPop")
        case .didPop:
            print("frame didPop")
        case .remove:
            print("frame remove")
        case .unknown:
            print("frame unknown")
        }
    }

    func touchMask() {
        dismiss()
    }
    
    func alertInfo() -> WPAlertManager.Alert {
        return .init(.default, startLocation: .bottom(.zero), startDuration: 0.2, stopLocation: .bottom, stopDuration: 0.2)
    }
    
    deinit {
        
        print("frame deinit")
    }
}

class LayoutAlert:WPBaseView,WPAlertProtocol{

    let btn = UIButton()
    
    init(_ string:String) {
        super.init(frame: .zero)
        btn.setTitle("Layout" + string, for: .normal)
    }

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
    
    func alertInfo() -> WPAlertManager.Alert {
        return .init(.bounces(damping: 0.5, velocity: 0.1, options: .curveLinear),
                     startLocation: .center(),
                     startDuration: 0.3,
                     stopLocation: .top,
                     stopDuration: 10)
    }
    
    deinit {
        print("弹窗释放")
    }
}
