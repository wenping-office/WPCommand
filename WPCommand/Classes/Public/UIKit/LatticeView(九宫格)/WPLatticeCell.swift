//
//  WPLatticeCell.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/29.
//

import SnapKit
import UIKit

open class WPLatticeCell: UICollectionViewCell {
    let imageView = UIImageView()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override open func didSetItem(item: WPCollectionItem) {
        guard let item = item as? WPLatticeItem else { return }

        if item.isPlus {
            imageView.image = item.plusImg
        } else {
            if let image = item.image {
                imageView.image = image
            } else {
                imageView.image = nil
            }
        }
    }
}
