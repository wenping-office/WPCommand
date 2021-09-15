//
//  UICollectionViewDataSource+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/18.
//

import UIKit

fileprivate var WPCollectionViewSourcePointer = "WPCollectionViewSourcePointer"

/// 扩展数据源
public extension UICollectionView{

    /// 数据源
    var wp_source : WPCollectionViewSource{
        set{
            WPRunTime.set(self, newValue, &WPCollectionViewSourcePointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = self.wp_delegate as? UICollectionViewDelegate
            dataSource = newValue
        }
        get{
            guard let source : WPCollectionViewSource = WPRunTime.get(self, &WPCollectionViewSourcePointer) else {
                let wp_source = WPCollectionViewSource(collectionView: self)
                self.wp_source = wp_source
                return wp_source
            }
          return source
        }
    }
}

open class WPCollectionViewSource: WPScrollViewDelegate {
    
    weak var collectionView : UICollectionView!
    
    init(collectionView : UICollectionView) {
        self.collectionView = collectionView
        super.init()
    }

    /// 数据源
    public var groups : [WPCollectionGroup] = []
    
    /// cellClass
    public var cellClass: AnyClass = UICollectionViewCell.self
    
    /// headerFooterClass
    public var headerFooterClass: AnyClass = UICollectionReusableView.self
}

extension WPCollectionViewSource : UICollectionViewDataSource{
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groups.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups[section].items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NSStringFromClass(headerFooterClass), for: indexPath)
        
        let group = groups[indexPath.section]
        
        group.uploadGroupBlock = { group in

        }
        view.group = group
        view.didSetHeaderFooterModel(model: group)
        return view
    }
}
