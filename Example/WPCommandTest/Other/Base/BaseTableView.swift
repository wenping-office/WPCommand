//
//  BaseTableView.swift
//  ShoppingCommon
//
//  Created by Wen on 2023/8/22.
//

import UIKit


open class BaseTableView: UITableView {
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: style)
        
        contentInsetAdjustmentBehavior = .never
        tableFooterView = UIView()
        backgroundColor = .clear
        separatorColor = .none
        separatorStyle = .none
        
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
