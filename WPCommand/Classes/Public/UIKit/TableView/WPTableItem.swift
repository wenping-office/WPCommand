//
//  WPitem.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/25.
//

import UIKit

open class WPTableItem: NSObject {
    public var reuseIdentifier: String {
        return NSStringFromClass(cellClass)
    }
    
    /// cell类型
    public let cellClass: UITableViewCell.Type
    /// cell状态
    open var viewStatus = UIControl.State.normal
    /// 这行的indexpath
    open var indexPath: IndexPath?
    /// 返回的高度 默认自适应高度
    open var cellHeight: CGFloat = UITableView.automaticDimension
    /// 编辑的样式
    open var editingStyle = UITableViewCell.EditingStyle.none
    /// 分割线间距
    open var separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 0)
    /// 编辑按钮点击后调用
    open var didCommitEditBlock: ((WPTableItem, WPTableGroup)->Void)?
    /// 选中一行调用
    open var didSelectedBlock: ((UITableViewCell) ->Void)?
    /// 选中当前行调用
    open var selectedToSelfBlock: ((WPTableItem) ->Void)?
    /// 设置cell
    open var settingCellBlock: ((UITableViewCell)->Void)?
    /// 即将绘制调用
    open var willDisplay: ((UITableViewCell) ->Void)?
    /// 设置完info后回调 可以用来主动计算Cell的高度
    open var didSetInfo: ((Any?)->Void)?
    /// 刷新Item
    open var uploadItemBlock: ((WPTableItem)->Void)?
    
    public var info: Any? {
        didSet {
            guard let info = info else { return }
            didSetInfo?(info)
            didSetInfo(info: info)
        }
    }
    
    public required init<T: UITableViewCell>(cellClass: T.Type) {
        self.cellClass = cellClass
        super.init()
    }
    
    public init<T: UITableViewCell>(cellClass: T.Type, willDisPlay: ((UITableViewCell) ->Void)? = nil, didSelected: ((UITableViewCell) ->Void)? = nil) {
        self.cellClass = cellClass
        super.init()
        didSelectedBlock = didSelected
        willDisplay = willDisPlay
    }
    
    /// 设置完Info后调用，可在此方法手动计算Cell高度并赋值CellHeight
    open func didSetInfo(info: Any?) {}
    
    /// 刷新itemModel
    public func update() {
        uploadItemBlock?(self)
    }
    
    /// 选中当前行
    public func selected() {
        selectedToSelfBlock?(self)
    }
}
