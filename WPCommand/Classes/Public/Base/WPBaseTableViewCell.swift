//
//  WPBaseTableViewCell.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

open class WPBaseTableViewCell: UITableViewCell{
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubView()
        initSubViewLayout()
        observeSubViewEvent()
        bindViewModel()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

 extension WPBaseTableViewCell{
    
    // 绑定模型
    open func bindViewModel(){}
    
    // 监听视图事件
    open func observeSubViewEvent(){}
    
    // 初始化视图布局
    open func initSubViewLayout(){}
    
    // 初始化视图
    open func initSubView(){}
    
}


