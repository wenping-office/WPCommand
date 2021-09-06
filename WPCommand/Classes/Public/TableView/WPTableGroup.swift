//
//  WPgroup.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/25.
//

import UIKit

open class WPTableGroup: NSObject {
    
    /// 当前组下的item
    public var items : [WPTableItem] = []
    /// 当前状态
    public var status = UIControl.State.normal
    /// 头部标题
    public var headerTitle : String?
    /// 尾部标题
    public var footerTitle : String?
    /// 头部的高 默认使用AutoLayout
    public var headerHeight : CGFloat = UITableView.automaticDimension
    /// 尾部的高 默认使用AutoLayout
    public var footerHeight : CGFloat = UITableView.automaticDimension
    /// 当前组索引
    public var section : Int = 0
    /// 即将添加一个item
    public var didAddItem : ((_ section : Int,_ style : UITableView.RowAnimation)->Void)?
    /// 即将价值一个item时的动画
    public var didLoadStyle = UITableView.RowAnimation.fade
    /// 头部缓存标识符
    public var headViewReuseIdentifier : String?
    /// 尾部缓存标识符
    public var footViewReuseIdentifier : String?
    /// 头部class
    public var headViewClass = UITableViewHeaderFooterView.self
    /// 尾部class
    public var footViewClass = UITableViewHeaderFooterView.self
    /// 头部即将显示block
    public var headWillDisplayBlock : ((UITableViewHeaderFooterView)->Void)?
    /// 尾部即将显示block
    public var footWillDisplayBlock : ((UITableViewHeaderFooterView)->Void)?
    /// 附件 可用来传值
    public var info : Any?
    
    required public init(items:[WPTableItem]=[]){
        super.init()
        self.items = items
    }
    
    public init<T:UITableViewHeaderFooterView>(headerClass:T.Type) {
        super.init()
        headViewClass = headerClass
        headViewReuseIdentifier = NSStringFromClass(headerClass)
    }
    
    public init<T:UITableViewHeaderFooterView>(footerClass:T.Type) {
        super.init()
        footViewClass = footerClass
        headViewReuseIdentifier = NSStringFromClass(footerClass)
    }
}

