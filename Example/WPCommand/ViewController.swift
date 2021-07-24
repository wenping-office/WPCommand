//
//  ViewController.swift
//  WPCommand
//
//  Created by Developer on 07/16/2021.
//  Copyright (c) 2021 Developer. All rights reserved.
//

import UIKit
import WPCommand

class ViewController: UIViewController {

    let tableView = WPTableAutoLayoutView(style: .plain, reloadModel: .default)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        let group = WPTableGroup()
        group.headerHeight = 0
        group.footerHeight = 0
        [("输入框",TestUIController())].forEach { elmt in
            let item = WPTableItem(cellClass: UITableViewCell.self) { cell in
                cell.textLabel?.text = elmt.0
            } didSelected: { cell in
                self.navigationController?.pushViewController(elmt.1, animated: true)
            }
            group.items.append(item)
        }
        tableView.groups = [group]
    }
    
}


