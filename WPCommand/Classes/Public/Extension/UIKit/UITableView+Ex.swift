//
//  UITableViewEx.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/20.
//

import UIKit

public extension WPSpace where Base : UITableView{
    /// 注册xibCell
    /// - Parameter aClass: 类型
    func registerCellNib<T: UITableViewCell>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        let nib = UINib(nibName: name, bundle: nil)
        base.register(nib, forCellReuseIdentifier: name)
    }

    
    /// 注册一个cell
    /// - Parameter aClass: cell
    func registerCellClass<T: UITableViewCell>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        base.register(aClass, forCellReuseIdentifier: name)
    }

    
    /// 获取一个注册的cell
    /// - Parameter aClass: cell类型
    /// - Returns: cell
    func dequeueReusableCell<T: UITableViewCell>(_ aClass: T.Type) -> T! {
        let name = String(describing: aClass)
        guard let cell = base.dequeueReusableCell(withIdentifier: name) as? T else {
            fatalError("*\(name)* 未注册")
        }
        return cell
    }

    
    /// 注册一个Xib的header或footer
    /// - Parameter aClass: 类型
    func registerHeaderFooterNib<T: UIView>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        let nib = UINib(nibName: name, bundle: nil)
        base.register(nib, forHeaderFooterViewReuseIdentifier: name)
    }

    
    /// 注册一个header或footer
    /// - Parameter aClass: 类型
    func registerHeaderFooterClass<T: UIView>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        base.register(aClass, forHeaderFooterViewReuseIdentifier: name)
    }

    
    /// 获取一个注册的header或者footer
    /// - Parameter aClass: 类型
    /// - Returns: headerfooter
    func dequeueReusableHeaderFooter<T: UIView>(_ aClass: T.Type) -> T! {
        let name = String(describing: aClass)
        guard let cell = base.dequeueReusableHeaderFooterView(withIdentifier: name) as? T else {
            fatalError("\(name) 未注册")
        }
        return cell
    }
}
