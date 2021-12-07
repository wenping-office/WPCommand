//
//  TestSpaceVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/11/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

// MARK: - TestSpaceVC

class TestSpaceVC: WPBaseVC {
    var tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.backgroundColor = .white

    }
}


extension UITableView {
    class Item<Cell: UITableViewCell> {
        // MARK: Open

        /// 设置完Info后调用，可在此方法手动计算Cell高度并赋值CellHeight
        open func didSetInfo(info _: Any?) {}

        // MARK: Public

        /// cell状态
        public var viewStatus = UIControl.State.normal
        /// 返回的高度 默认自适应高度
        public var cellHeight: CGFloat = UITableView.automaticDimension
        /// 编辑的样式
        public var editingStyle = UITableViewCell.EditingStyle.none
        /// 分割线间距
        public var separatorInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 0)
        /// 编辑按钮点击后调用
        public var didCommitEditBlock: ((Item, WPTableGroup) -> Void)?
        /// 选中一行调用
        public var didSelectedBlock: ((UITableViewCell) -> Void)?
        /// 设置cell
        public var settingCellBlock: ((Cell) -> Void)?
        /// 即将绘制调用
        public var willDisplay: ((Cell) -> Void)?
        /// 设置完info后回调 可以用来主动计算Cell的高度
        public var didSetInfo: ((Any?) -> Void)?

        /// 这行的indexpath
        public var indexPath: IndexPath {
            return tableIndexPath
        }

        /// 缓存标识符
        public var reuseIdentifier: String {
            return NSStringFromClass(Cell.self)
        }

        /// 刷新itemModel
        public func update() {
            uploadItemBlock?(self)
        }

        /// 选中当前行
        public func selected() {
            selectedToSelfBlock?(self)
        }

        // MARK: Internal

        /// 内部私有
        var tableIndexPath: IndexPath = .init(row: 0, section: 0)
        /// 选中当前行调用
        var selectedToSelfBlock: ((Item) -> Void)?
        /// 刷新Item
        var uploadItemBlock: ((Item) -> Void)?
    }

    open class Group {
        // MARK: Lifecycle

        public required init(items: [WPTableItem] = []) {
            self.items = items
        }

        public init<T: UITableViewHeaderFooterView>(headerClass: T.Type) {
            headViewClass = headerClass
            headViewReuseIdentifier = NSStringFromClass(headerClass)
        }

        public init<T: UITableViewHeaderFooterView>(footerClass: T.Type) {
            footViewClass = footerClass
            footViewReuseIdentifier = NSStringFromClass(footerClass)
        }

        // MARK: Public

        /// 当前组下的item
        public var items: [WPTableItem] = []
        /// 当前状态
        public var state = UIControl.State.normal
        /// 头部标题
        public var headerTitle: String?
        /// 尾部标题
        public var footerTitle: String?
        /// 头部的高 默认使用AutoLayout
        public var headerHeight: CGFloat = UITableView.automaticDimension
        /// 尾部的高 默认使用AutoLayout
        public var footerHeight: CGFloat = UITableView.automaticDimension

        /// 当前组索引
        public var section: Int = 0
        /// 即将添加一个item
        public var didAddItem: ((_ section: Int, _ style: UITableView.RowAnimation) -> Void)?
        /// 即将价值一个item时的动画
        public var didLoadStyle = UITableView.RowAnimation.fade
        /// 头部缓存标识符
        public var headViewReuseIdentifier: String?
        /// 尾部缓存标识符
        public var footViewReuseIdentifier: String?
        /// 头部class
        public var headViewClass = UITableViewHeaderFooterView.self
        /// 尾部class
        public var footViewClass = UITableViewHeaderFooterView.self
        /// 头部即将显示block
        public var headWillDisplayBlock: ((UITableViewHeaderFooterView) -> Void)?
        /// 尾部即将显示block
        public var footWillDisplayBlock: ((UITableViewHeaderFooterView) -> Void)?
        /// 附件 可用来传值
        public var info: Any?
    }
}
