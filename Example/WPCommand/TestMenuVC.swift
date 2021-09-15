//
//  TestMenuVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/8/5.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class TestMenuVC: WPBaseVC, WPMenuViewDataSource {
    func viewForIndex(index: Int) -> UIView? {
        return nil
    }

    let menuView = WPMenuView(navigationHeight: 44)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let items = [testMenuItem(),testMenuItem(),testMenuItem(),testMenuItem(),testMenuItem()]

        menuView.backgroundColor = .wp_random

        menuView.setItems(items: items)
        
    }
    
    override func initSubView() {
        menuView.dataSource = self
        view.addSubview(menuView)
    }

    override func initSubViewLayout() {
        menuView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}


class testMenuItem: UILabel,WPMenuViewNavigationProtocol {
    func upledeStatus(status: WPMenuView.NavigationStatus) {
        text = "测试代码"
        textColor = .wp_random
        backgroundColor = .wp_random
    }
    
    
}
