//
//  WPlatticeItem.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/29.
//

import UIKit

open class WPLatticeItem: WPCollectionItem {
    /// 是否是占位符 需要自己判断
    public let isPlaceholder: Bool

    public required init(isPlaceholder: Bool = false) {
        self.isPlaceholder = isPlaceholder
        super.init()
    }
}
