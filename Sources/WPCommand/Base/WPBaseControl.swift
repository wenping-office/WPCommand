//
//  WPBaseControl.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/10/31.
//

import UIKit

open class WPBaseControl: UIControl {
    override public init(frame: CGRect) {
        super.init(frame: frame)
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
