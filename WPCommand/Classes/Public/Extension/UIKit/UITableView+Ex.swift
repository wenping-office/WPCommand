//
//  UITableViewEx.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/20.
//

import UIKit

extension UITableView{
    
    /// 注册xibCell
    /// - Parameter aClass: 类型
    func wp_registerCellNib<T: UITableViewCell>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        let nib = UINib(nibName: name, bundle: nil)
        register(nib, forCellReuseIdentifier: name)
    }

    
    /// 注册一个cell
    /// - Parameter aClass: cell
    func wp_registerCellClass<T: UITableViewCell>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        register(aClass, forCellReuseIdentifier: name)
    }

    
    /// 获取一个注册的cell
    /// - Parameter aClass: cell类型
    /// - Returns: cell
    func wp_dequeueReusableCell<T: UITableViewCell>(_ aClass: T.Type) -> T! {
        let name = String(describing: aClass)
        guard let cell = dequeueReusableCell(withIdentifier: name) as? T else {
            fatalError("*\(name)* 未注册")
        }
        return cell
    }

    
    /// 注册一个Xib的header或footer
    /// - Parameter aClass: 类型
    func wp_registerHeaderFooterNib<T: UIView>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        let nib = UINib(nibName: name, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: name)
    }

    
    /// 注册一个header或footer
    /// - Parameter aClass: 类型
    func wp_registerHeaderFooterClass<T: UIView>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        register(aClass, forHeaderFooterViewReuseIdentifier: name)
    }

    
    /// 获取一个注册的header或者footer
    /// - Parameter aClass: 类型
    /// - Returns: headerfooter
    func wp_dequeueReusableHeaderFooter<T: UIView>(_ aClass: T.Type) -> T! {
        let name = String(describing: aClass)
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: name) as? T else {
            fatalError("\(name) 未注册")
        }
        return cell
    }
}
