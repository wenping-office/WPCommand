//
//  WPCollectionItem.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/29.
//

import UIKit

open class WPCollectionItem: NSObject {
    public enum status:Int{
        /// 默认状态
        case normal
        /// 选中状态
        case selected
    }
    /// 尺寸
    open var itemSize:CGSize = CGSize.zero
    /// 当前状态
    open var status = WPCollectionItem.status.normal
    /// 选中block
    open var selectedBlock : ((_ item:WPCollectionItem)->())?
    /// 即将显示
    open var willDisplay : ((_ item:WPCollectionItem)->())?
    /// indexPath
    open var indexPath : IndexPath = IndexPath(item: 0, section: 0)
    /// 设置完info后回调
    open var didSetInfo : ((Any?) -> Void)?
    /// 刷新Item
    open var uploadItemBlock : ((WPCollectionItem) -> Void)?
    /// 附件
    open var info : Any?{
        didSet{
            guard let info = info  else { return }
            didSetInfo != nil ? didSetInfo!(info) : print("")
            didSetInfo(info: info)
            didSetItemInfo(info: info)
        }
    }
    /// 设置完Info后调用
    open func didSetInfo(info:Any?){}
    /// 刷新cell的item
    open func update(){
        uploadItemBlock != nil ? uploadItemBlock!(self) : print()
    }
    
    @objc public func didSetItemInfo(info:Any?){}
}


