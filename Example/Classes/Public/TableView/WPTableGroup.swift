//
//  WPgroup.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/25.
//

import UIKit

open class WPTableGroup: NSObject {
    public var items : [WPTableItem] = []
    public var status = UIControl.State.normal
    public var headerTitle : String?
    public var footerTitle : String?
    public var headerHeight : CGFloat = UITableView.automaticDimension
    public var footerHeight : CGFloat = UITableView.automaticDimension
    public var section : Int = 0
    public var didAddItem : ((_ section : Int,_ style : UITableView.RowAnimation)->Void)?
    public var didLoadStyle = UITableView.RowAnimation.fade
    public var headViewReuseIdentifier : String? = NSStringFromClass(UITableViewHeaderFooterView.self)
    public var footViewReuseIdentifier : String? = NSStringFromClass(UITableViewHeaderFooterView.self)
    public var headViewClass = UITableViewHeaderFooterView.self
    public var footViewClass = UITableViewHeaderFooterView.self
    public var headWillDisplayBlock : ((UITableViewHeaderFooterView)->Void)?
    public var footWillDisplayBlock : ((UITableViewHeaderFooterView)->Void)?
    public var info : Any?
    
    required public init(items:[WPTableItem]=[]){
        super.init()
        self.items = items
    }

    public init<T:UITableViewHeaderFooterView>(headerClass:T.Type) {
        super.init()
        headViewClass = headerClass
    }
    
    public init<T:UITableViewHeaderFooterView>(footerClass:T.Type) {
        super.init()
        footViewClass = footerClass
    }
}

