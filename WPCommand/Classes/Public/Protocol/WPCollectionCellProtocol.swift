//
//  WPCollectionCellProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/26.
//

import UIKit

var WPCollectionItemPointer = "WPCollectionItemPointer"

public protocol WPCollectionCellProtocol : NSObjectProtocol{}

public extension WPCollectionCellProtocol{
    var item : WPCollectionItem? {
        get{
            return objc_getAssociatedObject(self, &WPCollectionItemPointer) as? WPCollectionItem
        }
        set{
            objc_setAssociatedObject(self, &WPCollectionItemPointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UICollectionViewCell:WPCollectionCellProtocol{
        
    @objc open func reloadItemInfo(info:Any?){}
}
