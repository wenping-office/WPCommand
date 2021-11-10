//
//  WPMenuHeaderView.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/18.
//

import UIKit

class WPMenuHeaderViewItem: WPMenuView.Item {
    /// 头部视图
    var headerView: WPMenuHeaderViewProtocol?
    /// 是否加入到视图
    var isAddToSuperView = false
    /// 重用标识符
    var reuseIdentifier: String {
        return NSStringFromClass(WPMenuBodyCell.self) + index.description
    }

    init(index: Int,
         headerView: WPMenuHeaderViewProtocol?)
    {
        super.init(index: index)
        self.headerView = headerView
    }
}

class WPMenuHeaderView: WPBaseTableViewCell {
    override func initSubView() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        selectionStyle = .none
    }

    /// 是否要设置高度
    var headerHeight: WPMenuView.HeaderHeightOption = .height(0)

    /// 数据源
    var datas: [WPMenuHeaderViewItem] = []

    /// 设置一个视图
    func setHeaderView(of view: WPMenuHeaderViewProtocol?, complete: @escaping (Bool) -> Void) {
        contentView.wp.removeAllSubViewFromSuperview()
        if let header = view?.menuHeaderView() {
            headerHeight = view?.menuHeaderViewAtHeight() ?? .height(0)
            contentView.addSubview(header)
            header.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            headerHeight = .height(0)
        }

        complete(true)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let filst = contentView.subviews.first
        filst?.frame = bounds
    }
}

