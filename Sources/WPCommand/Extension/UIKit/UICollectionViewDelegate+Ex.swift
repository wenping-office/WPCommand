//
//  UICollectionViewDelegate+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/18.
//

import UIKit

private var WPCollectionDelegatePointer = "WPCollectionDelegatePointer"

extension UICollectionView {
    var wp_delegate: WPCollectionViewDelegate {
        set {
            WPRunTime.set(self, newValue, withUnsafePointer(to: &WPCollectionDelegatePointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = newValue
        }
        get {
            guard let wp_delegate: WPCollectionViewDelegate = WPRunTime.get(self, withUnsafePointer(to: &WPCollectionDelegatePointer, {$0})) else {
                let wp_delegate = WPCollectionViewDelegate()
                self.wp_delegate = wp_delegate
                return wp_delegate
            }
            return wp_delegate
        }
    }
}

public extension WPSpace where Base: UICollectionView {
    /// 桥接代理
    var delegate: WPCollectionViewDelegate {
        return base.wp_delegate
    }
}

open class WPCollectionViewDelegate: WPScrollViewDelegate {
    /// 点击了某一个cell
    public var didSelectItemAt: ((UICollectionView, IndexPath) -> Void)?
    /// item的尺寸
    public var layoutSizeForItemAt: ((UICollectionView, UICollectionViewLayout, IndexPath) -> CGSize)?
    /// 内边距
    public var layoutInsetForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> UIEdgeInsets)?
    /// 每组最小间距
    public var layoutMinimumLineSpacingForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)?
    /// 每组间距
    public var layoutMinimumInteritemSpacingForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)?
    /// 每一组头部视图size
    public var layoutReferenceSizeForHeaderInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)?
    /// 每一组尾部试图size
    public var layoutReferenceSizeForFooterInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)?
}

extension WPCollectionViewDelegate: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if layoutSizeForItemAt != nil {
            return layoutSizeForItemAt!(collectionView, collectionViewLayout, indexPath)
        } else if let item = collectionView.wp_source.groups.wp.get(indexPath.section)?.items.wp.get(indexPath.row) {
            return item.itemSize
        } else {
            return .zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if layoutInsetForSectionAt != nil {
            return layoutInsetForSectionAt!(collectionView, collectionViewLayout, section)
        } else if let group = collectionView.wp_source.groups.wp.get(section){
            return group.groupEdgeInsets
        } else {
            return .zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if layoutMinimumLineSpacingForSectionAt != nil {
            return layoutMinimumLineSpacingForSectionAt!(collectionView, collectionViewLayout, section)
        } else if let group = collectionView.wp_source.groups.wp.get(section){
            return group.minimumLineSpacing
        } else {
            return 0
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if layoutMinimumInteritemSpacingForSectionAt != nil {
            return layoutMinimumInteritemSpacingForSectionAt!(collectionView, collectionViewLayout, section)
        } else if let group = collectionView.wp_source.groups.wp.get(section){
            return group.minimumInteritemSpacing
        } else {
            return 0
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if layoutReferenceSizeForHeaderInSection != nil {
            return layoutReferenceSizeForHeaderInSection!(collectionView, collectionViewLayout, section)
        } else if let group = collectionView.wp_source.groups.wp.get(section){
            return group.headerSize
        } else {
            return .zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if layoutReferenceSizeForFooterInSection != nil {
            return layoutReferenceSizeForFooterInSection!(collectionView, collectionViewLayout, section)
        } else if let group = collectionView.wp_source.groups.wp.get(section){
            return group.footerSize
        } else {
            return .zero
        }
    }
}

extension WPCollectionViewDelegate: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemAt?(collectionView, indexPath)
        if let item = collectionView.wp_source.groups.wp.get(indexPath.section)?.items.wp.get(indexPath.row){
            item.selectedBlock?(item)
        }
    }
}
