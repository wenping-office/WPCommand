//
//  BaseView.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

open class BaseView: WPBaseView {
    public lazy var mainView = UIView().wp.make { view in
        self.insertSubview(view, at: 0)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
