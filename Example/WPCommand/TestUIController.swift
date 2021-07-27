//
//  TestUIController.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/24.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

public struct Test:WPRepeatProtocol {
    public var wp_repeatKey: String{
        return self.id
    }
    
    
    var id : String = ""
}

class TestUIController: WPBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        self.textField()
        self.textView()
        var array = ["1","2","3","1","3"]
        array.wp_repeat(retain: .last)


    }
    
    func textField(){
        let field = WPTextField(inputMode: .input,["3","4"])
        field.maxCount = 8
        view.addSubview(field)
        field.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.height.equalTo(44)
            make.center.equalToSuperview()
        }
        
        view.wp_subViewRandomColor()
    }
    
    func textView(){
        let textView = WPTextView(inputMode: .input, ["1","2"])
        textView.maxCount = 20
        view.addSubview(textView)
        
        textView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(150)
            make.height.equalTo(50)
        }
    }

}
