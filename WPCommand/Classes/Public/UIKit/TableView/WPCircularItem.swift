//
//  WPCircularItem.swift
//  WPCommand
//
//  Created by Wen on 2024/1/11.
//

import UIKit


open class WPCircularItem: WPTableItem {
    
    /// 分割线颜色
    public var lineColor:UIColor = .gray
    /// 是否显示分割线 group使用
    public var isShowLine = true
    /// 是否显示分割线 当isShowLine 为true的时候有用
    public var isHiddenLine = false
    
    convenience init(){
        self.init(cellClass: WPCircularCell.self)
    }
}

/// 圆角Cell
open class WPCircularCell: WPBaseTableViewCell {
    /// 背景视图
    public let contentBackgroundView = UIView().wp.backgroundColor(.white).clipsToBounds(true).value()
    /// 分割线
    public let separatorView = UIView()
    
    open override func initSubView() {
        super.initSubView()
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(contentBackgroundView)
        contentView.addSubview(separatorView)
    }

    open override func initSubViewLayout() {
        super.initSubViewLayout()
        contentBackgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.top.bottom.equalToSuperview().offset(0)
        }
        
        separatorView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(contentBackgroundView)
            make.height.equalTo(0.5)
        }
    }
    
    open override func didSetItem(item: WPTableItem) {
        super.didSetItem(item: item)
        if let newItem = item as? WPCircularItem{
            separatorView.backgroundColor = newItem.lineColor
            if newItem.isShowLine {
                separatorView.isHidden = newItem.isHiddenLine
            }else{
                separatorView.isHidden = true
            }
        }
    }
}
