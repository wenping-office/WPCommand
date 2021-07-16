//
//  WPLatticeCell.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/29.
//

import UIKit
import SnapKit
import Kingfisher

open class WPLatticeCell: UICollectionViewCell{
    let imageView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   @objc open override func didSetItem(item: WPCollectionItem) {
        guard let item = item as? WPLatticeItem else { return }
        
        if let image = item.image {
            imageView.image = image
        }else if let url = item.url {
            imageView.kf.setImage(with: URL(string: url))
        }else{
            imageView.image = nil
        }
    }
}
