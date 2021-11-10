//
//  WPBaseVC.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

open class WPBaseVC: UIViewController {
    /// 导航栏标题字体颜色
    open var navigationTitleColor: UIColor {
        return .black
    }

    /// 导航栏标题字体
    open var navigationTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .bold)
    }

    /// 是否隐藏导航栏
    open var navigationisHidden: Bool {
        return false
    }
    
    /// 导航栏背景视图
    open var navigationBackgroundImage: UIImage {
        return UIColor.white.wp.image()!
    }
    
    /// 导航栏是否透明
    open var navigationTranslucent: Bool {
        return false
    }

    public required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = navigationTranslucent
        navigationStyle(backgroundImage: navigationBackgroundImage,
                        titleColor: navigationTitleColor,
                        font: navigationTitleFont,
                        hidden: navigationisHidden)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = navigationTranslucent
        navigationStyle(backgroundImage: navigationBackgroundImage,
                        titleColor: navigationTitleColor,
                        font: navigationTitleFont,
                        hidden: navigationisHidden)
    }
    
    /// 设置导航栏样式
    func navigationStyle(backgroundImage: UIImage, titleColor: UIColor, font: UIFont, hidden: Bool) {
        navigationController?.setNavigationBarHidden(hidden, animated: true)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: titleColor,
                                                                   .font: font]
        navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .any, barMetrics: .default)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        initSubView()
        initSubViewLayout()
        observeSubViewEvent()
        bindViewModel()
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
