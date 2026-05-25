//
//  WPPaddingView.swift
//  Alamofire
//
//  Created by Wen on 2024/1/11.
//

import UIKit
import SnapKit

/// 边距视图
public class WPPaddingView<T: UIView>: UIView {
    /// 目标视图
    public let target: T
    
    /// 创建一个内边距包裹视图
    /// - Parameters:
    ///   - target: 目标视图
    ///   - padding: 内边距
    ///   - priority: 约束等级
    public convenience init(_ target: T,
                padding: UIEdgeInsets = .zero,
                priority:ConstraintPriority = .required) {
        self.init(target, custom: { view in
            view.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(padding.left).priority(priority)
                make.right.equalToSuperview().offset(-padding.right).priority(priority)
                make.top.equalToSuperview().offset(padding.top).priority(priority)
                make.bottom.equalToSuperview().offset(-padding.bottom).priority(priority)
            }
        })
    }
    
    /// 自定义一个边距包裹试图
    /// - Parameters:
    ///   - target: 目标视图
    ///   - customLayout: 自定义布局
    public init(_ target: T,custom:((T)->Void)) {
        self.target = target
        super.init(frame: .zero)
        addSubview(target)
        weak var wTarget = target
        custom(wTarget!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

