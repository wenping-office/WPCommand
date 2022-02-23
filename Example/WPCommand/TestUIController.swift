//
//  TestUIController.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/24.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

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
    
    
    
    let labelsView = WPLabelsView<UILabel>(itemHeight: 40)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addBtn()

        labelsView.set(data: ["测试代码0","测试代码1","测试代码2","测试代码3","测试代码4","测试代码5","测试代码6","测试代码7","测试代码8","测试代码9","测试代码10","测试代码11"])
        labelsView.numberOfLines = 2
        labelsView.delegate = self
        view.addSubview(labelsView)
        labelsView.backgroundColor = .wp.random
        labelsView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-0)
            make.height.equalTo(300)
        }
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
            make.centerY.equalToSuperview().offset(200)
            make.centerX.equalToSuperview()
        }
    }

    func showAlert() {
        
        var testItem : [YPWorkTypeAlert.Item] = []
        var count = 4
        for index in 0...30 {
            let item : YPWorkTypeAlert.Item = .init()
            if count > 0 {
//                item.placeholder = .init(text: "测试代码", btnTitle: "点击", callBack: {
//                    print("回调")
//                })
            }
            item.text = "测试代码\(index)"
            for twoIndex in 0...10 {
                let twoItem : YPWorkTypeAlert.Item = .init()
                twoItem.text = "测试代码\(twoIndex)"
                for threeIndex in 0...5 {
                    let threeItem : YPWorkTypeAlert.Item = .init()
                    threeItem.text = "测试代码\(threeIndex)"
                    twoItem.subItems.append(threeItem)
                    if index == 0  && count > 0{
//                        threeItem.isSelected = true
                        count = count - 1
                    }
                }
                item.subItems.append(twoItem)
            }
            testItem.append(item)
        }

        YPWorkTypeAlert.show(config: { alert in
            alert.maxLevelTwo = 3
            alert.maxLevelThree = 5
            alert.topBar.titleLabel.text = "测试代码"
        }, style: .two, source: testItem) { items in
            for item in items {
                print(item.text)
            }
        }
        

        /*
        YPOptionAlert.show(source: [[("1",false),("2",true)],[("取消",false)]]) { index in
            
        }
         */
    }

}


