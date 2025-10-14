//
//  WPCollectionItem.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/29.
//

import UIKit

open class WPCollectionItem: NSObject {
    public enum status: Int {
        /// 默认状态
        case normal
        /// 选中状态
        case selected
    }

    /// cell
    public var cellClass : UICollectionViewCell.Type = UICollectionViewCell.self
    /// 尺寸
    public var itemSize = CGSize.init(width: 50, height: 50)
    /// 当前状态
    public var status = WPCollectionItem.status.normal
    /// 选中block
    public var selectedBlock: ((_ item: WPCollectionItem) -> Void)?
    /// 即将显示
    public var willDisplay: ((_ item: WPCollectionItem, _ cell: UICollectionViewCell) -> Void)?
    /// indexPath
    public var indexPath = IndexPath(item: 0, section: 0)
    /// 设置完info后回调
    public var didSetInfo: ((Any?) -> Void)?
    /// 刷新Item
    public var uploadItemBlock: ((WPCollectionItem) -> Void)?
    /// 附件
    public var info: Any? {
        didSet {
            guard let info = info else { return }
            didSetInfo?(info)
            didSetInfo(info: info)
            didSetItemInfo(info: info)
        }
    }

    /// 设置完Info后调用
    public func didSetInfo(info: Any?) {}
    /// 刷新cell的item
    public func update() {
        uploadItemBlock?(self)
    }
    
    /// 已经获取itemInfo
    @objc public func didSetItemInfo(info: Any?) {}
}

