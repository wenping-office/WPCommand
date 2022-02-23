//
//  YPOptionAlert.swift
//  WPCommand_Example
//
//  Created by WenPing on 2022/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class YPOptionAlert: WPBaseView,YPAlertProtocol {
    let tableView = UITableView.init(frame: .zero, style: .plain)
    
    var source : [[(String,Bool)]] = []
    
    var callBack : ((Int)->Void)?

    override func initSubView() {
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        backgroundColor = .white
        tableView.isScrollEnabled = false
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        addSubview(tableView)
    }

    override func initSubViewLayout(){
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func alertInfo() -> YPAlertManager.Alert {
        return .init(.default, location: .bottom(.zero), showDuration: 0.3, direction: .bottom, dismissDuration: 0.3)
    }

    /// 显示弹窗
    /// - Parameters:
    ///   - view: 显示到的视图
    ///   - source: 展示的值
    ///   - callBack: 回调
    static func show(in view:UIView? = nil,
                     source:[[(String,Bool)]],
                     callBack:@escaping (Int)->Void){
        var maxHeight = WPSystem.screen.isFull ? 20 : 0
        maxHeight += maxHeight + (source.count - 1) * 8
        source.forEach { subArr in
            subArr.forEach { elmt in
                maxHeight += 48
            }
        }
        
        let alert = YPOptionAlert(frame: .init(x: 0, y: 0, width: Int(WPSystem.screen.size.width), height: maxHeight))
        alert.source = source
        alert.tableView.reloadData()
        alert.callBack = callBack
        alert.show(in: view)
    }
}

extension YPOptionAlert:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let elmt = source[indexPath.section][indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel?.text = elmt.0
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        if elmt.1 {
            cell.textLabel?.textColor = .wp.initWith(0, 146, 255, 1)
        }else{
            cell.textLabel?.textColor = .wp.initWith(0, 0, 0, 0.85)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .wp.initWith(245, 246, 250, 1)
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section > 0 ? 8 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        dismiss(stateHandler: {[weak self] state in
            if state == .didPop {
                self?.callBack?(2)
            }
        })
    }
}
