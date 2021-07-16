//
//  UICollectionViewCell+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UICollectionViewCell{
    
    @objc open func didSetItem(item:WPCollectionItem){}

}
var WPCollectionItemPointer = "WPCollectionItemPointer"

public protocol UICollectionCellProtocol : NSObjectProtocol{}

public extension UICollectionCellProtocol{
    var item : WPCollectionItem? {
        get{
            return objc_getAssociatedObject(self, &WPCollectionItemPointer) as? WPCollectionItem
        }
        set{
            objc_setAssociatedObject(self, &WPCollectionItemPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UICollectionViewCell:UICollectionCellProtocol{
        
    @objc public func reloadItemInfo(info:Any?){}
}


