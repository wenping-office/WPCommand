//
//  UITextView+Rx.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/10/16.
//

import UIKit
import RxSwift

public extension WPSpace where Base: UITextView {
    @discardableResult
    func placeholder(_ placeholder:String?,
                     padding:UIEdgeInsets = .init(top: 8, left: 0, bottom: 8, right: 0),
                     config:((UILabel)->Void)? = nil) -> Self {
        
        let tag = -1999888
        let placeView = base.subviews.wp.elementFirst(where: { $0.tag == tag})

        placeView?.removeFromSuperview()
        if placeholder == nil {
            return self
        }
        let label = UILabel().wp.padding { labe in
            labe.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(5+padding.left)
                make.right.equalToSuperview().offset(-(padding.right+5)).priority(.high)
                make.top.equalToSuperview().offset(padding.top)
                make.bottom.equalToSuperview().offset(-padding.bottom)
            }
        }
        label.tag = tag
        label.target.text = placeholder
        label.target.numberOfLines = 0
        label.target.font = base.font
        label.target.textColor = .wp.initWith(198, 198, 198, 1)
        label.target.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.target.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.isUserInteractionEnabled = false

        base.addSubview(label)
        weak var wLabel = label.target
        config?(wLabel!)
        
        label.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.greaterThanOrEqualTo(base.font?.pointSize ?? 0 + padding.top)
        }
        base.rx.text.map { str in
            return !(str?.count ?? 0 <= 0)
        }.bind(to: label.rx.isHidden).disposed(by: label.wp.disposeBag)
        return self
    }
}
