//
//  WPlatticeItem.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/29.
//

import UIKit

open class WPLatticeItem: WPCollectionItem{
    
    /// 是否是+号 需要自己判断
    public let isPlus : Bool
    /// plus为true的时候图片
    public var plusImg : UIImage?
    /// image图片
    public var image : UIImage?
    
    required public init(isPlus:Bool = false,_ plusImg:UIImage?) {
        self.isPlus = isPlus
        super.init()
        self.plusImg = plusImg
    }
}


