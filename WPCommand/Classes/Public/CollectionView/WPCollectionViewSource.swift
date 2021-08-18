//
//  WPCollectionViewSource.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/17.
//

import UIKit

fileprivate var WPCollectionViewSourcePointer = "WPTableViewSourcePointer"

/// 扩展数据源
public extension UICollectionView{

    /// 数据源
    var wp_source : WPCollectionViewSource{
        set{
            WPRunTime.set(self, newValue, &WPCollectionViewSourcePointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = newValue
            dataSource = newValue
        }
        get{
            guard let source : WPCollectionViewSource = WPRunTime.get(self, &WPCollectionViewSourcePointer) else {
                let wp_source = WPCollectionViewSource()
                delegate = wp_source
                dataSource = wp_source
                self.wp_source = wp_source
                return wp_source
            }
          return source
        }
    }
}



public class WPCollectionViewSource: WPScrollViewDelegate {
    /// 数据源
    open var groups : [WPCollectionGroup] = []
    
    /// cellClass
    open var cellClass: AnyClass = UICollectionViewCell.self
    
    /// headerFooterClass
    open var headerFooterClass: AnyClass = UICollectionReusableView.self
    
    /// 当前选中item的Block
    open var itemsSelectedBlock : ((WPCollectionItem)->Void)?
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

extension WPCollectionViewSource:UICollectionViewDelegate{
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = groups[indexPath.section].items[indexPath.row]
        
        itemsSelectedBlock != nil ? itemsSelectedBlock!(item) : print("")
        item.selectedBlock != nil ? item.selectedBlock!(item) : print("")
        
    }
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
