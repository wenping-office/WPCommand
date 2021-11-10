//
//  TestSpaceVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/11/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class TestSpaceVC: WPBaseVC {
    var tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.backgroundColor = .white

    }
    



}
