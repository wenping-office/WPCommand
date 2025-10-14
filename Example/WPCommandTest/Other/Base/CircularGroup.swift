//
//  CircularGroup.swift
//  ShoppingCommon
//
//  Created by Wen on 2023/8/24.
//

import UIKit
import WPCommand

open class CircularGroup: WPTableGroup {
   
    public init(headerClass:UITableViewHeaderFooterView.Type){
        super.init(headerClass: headerClass.self)
    }
    
    public init(circularItems:[CircularItem] = []){
        super.init()
        self.circularItems = circularItems
        headerHeight = 0
        footerHeight = 0
    }
    
    required public init(items: [WPTableItem] = []) {
        fatalError("init(items:) has not been implemented")
    }
    
    public var circularItems:[CircularItem]{
        set{
            items = newValue
            newValue.forEach { item in
                item.isShowLine = true
                item.willDisplay = { cell in
                    if let cirCell = cell as? CircularCell{
                        cirCell.contentBackgroundView.layoutIfNeeded()
                        cirCell.contentBackgroundView.wp.corner([.topLeft,.topRight], radius: 0)
                    }
                }
            }

            if newValue.count == 1{
                circularItems.first?.willDisplay = { cell in
                    if let cirCell = cell as? CircularCell{
                        cirCell.contentBackgroundView.layoutIfNeeded()
                        cirCell.contentBackgroundView.wp.corner([.topLeft,.topRight,.bottomLeft,.bottomRight], radius: 15)
                    }
                }
            }else{
                newValue.first?.willDisplay = { cell in
                    if let cirCell = cell as? CircularCell{
                        cirCell.contentBackgroundView.layoutIfNeeded()
                        cirCell.contentBackgroundView.wp.corner([.topLeft,.topRight], radius: 15)
                    }
                }

                newValue.last?.willDisplay = { cell in
                    if let cirCell = cell as? CircularCell{
                        cirCell.contentBackgroundView.layoutIfNeeded()
                        cirCell.contentBackgroundView.wp.corner([.bottomLeft,.bottomRight], radius: 15)
                    }
                }
            }
            newValue.last?.isShowLine = false
        }
        get{
            return items as! [CircularItem]
        }
    }
    
}

open class CircularItem: WPTableItem {
    fileprivate var isShowLine = true
    
    public var isHiddenLine = false
}

open class CircularCell: WPBaseTableViewCell {
    // 背景视图
    public let contentBackgroundView = UIView().wp.backgroundColor(.gray).value()
    public let separatorView = UIView().wp.do { view in
        if #available(iOS 13.0, *) {
            view.backgroundColor = .separator
        } else {
            view.backgroundColor = .black
        }
    }.value()
    
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
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.bottom.equalToSuperview().offset(0)
        }
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalTo(contentBackgroundView)
            make.left.equalTo(contentBackgroundView).offset(15)
            make.right.equalTo(contentBackgroundView).offset(-15)
            make.height.equalTo(1)
        }
    }
    
    open override func didSetItem(item: WPTableItem) {
        super.didSetItem(item: item)
        
        if let newItem = item as? CircularItem{
            
            if newItem.isShowLine {
                separatorView.isHidden = newItem.isHiddenLine
            }else{
                separatorView.isHidden = true
            }
        }
    }
}
