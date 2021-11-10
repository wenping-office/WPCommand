//
//  WPBaseTableHeaderFooterView.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/18.
//

import UIKit

open class WPBaseTableViewHeaderFooterView: UITableViewHeaderFooterView {
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initSubView()
        initSubViewLayout()
        observeSubViewEvent()
        bindViewModel()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 绑定模型
    open func bindViewModel() {}
    
    // 监听视图事件
    open func observeSubViewEvent() {}
    
    // 初始化视图布局
    open func initSubViewLayout() {}
    
    // 初始化视图
    open func initSubView() {}
}
