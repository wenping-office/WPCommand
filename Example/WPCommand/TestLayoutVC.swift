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

        
        let testView = UIView()
        self.view.addSubview(testView)
        testView.backgroundColor = .wp.random
        testView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(400)
        }

        let alert = LayoutAlert("alkfdjadf")
        alert.wp.show(in: nil) { state in
            print(state,"------")
        }

        arithmeticMean(3,3,23)

//        LayoutAlert("疯狂大叫弗").show(in:view)
    }
    
    func arithmeticMean(_ numbers:Double...) -> Int {
        
        return 0
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
            self?.wp.dismiss()
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
    
    func updateStatus(status: WPAlertManager.State) {
        
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
        wp.dismiss()
    }
    
    func alertInfo() -> WPAlertManager.Alert {
        return .init(.default, location: .top(.zero), showDuration: 0.2, direction: .right, dismissDuration: 0.2)
    }
    
    func maskInfo() -> WPAlertManager.Mask {
        return .init(color: .red, enabled: false, hidden: true)
    }

    deinit {
        
        print("frame deinit")
    }
}

class testBtn : UITextField,WPHighlightMaskProtocol{
    
}

class LayoutAlert:WPBaseView,WPAlertProtocol{

    let btn = UIButton()
    let lab = UILabel()
    let field = testBtn()

    var isObser = false
    var idDidShow = false

    init(_ string:String) {
        super.init(frame: .init(x: 0, y: 0, width: 0, height: 0))
        btn.setTitle("更新尺寸", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        lab.text = string
    }

    override func initSubView() {

        btn.backgroundColor = .white
        addSubview(btn)
        
        lab.numberOfLines = 0
        addSubview(lab)
        
        field.placeholder = "键盘"
        addSubview(field)

        btn.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] in
            let test = self?.lab.text
            self?.lab.text = test! + test!
//            self?.btn.snp.updateConstraints { make in
//                make.width.equalTo(260)
//            }
            
//            WPAlertManager.default.updateSize(.bounces(damping: 0.3, velocity: 0.1, options: .allowUserInteraction),
//                                              0.2,
//                                                   .init(width: 50,     height: 50))
            
            WPAlertManager.default.update(offset: .init(x: 0, y: -10))
            
        }).disposed(by: wp.disposeBag)
        
        wp.subViewRandomColor()
    }
    
    override func initSubViewLayout() {

        btn.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(44)
            make.left.right.equalToSuperview()
            make.width.equalTo(200)
        }
        
        field.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(btn.snp.bottom)
        }

        lab.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(field.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
    
    func alertInfo() -> WPAlertManager.Alert {
        return .init(.default,
                     location: .center(),
                     showDuration: 0.3,
                     direction: .center,
                     dismissDuration: 0.3)
    }
    
    func touchMask() {
        wp.dismiss()
//        FrameAlert().show(in:superview,option: .insert(keep: true))
    }
    
    func stateDidUpdate(state: WPAlertManager.State) {
        if state == .didShow {
            idDidShow = true
            field.showHighlight(to: self, touch: { view in

            }, color: .wp.initWith(0, 0, 0, 1))
        }else{
            idDidShow = false
        }

        if state == .didShow  {

            WPSystem.keyboard.offsetY(in: self.btn, bag: wp.disposeBag).subscribe(onNext: {[weak self] value in
//                let test = self.lab.text
//                self.lab.text = test! + test!
                guard
                    let self = self
                else { return }
                
                if self.idDidShow {
                    let newValue = (value != 0) ? value - 10 : 0
                    //                WPAlertManager.default.update(size: .init(width: 50, height: -100))
                    WPAlertManager.default.update(offset: .init(x: 0, y: newValue))
                }else{
                    
                }
            }).disposed(by: wp.disposeBag)
        }
    }

    deinit {
        print("弹窗释放")
    }
}
