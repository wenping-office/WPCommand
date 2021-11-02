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
            ("layout弹窗",TestLayoutVC.self),
            ("高亮蒙层",TestHighlightVC.self),
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
        
        let test = Person()
        let name : String = test.name
        
        let obj = ObjTest()
        let size : CGSize = .init()
        size.wp.isCustom
        
        let date = Date()

    }
    
}

struct ObjTest:Codable {
    
}

public extension WPSpace where Base == String{
    
    /// 当前app版本
    var appVersion : Base?{
        return "saf"
    }
}

@dynamicMemberLookup
struct Person {
    
    subscript(dynamicMember member: String) -> String {
        let properties = ["name":"Zhangsan", "sex": "男"]
        return properties[member, default: "unknown property"]
    }
    
    
    subscript(dynamicMember member: String) -> Int {
        let properties = ["age": 20]
        return properties[member, default: 0]
    }
    
}


public protocol NamespaceWrappable {
    associatedtype WrapperType
    var hk: WrapperType { get }
    static var hk: WrapperType.Type { get }
}
public extension NamespaceWrappable {
    var hk: NamespaceWrapper<Self> {
        return NamespaceWrapper(value: self)
    }
    static var hk: NamespaceWrapper<Self>.Type {
        return NamespaceWrapper.self
    }
}
public protocol TypeWrapperProtocol {
    associatedtype WrappedType
    var wrappedValue: WrappedType { get }
    init(value: WrappedType)
}
public struct NamespaceWrapper<T>: TypeWrapperProtocol {
    
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}

extension Array : NamespaceWrappable{}
extension TypeWrapperProtocol where WrappedType == Array<Any>{
    /// 复制一个array
    var copy : [WrappedType.Element]{
        let arr = wrappedValue
        return arr
    }
}
