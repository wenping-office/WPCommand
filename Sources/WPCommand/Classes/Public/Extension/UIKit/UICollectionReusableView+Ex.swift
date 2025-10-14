//
//  UICollectionReusableView+Ex.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UICollectionReusableView: WPCollectionReusableViewProtocol {
    /// 扩展一个即将获得group方法
    /// - Parameter model: 模型
    @objc open func didSetHeaderFooterModel(model: WPCollectionGroup) {}
}
