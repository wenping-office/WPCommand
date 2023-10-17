//
//  StackScrollView.swift
//  WPCommand
//
//  Created by Wen on 2023/10/16.
//

import UIKit

open class WPStackScrollView: UIScrollView {
    public let stackView:UIStackView

    public init(views:[UIView] = [],
                maxWidth: CGFloat? = nil,
                maxHeight: CGFloat? = nil,
                padding: UIEdgeInsets = .zero) {
        self.stackView = UIStackView(arrangedSubviews: views)
        super.init(frame: .zero)
        backgroundColor = .clear
        panGestureRecognizer.delaysTouchesBegan = true
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(padding.left)
            make.top.equalToSuperview().offset(padding.top)
            make.bottom.equalToSuperview().offset(-padding.bottom)
            make.right.equalToSuperview().offset(-padding.right)

            if let width = maxWidth {
                make.width.equalTo(width)
            }
            if let height = maxHeight {
                make.height.equalTo(height)
            }
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
