//
//  WPBaseVC.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

open class WPBaseVC: UIViewController {

    required public init(){
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        initSubView()
        initSubViewlayout()
        observeSubViewEvent()
        bindViewModel()
    }

    // 绑定模型
    open func bindViewModel(){}
    
    // 监听视图事件
    open func observeSubViewEvent(){}
    
    // 初始化视图布局
    open func initSubViewlayout(){}
    
    // 初始化视图
    open func initSubView(){}
}
