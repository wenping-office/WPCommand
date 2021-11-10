//
//  WPCollectionAutoLayoutView.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/29.
//

import UIKit

open class WPCollectionAutoLayoutView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    /// 数据源
    open var groups: [WPCollectionGroup] = []
    
    /// cellClass
    open var cellClass: AnyClass = UICollectionViewCell.self
    
    /// headerFooterClass
    open var headerFooterClass: AnyClass = UICollectionReusableView.self
    
    /// 当前选中item的Block
    open var itemsSelectedBlock: ((WPCollectionItem) -> Void)?
    
    public init<T: UICollectionViewCell>(
        collectionViewLayout layout: UICollectionViewLayout,
        cellClass: T.Type
    ) {
        super.init(frame: .zero, collectionViewLayout: layout)
        register(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
        self.cellClass = cellClass
        dataSource = self
        delegate = self
    }
    
    public init<T: UICollectionViewCell>(
        cellClass: T.Type,
        selected: ((WPCollectionItem) -> Void)? = nil
    ) {
        let layout = UICollectionViewFlowLayout()
        super.init(frame: CGRect.zero, collectionViewLayout: layout)
        self.register(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
        self.cellClass = cellClass
        itemsSelectedBlock = selected
        dataSource = self
        delegate = self
    }
    
    public init(
        cellClass: AnyClass,
        headerFooterClass: AnyClass = UICollectionReusableView.self,
        scrollDirection: UICollectionView.ScrollDirection,
        selected: ((WPCollectionItem) -> Void)? = nil
    ) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        super.init(frame: CGRect.zero, collectionViewLayout: layout)
        
        self.register(headerFooterClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(headerFooterClass))
        self.register(headerFooterClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(headerFooterClass))
        
        self.register(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
        self.cellClass = cellClass
        self.headerFooterClass = headerFooterClass
        self.itemsSelectedBlock = selected
        self.dataSource = self
        self.delegate = self
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 数据源
public extension WPCollectionAutoLayoutView {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(self.cellClass), for: indexPath)
        let item = groups[indexPath.section].items[indexPath.row]
        
        item.uploadItemBlock = { item in
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.didSetItem(item: item)
        }
        
        cell.item = item
        cell.item?.indexPath = indexPath
        cell.didSetItem(item: item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NSStringFromClass(headerFooterClass), for: indexPath)
        
        let group = groups[indexPath.section]
        
        group.uploadGroupBlock = { _ in
        }
        view.group = group
        view.didSetHeaderFooterModel(model: group)
        return view
    }
}

/// UICollectionViewDelegate代理
public extension WPCollectionAutoLayoutView {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = groups[indexPath.section].items[indexPath.row]
        
        itemsSelectedBlock?(item)
        item.selectedBlock?(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = groups[indexPath.section].items[indexPath.row]
        item.willDisplay?(item, cell)
    }
}

/// UICollectionViewDelegateFlowLayout 代理
public extension WPCollectionAutoLayoutView {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return groups[indexPath.section].items[indexPath.row].itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return groups[section].groupEdgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(groups[section].minimumLineSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(groups[section].minimumInteritemSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return groups[section].headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return groups[section].footerSize
    }
}
