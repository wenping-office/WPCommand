//
//  BaseTableCell.swift
//  ShoppingCommon
//
//  Created by Wen on 2023/8/22.
//

import UIKit
import WPCommand

open class BaseTableItem: WPTableItem{
    public var contentEdge = UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)
}

open class BaseTableCell: WPBaseTableViewCell {

    // 背景视图
    public let contentBackgroundView = UIView().wp.backgroundColor(.black).cornerRadius(18).clipsToBounds(true).value()
    
    open override func initSubView() {
        super.initSubView()
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(contentBackgroundView)
    }

    open override func initSubViewLayout() {
        super.initSubViewLayout()
        contentBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().offset(0)
            make.top.bottom.equalToSuperview().offset(0)
        }
    }
    
    open override func didSetItem(item: WPTableItem) {
        
        if let newItem = item as? BaseTableItem{
            contentBackgroundView.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(newItem.contentEdge.left)
                make.right.equalToSuperview().offset(-newItem.contentEdge.right)
                make.top.equalToSuperview().offset(newItem.contentEdge.top)
                make.bottom.equalToSuperview().offset(-newItem.contentEdge.bottom)
            }
        }
    }
}
