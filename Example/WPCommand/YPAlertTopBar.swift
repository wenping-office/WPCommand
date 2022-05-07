//
//  YPAlertTopBar.swift
//  WPCommand_Example
//
//  Created by WenPing on 2022/2/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class YPAlertTopBar: WPBaseView {
    
    /// 取消按钮
    let cancelBtn = UIButton()
    
    /// 确定按钮
    let qureBtn = UIButton()
    
    /// 标题
    let titleLabel = UILabel()

    override func initSubView() {
        
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelBtn.setTitleColor(UIColor.wp.initWith(0, 0, 0, 0.45), for: .normal)
        qureBtn.setTitle("确定", for: .normal)
        qureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        qureBtn.setTitleColor(UIColor.wp.initWith(0, 146, 255, 1), for: .normal)
        titleLabel.textColor = UIColor.wp.initWith(0, 0, 0, 0.85)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        addSubview(cancelBtn)
        addSubview(qureBtn)
        addSubview(titleLabel)
    }
    
    override func initSubViewLayout(){
        
        cancelBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(40)
        }

        qureBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.right.equalTo(-16)
        }
    }
}
