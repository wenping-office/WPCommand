//
//  PagesView.swift
//  WPCommand_Example
//
//  Created by 1234 on 2024/12/7.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

open class PagesView<Item:UIView>: BaseView {
    let stackView = UIStackView()
    
    public var totalCount: Int = 0 {
        didSet {
            stackView.arrangedSubviews.forEach { view in
                view.removeFromSuperview()
            }
            var index = 0
            while index < totalCount {
                let view = Item()
                view.snp.makeConstraints { make in
                    make.size.equalTo(viewSize)
                }
                view.layer.cornerRadius = itemRadius
                view.clipsToBounds = true
                stackView.addArrangedSubview(view)
                index += 1
            }
        }
    }
    
    /// 当前选中索引
    public var index: Int? {
        var viewIndex = 0
        var index: Int?
        stackView.arrangedSubviews.forEach { view in
            if view.tag == 1 {
                index = viewIndex
            }
            viewIndex += 1
        }
        
        return index
    }
    
    let viewSize: CGSize
    let normalColor: UIColor
    let selectedColor: UIColor
    let itemRadius: CGFloat
    
    public init(normalColor: UIColor,
                selectedColor: UIColor,
                viewSize: CGSize,
                spacing: CGFloat = 5,
                itemRadius: CGFloat = 0)
    {
        self.viewSize = viewSize
        self.normalColor = normalColor
        self.selectedColor = selectedColor
        self.itemRadius = itemRadius
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.spacing = spacing
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func setIndex(_ index: Int) {
        stackView.arrangedSubviews.forEach { view in
            view.tag = 0
            view.backgroundColor = normalColor
        }
        
        stackView.arrangedSubviews.wp.get(index)?.tag = 1
        stackView.arrangedSubviews.wp.get(index)?.backgroundColor = selectedColor
    }
}
