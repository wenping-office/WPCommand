//
//  WPlatticeItem.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/29.
//

import UIKit

open class WPLatticeItem: WPCollectionItem{
    /// 是否是+号
    public let isPlus : Bool
    /// image图片
    public var image : UIImage?
    /// 网络图片url
    public var url : String?
    
    required public init(isPlus:Bool = false) {
        self.isPlus = isPlus
        super.init()
        if isPlus {
            image = UIImage(named: "photo_plus")
        }
    }
}


