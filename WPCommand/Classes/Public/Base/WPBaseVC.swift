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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubView()
        initSubViewlayout()
        observeSubViewEvent()
        bindViewModel()
    }
    
    // 绑定模型
    public func bindViewModel(){}
    
    // 监听视图事件
    public func observeSubViewEvent(){}
    
    // 初始化视图布局
    public func initSubViewlayout(){}
    
    // 初始化视图
    public func initSubView(){}
}
