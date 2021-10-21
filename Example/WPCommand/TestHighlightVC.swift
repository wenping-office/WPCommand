//
//  TestHighlightVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class TestHighlightVC: WPBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let redView = UIView()
        redView.backgroundColor = .wp_random
        view.addSubview(redView)
        redView.snp.makeConstraints { make in
            make.width.height.equalTo(200)
            make.center.equalToSuperview()
        }
        
        WPGCD.main_asyncAfter(.now() + 3, task: {
            redView.showHighlight()
        })
        
        WPGCD.main_asyncAfter(.now() + 6, task: {
            redView.removeHighlight()
        })
    }


}
