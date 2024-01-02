//
//  WPgroup.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/25.
//

import UIKit

open class WPTableGroup: NSObject {
    /// 当前组下的item
    open var items: [WPTableItem] = []
    /// 当前状态
    open var status = UIControl.State.normal
    /// 头部标题
    open var headerTitle: String?
    /// 尾部标题
    open var footerTitle: String?
    /// 头部的高 默认使用AutoLayout
    open var headerHeight: CGFloat = UITableView.automaticDimension
    /// 尾部的高 默认使用AutoLayout
    open var footerHeight: CGFloat = UITableView.automaticDimension
    /// 当前组索引
    open var section: Int = 0
    /// 即将添加一个item
    open var didAddItem: ((_ section: Int, _ style: UITableView.RowAnimation)->Void)?
    /// 即将价值一个item时的动画
    open var didLoadStyle = UITableView.RowAnimation.fade
    /// 头部缓存标识符
    open var headViewReuseIdentifier: String?
    /// 尾部缓存标识符
    open var footViewReuseIdentifier: String?
    /// 头部class
    open var headViewClass = UITableViewHeaderFooterView.self
    /// 尾部class
    open var footViewClass = UITableViewHeaderFooterView.self
    /// 头部即将显示block
    open var headWillDisplayBlock: ((UITableViewHeaderFooterView)->Void)?
    /// 尾部即将显示block
    open var footWillDisplayBlock: ((UITableViewHeaderFooterView)->Void)?
    /// 附件 可用来传值
    open var info: Any?

    public required init(items: [WPTableItem] = []) {
        super.init()
        self.items = items
    }

    public init<T: UITableViewHeaderFooterView>(headerClass: T.Type) {
        super.init()
        headViewClass = headerClass
        headViewReuseIdentifier = NSStringFromClass(headerClass)
    }

    public init<T: UITableViewHeaderFooterView>(footerClass: T.Type) {
        super.init()
        footViewClass = footerClass
        footViewReuseIdentifier = NSStringFromClass(footerClass)
    }
}
