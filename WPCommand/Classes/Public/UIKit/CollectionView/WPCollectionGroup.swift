//
//  WPCollectionGroup.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/29.
//

import UIKit

open class WPCollectionGroup: NSObject {
    /// 单组数据
    open var items : [WPCollectionItem] = []
    /// 每一组边距
    open var groupEdgeInsets = UIEdgeInsets.zero
    /// 每一组item间距
    open var minimumInteritemSpacing : CGFloat = 0.0
    /// 每一组item间距
    open var minimumLineSpacing : CGFloat = 0.0
    /// 每一组headerSize
    open var headerSize = CGSize.zero
    /// 每一组footerSize
    open var footerSize = CGSize.zero
    /// 刷新group
    open var uploadGroupBlock : ((WPCollectionGroup)->Void)?
    /// 刷新cell的item
    open func update(){
        uploadGroupBlock != nil ? uploadGroupBlock!(self) : print()
    }
}


