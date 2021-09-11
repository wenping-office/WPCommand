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

    let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        let group = WPTableGroup()
        group.headerHeight = 0
        group.footerHeight = 0
        
        let vc : [(String,WPBaseVC.Type)] = [
            ("输入框",TestUIController.self),
            ("弹窗管理器",TestAlertController.self),
            ("菜单视图",TestMenuVC.self),
            ("layout弹窗",TestLayoutVC.self)
        ]
        vc.forEach { elmt in
            let item = WPTableItem(cellClass: UITableViewCell.self) { cell in
                cell.textLabel?.text = elmt.0
            } didSelected: { cell in
                let vc = elmt.1.init()
                vc.title = elmt.0
                self.navigationController?.pushViewController(vc, animated: true)
            }
            group.items.append(item)
        }
        tableView.wp_source.groups = [group]
        
    }
    
}


