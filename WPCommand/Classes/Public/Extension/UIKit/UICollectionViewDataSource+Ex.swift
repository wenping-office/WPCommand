//
//  UICollectionViewDataSource+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/18.
//

import UIKit

private var WPCollectionViewSourcePointer = "WPCollectionViewSourcePointer"

/// 扩展数据源
extension UICollectionView {
    /// 数据源
    var wp_source: WPCollectionViewSource {
        set {
            WPRunTime.set(self, newValue, &WPCollectionViewSourcePointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = self.wp_delegate
            dataSource = newValue
        }
        get {
            guard let source: WPCollectionViewSource = WPRunTime.get(self, &WPCollectionViewSourcePointer) else {
                let wp_source = WPCollectionViewSource(collectionView: self)
                self.wp_source = wp_source
                return wp_source
            }
            return source
        }
    }
}

public extension WPSpace where Base: UICollectionView {
    /// 桥接代理
    var dataSource: WPCollectionViewSource {
        return base.wp_source
    }
}

open class WPCollectionViewSource: WPScrollViewDelegate {
    weak var collectionView: UICollectionView!

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
    }

    /// 数据源
    public var groups: [WPCollectionGroup] = []

    /// 缓存标识符池
    private var identifiers: [String: String] = [:]
    
    /// 缓存标识符池
    private var viewIdentifiers: [String: String] = [:]

    /// 获取一个cell
    private func reusableCell(cellClass: UICollectionViewCell.Type,
                              indexPath: IndexPath) -> UICollectionViewCell
    {
        let key = NSStringFromClass(cellClass)
        let resualt = (identifiers[key] != nil)
        var id: String!
        if resualt {
            id = identifiers[key]
        } else {
            id = String.wp.random(length: 20)
            collectionView.register(cellClass, forCellWithReuseIdentifier: id)
            identifiers[key] = id
        }

        return collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
    }

    private func supplementaryView(kind: String,
                                   group: WPCollectionGroup,
                                   indexPath: IndexPath) -> UICollectionReusableView
    {
        var key: (key: String, isHeader: Bool) = ("", false)

        if kind == UICollectionView.elementKindSectionHeader {
            key = (NSStringFromClass(group.headViewClass), true)
        } else {
            key = (NSStringFromClass(group.footViewClass), false)
        }

        let resualt = (viewIdentifiers[key.key] != nil)
        var id: String!
        if resualt {
            id = viewIdentifiers[key.key]
        } else {
            id = String.wp.random(length: 20)
            if key.isHeader {
                collectionView.register(group.headViewClass,
                                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: id)
                viewIdentifiers[key.key] = id
            } else {
                collectionView.register(group.headViewClass,
                                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: id)
                viewIdentifiers[key.key] = id
            }
        }

        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath)
    }
}

extension WPCollectionViewSource: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groups.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups[section].items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = groups[indexPath.section].items[indexPath.row]
        let cell = reusableCell(cellClass: item.cellClass, indexPath: indexPath)
        item.uploadItemBlock = { item in
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.didSetItem(item: item)
        }
        cell.item = item
        cell.item?.indexPath = indexPath
        cell.didSetItem(item: item)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let group = groups[indexPath.section]
        let view = supplementaryView(kind: kind, group: group, indexPath: indexPath)
        group.uploadGroupBlock = { _ in
        }
        view.group = group
        view.didSetHeaderFooterModel(model: group)
        return view
    }
}
