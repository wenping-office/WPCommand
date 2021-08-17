//
//  TestMenuVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/8/5.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class TestMenuVC: WPBaseVC {

    let menuView = WPMenuView(navigationHeight: 44)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        menuView.backgroundColor = .wp_random
    }
    
    override func initSubView() {
        view.addSubview(menuView)
    }

    override func initSubViewlayout() {
        menuView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}