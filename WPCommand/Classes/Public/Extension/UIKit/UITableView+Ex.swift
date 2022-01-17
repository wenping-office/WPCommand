//
//  UITableViewEx.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/20.
//

import UIKit

public extension WPSpace where Base: UITableView {
    /// 注册xibCell
    /// - Parameter aClass: 类型
    func register<T: UITableViewCell>(withNib cellType: T.Type) {
        let name = String(describing: cellType)
        let nib = UINib(nibName: name, bundle: nil)
        base.register(nib, forCellReuseIdentifier: name)
    }

    /// 注册一个cell
    /// - Parameter aClass: cell
    func register<T: UITableViewCell>(with cellType: T.Type) {
        let name = String(describing: cellType)
        base.register(cellType, forCellReuseIdentifier: name)
    }

    /// 获取一个注册的cell
    /// - Parameter aClass: cell类型
    /// - Returns: cell
    func dequeue<T: UITableViewCell>(of cellType: T.Type) -> T! {
        let name = String(describing: cellType)
        guard let cell = base.dequeueReusableCell(withIdentifier: name) as? T else {
            fatalError("*\(name)* 未注册")
        }
        return cell
    }

    /// 注册一个Xib的header或footer
    /// - Parameter aClass: 类型
    func registerHeaderFooter<T: UIView>(withNib headerFooterType: T.Type) {
        let name = String(describing: headerFooterType)
        let nib = UINib(nibName: name, bundle: nil)
        base.register(nib, forHeaderFooterViewReuseIdentifier: name)
    }

    /// 注册一个header或footer
    /// - Parameter aClass: 类型
    func registerHeaderFooter<T: UIView>(with headerFooterType: T.Type) {
        let name = String(describing: headerFooterType)
        base.register(headerFooterType, forHeaderFooterViewReuseIdentifier: name)
    }

    /// 获取一个注册的header或者footer
    /// - Parameter aClass: 类型
    /// - Returns: headerfooter
    func dequeueHeaderFooter<T: UIView>(of headerFooterType: T.Type) -> T! {
        let name = String(describing: headerFooterType)
        guard let cell = base.dequeueReusableHeaderFooterView(withIdentifier: name) as? T else {
            fatalError("\(name) 未注册")
        }
        return cell
    }
}
