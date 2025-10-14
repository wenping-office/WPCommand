//
//  BaseView.swift
//  ShoppingCommon
//
//  Created by Wen on 2023/8/22.
//

import WPCommand

open class BaseView: WPBaseView {

    public lazy var mainView = UIView().wp.make { view in
        self.insertSubview(view, at: 0)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

