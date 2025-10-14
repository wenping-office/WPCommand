//
//  BaseCollectionView.swift
//  Common
//
//  Created by 1234 on 2024/11/18.
//

import UIKit

open class BaseCollectionView: UICollectionView {

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        contentInsetAdjustmentBehavior = .never
        backgroundColor = .clear
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
