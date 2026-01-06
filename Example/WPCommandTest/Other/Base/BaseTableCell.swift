//
//  BaseTableCell.swift
//  ShoppingCommon
//
//  Created by Wen on 2023/8/22.
//

import UIKit
import WPCommand

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
}
