//
//  UICollectionViewCell+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension UICollectionViewCell{
    /// 加载的collectionView
    var wp_collectionView: UICollectionView? {
        return superview as? UICollectionView
    }
}

extension UICollectionViewCell{
    
    /// 已赋值item后调用
    /// - Parameter item: item模型
    @objc open func didSetItem(item:WPCollectionItem){}

}




