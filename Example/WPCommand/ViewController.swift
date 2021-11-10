//
//  ViewController.swift
//  WPCommand
//
//  Created by Developer on 07/16/2021.
//  Copyright (c) 2021 Developer. All rights reserved.
//

import UIKit
import WPCommand
import RxSwift

class ViewController: UIViewController {

    var tableView = UITableView(frame: .zero, style: .plain)

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
            ("测试空间",TestSpaceVC.self),
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
        tableView.wp.dataSource.groups = [group]

        let presions = [Presion.init(id: "123", name: "qqq"),Presion.init(id: "234", name: "rew")]
        let name = presions.map { $0.name }
        let nams = presions.map(\.name)
        
    }
    
}


@dynamicMemberLookup
public struct Reactive<Base> {
    /// Base object to extend.
    public let base: Base

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }

    /// Automatically synthesized binder for a key path between the reactive
    /// base and one of its properties
    public subscript<Property>(dynamicMember keyPath: ReferenceWritableKeyPath<Base, Property>) -> Binder<Property> where Base: AnyObject {
        Binder(self.base) { base, value in
            base[keyPath: keyPath] = value
        }
    }
}

/// A type that has reactive extensions.
public protocol ReactiveCompatible {
    /// Extended type
    associatedtype ReactiveBase

    /// Reactive extensions.
    static var yd: Reactive<ReactiveBase>.Type { get set }

    /// Reactive extensions.
    var yd: Reactive<ReactiveBase> { get set }
}

extension ReactiveCompatible {
    /// Reactive extensions.
    public static var yd: Reactive<Self>.Type {
        get { Reactive<Self>.self }
        // this enables using Reactive to "mutate" base type
        // swiftlint:disable:next unused_setter_value
        set { }
    }

    /// Reactive extensions.
    public var yd: Reactive<Self> {
        get { Reactive(self) }
        // this enables using Reactive to "mutate" base object
        // swiftlint:disable:next unused_setter_value
        set { }
    }
}

/// Extend NSObject with `rx` proxy.
extension NSObject: ReactiveCompatible { }









/// keypath 动态获取属性
func setter<Object : AnyObject,value>(for object:Object,keyPath:ReferenceWritableKeyPath<Object,value>)->(value)->Void{

    return { [weak object] value in
        object?[keyPath: keyPath] = value
    }
}

extension Sequence{
    func map<T>(_ keyPath:KeyPath<Element,T>) -> [T] {
        return map{ $0[keyPath: keyPath]}
    }
    
    func stord<T:Comparable>(_ keyPath : KeyPath<Element,T>) -> [Element]{
        return sorted { elmt1, elmt2 in
            return elmt1[keyPath:keyPath] < elmt2[keyPath:keyPath]
        }
    }
}

struct Presion {
    let id : String
    let name : String
}
