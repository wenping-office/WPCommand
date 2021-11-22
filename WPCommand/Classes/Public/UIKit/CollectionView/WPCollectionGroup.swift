//
//  WPCollectionGroup.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/29.
//

import UIKit

open class WPCollectionGroup: NSObject {

    /// 头部class
    public let headViewClass : UICollectionReusableView.Type = UICollectionReusableView.self
    /// 尾部class
    public let footViewClass : UICollectionReusableView.Type = UICollectionReusableView.self
    /// 单组数据
    public var items: [WPCollectionItem] = []
    /// 每一组边距
    public var groupEdgeInsets = UIEdgeInsets.zero
    /// 每一组item间距
    public var minimumInteritemSpacing: CGFloat = 0.0
    /// 每一组item间距
    public var minimumLineSpacing: CGFloat = 0.0
    /// 每一组headerSize
    public var headerSize = CGSize.zero
    /// 每一组footerSize
    public var footerSize = CGSize.zero
    /// 刷新group
    public var uploadGroupBlock: ((WPCollectionGroup) -> Void)?
    /// 刷新cell的item
    public func update() {
        uploadGroupBlock?(self)
    }
}
