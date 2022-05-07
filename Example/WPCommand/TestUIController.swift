//
//  TestUIController.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/24.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand
import RxCocoa
import RxSwift

class BaseError: Error {
    
}

extension UILabel : WPLabelsItemView{

    public func labelItemWidth(with data: Any) -> CGFloat {
        guard
            
        let dataStr = data as? String
            
        else { return 0 }

        text = dataStr
        backgroundColor = .wp.random

        return dataStr.wp.width(UIFont.systemFont(ofSize: 16), CGFloat.greatestFiniteMagnitude)
    }
}

class TestUIController: WPBaseVC,WPLabelsViewDelegate {
    
    func labelsView(didSelectAt index: Int, with itemView: WPLabelsItemView, data: Any) {
        print("-------")
    }
    
    lazy var testTest = test()
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func viewWillDisappear(_ animated: Bool) {

    }

    override func viewDidAppear(_ animated: Bool) {
        
    }

    let labelsView = WPLabelsView<UILabel>(itemHeight: 40)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addBtn()


//        labelsView.set(data: ["测试代码0","测试代码1","测试代码2","测试代码3","测试代码4","测试代码5","测试代码6","测试代码7","测试代码8","测试代码9","测试代码10","测试代码11"])
//        labelsView.numberOfLines = 2
//        labelsView.delegate = self
//        view.addSubview(labelsView)
//        labelsView.backgroundColor = .wp.random
//        labelsView.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(100)
//            make.left.equalToSuperview()
//            make.right.equalToSuperview().offset(-0)
//            make.height.equalTo(300)
//        }
//
//        var a = ["1","2","3","5","3","6","2"]
//        a.yp_remove(in: ["1","3","4","2"])
        
        let textView = UITextView()
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.width.height.equalTo(200)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(150)
        }
        
        test().bind { elmt in
            print(elmt)
        }
        
    }
    
    func addBtn(){
        
        let btn = UIButton()
        btn.setTitle("按钮", for: .normal)
        btn.setTitleColor(.wp.random, for: .normal)
        view.addSubview(btn)

        btn.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(200)
            make.centerX.equalToSuperview()
        }

        let testObj : BehaviorRelay<String> = .init(value: "")

        testObj.bind(onNext: { elmt in
            print(elmt)

        }).disposed(by: wp.disposeBag)

        
        btn.rx.controlEvent(.touchUpInside).flatMap { _ in
                    return self.test()
        }.do(onNext: { elmt in
            
            print(elmt,"-----")

        }).bind(to: testObj).disposed(by: wp.disposeBag)
            
//        btn.rx.controlEvent(.touchUpInside).flatMap(self.test()).do(onNext: { elmt in
//
//            print(elmt,"-----")
//
//        }).bind(to: testObj).disposed(by: wp.disposeBag)
        

//        btn.rx.controlEvent(.touchUpInside).flatMap { _ in
//            return self.test()
//        }.do { str in
//            print("3232")
//
//        }.bind(to: test()).disposed(by: wp.disposeBag)
            
            let ob : Observable<Bool> = .create { ob in
                return Disposables.create()
            }
         let view = UISwitch()

//            view.rx.isOn.asObservable().flatMap(ob)
            view.rx.isOn.flatMap({ _ in ob }).bind(to: view.rx.isOn)
        
            let gts = UITapGestureRecognizer()
            view.addGestureRecognizer(gts)

    }

    func test() -> Observable<String> {
        return .create { ob in
//            ob.onNext("fkajs")
            ob.onError(BaseError.init())
            return Disposables.create()
        }.catchErrorJustReturn("报错")
    }

    func showAlert() {
        
        YPOptionAlert.show(source: [[("取消",true),("2",false),("2",false)],[("确定",true)]]) { index in
            print(index)
        }

//        var testItem : [YPWorkTypeAlert.Item] = []
//        var count = 4
//        for index in 0...30 {
//            let item : YPWorkTypeAlert.Item = .init()
//            if count > 0 {
////                item.placeholder = .init(text: "测试代码", btnTitle: "点击", callBack: {
////                    print("回调")
////                })
//            }
//            item.text = "测试代码\(index)"
//            for twoIndex in 0...10 {
//                let twoItem : YPWorkTypeAlert.Item = .init()
//                twoItem.text = "测试代码\(twoIndex)"
//                for threeIndex in 0...5 {
//                    let threeItem : YPWorkTypeAlert.Item = .init()
//                    threeItem.text = "测试代码\(threeIndex)"
//                    twoItem.subItems.append(threeItem)
//                    if index == 0  && count > 0{
////                        threeItem.isSelected = true
//                        count = count - 1
//                    }
//                }
//                item.subItems.append(twoItem)
//            }
//            testItem.append(item)
//        }
//
//        YPWorkTypeAlert.show(config: { alert in
//            alert.maxLevelTwo = 3
//            alert.maxLevelThree = 5
//            alert.topBar.titleLabel.text = "测试代码"
//        }, style: .two, source: testItem) { items in
//            for item in items {
//                print(item.text)
//            }
//        }
        

//        labelsView.set(data: [])
//        labelsView.snp.updateConstraints({ make in
//            make.height.equalTo(labelsView.contentHeight)
//        })
//
//        let str = labelsView.data.map { elmt in
//            return 2
//        }
        
    }

}

public extension Array where Element : StringProtocol{
    /// 移除一组和目标数组相同的元素
    mutating func yp_remove(in targets:[Element]) {
        var reuast : [Element] = self
        targets.forEach { elmt in
            reuast.wp_filter { obj in
                return elmt == obj
            }
        }
        self = reuast
    }
}

class TestGroup: WPTableGroup {


}

class SuperCell<T>: UITableViewCell {
    var data : T?
    
    func setDefault(data:T?){

    }
}

class SubClass: SuperCell<String> {

    override func setDefault(data: String?) {
        
    }
}
