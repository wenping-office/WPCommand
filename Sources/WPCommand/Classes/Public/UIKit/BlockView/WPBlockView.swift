//
//  WPBlockView.swift
//  Alamofire
//
//  Created by Wen on 2024/1/11.
//

import UIKit

public extension WPBlockView {
    struct Item {
        public init() {}
        /// 标题
        public var title: NSAttributedString?
        /// 标题图片
        public var titleImage: UIImage?
        /// 描述
        public var describe: NSAttributedString?
        /// 描述图片
        public var describeImage: UIImage?
        /// 子描述
        public var subDescribe: NSAttributedString?
        /// 底部描述
        public var bottomDescribe: NSAttributedString?
    }
}

/// 静态视图 常用布局label封装
open class WPBlockView: WPBaseView {
    /// 标题
    public let titleLabel = UILabel().wp.textColor(.black).value()
    
    /// 标题图片
    public let titleImageView = UIImageView()
    
    /// 左边视图
    public lazy var leftStackView = UIStackView.wp
        .views([titleImageView, titleLabel])
        .alignment(.center)
        .spacing(6)
        .value()

    /// 描述
    public let desribeLabel = UILabel().wp
        .font(.systemFont(ofSize: 14))
        .textColor(.black)
        .numberOfLines(0)
        .textAlignment(.right)
        .value()

    /// 子描述
    public let subDesribeLabel = UILabel().wp
        .font(.systemFont(ofSize: 12))
        .textColor(.black)
        .numberOfLines(0)
        .textAlignment(.right)
        .value()
    
    /// 描述图片
    public let desribeImageView = UIImageView()
    
    /// 右边视图
    public lazy var rightTopView = UIStackView.wp
        .views([desribeLabel, desribeImageView])
        .spacing(4)
        .alignment(.center)
        .value()

    /// 占位图
    public let placeholderDesribeImageView = UIImageView().wp
        .isHidden(true)
        .padding(.zero, priority: .required)
    
    /// 右边子描述视图
    public lazy var rightBottomView = UIStackView.wp
        .views([subDesribeLabel, placeholderDesribeImageView])
        .spacing(4)
        .alignment(.center)
        .value()
    
    /// 右边视图
    public lazy var rightStackView = UIStackView.wp
        .views([rightTopView, rightBottomView])
        .spacing(4)
        .axis(.vertical)
        .alignment(.trailing)
        .value()
    
    /// 顶部视图
    public lazy var topStackView = UIStackView.wp
        .views([leftStackView, rightStackView])
        .spacing(10)
        .alignment(.top)
        .value()
    
    /// 底部视图
    public let bottomLabel = UILabel().wp
        .font(.systemFont(ofSize: 12))
        .textColor(.black)
        .numberOfLines(0)
        .value()

    /// 内容视图
    public lazy var contentStackView = UIStackView.wp
        .views([topStackView, bottomLabel])
        .axis(.vertical)
        .spacing(4).value()
    
    /// 数据模型
    public var item: Item = .init() {
        didSet {
            reset()
        }
    }
    
    /// 重置数据源
    public func reset() {
        titleLabel.attributedText = item.title
        desribeLabel.attributedText = item.describe
        subDesribeLabel.attributedText = item.subDescribe
        desribeImageView.image = item.describeImage
        placeholderDesribeImageView.target.image = item.describeImage
        titleImageView.image = item.titleImage
        titleImageView.isHidden = item.titleImage == nil
        subDesribeLabel.isHidden = (item.subDescribe?.length ?? 0) <= 0
        desribeLabel.isHidden = (item.describe?.length ?? 0) <= 0
        desribeImageView.isHidden = item.describeImage == nil
        placeholderDesribeImageView.isHidden = item.describeImage == nil || item.subDescribe?.length ?? 0 <= 0
        rightBottomView.isHidden = subDesribeLabel.isHidden
        titleLabel.isHidden = item.title?.length ?? 0 <= 0
        bottomLabel.attributedText = item.bottomDescribe
        bottomLabel.isHidden = item.bottomDescribe?.length ?? 0 <= 0

        leftStackView.isHidden = leftStackView.wp.subViewsAllHidden
        rightTopView.isHidden = rightTopView.wp.subViewsAllHidden
        rightBottomView.isHidden = rightBottomView.wp.subViewsAllHidden
        rightStackView.isHidden = rightStackView.wp.subViewsAllHidden
        topStackView.isHidden = topStackView.wp.subViewsAllHidden
         
        if desribeLabel.isHidden {
            titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        } else {
            titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
    }

    override open func initSubView() {
        super.initSubView()
        
        addSubview(contentStackView)
        
        subDesribeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        desribeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        desribeImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        desribeImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        placeholderDesribeImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        placeholderDesribeImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        titleImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                
        bottomLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        bottomLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    override open func initSubViewLayout() {
        super.initSubViewLayout()
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
