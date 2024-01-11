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
    public let titleLabel = UILabel()
    /// 标题图片
    public let titleImageView = UIImageView()
    /// 左边视图
    public lazy var leftStackView = UIStackView(arrangedSubviews: [titleImageView, titleLabel])
    
    /// 描述
    public let desribeLabel = UILabel()
    /// 子描述
    public let subDesribeLabel = UILabel()
    /// 描述图片
    public let desribeImageView = UIImageView()
    /// 右边视图
    public lazy var rightTopView = UIStackView(arrangedSubviews: [desribeLabel,desribeImageView])
    /// 占位图
    public let placeholderDesribeImageView = WPPaddingView(UIImageView(),padding: .zero,priority: .required)
    
    /// 右边子描述视图
    public lazy var rightBottomView = UIStackView(arrangedSubviews: [subDesribeLabel, placeholderDesribeImageView])
    
    /// 右边视图
    public lazy var rightStackView = UIStackView(arrangedSubviews: [rightTopView, rightBottomView])
    
    /// 顶部视图
    public lazy var topStackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
    
    /// 底部视图
    public let bottomLabel = UILabel()
    
    /// 内容视图
    public lazy var contentStackView = UIStackView(arrangedSubviews: [topStackView, bottomLabel])
    
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
         
        if desribeLabel.isHidden{
            titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }else{
            titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
    }

    override open func initSubView() {
        super.initSubView()
        
        titleLabel.textColor = .black
        leftStackView.alignment = .center
        leftStackView.spacing = 6

        desribeLabel.font = .systemFont(ofSize: 14)
        desribeLabel.textColor = .black
        desribeLabel.numberOfLines = 0
        desribeLabel.textAlignment = .right
        
        subDesribeLabel.font = .systemFont(ofSize: 12)
        subDesribeLabel.textColor = .black
        subDesribeLabel.numberOfLines = 0
        subDesribeLabel.textAlignment = .right
        placeholderDesribeImageView.target.isHidden = true

        rightTopView.spacing = 4
        rightTopView.alignment = .center
        
        rightBottomView.spacing = 4
        rightBottomView.alignment = .center
        
        topStackView.spacing = 10
        topStackView.alignment = .top

        rightStackView.spacing = 4
        rightStackView.axis = .vertical
        rightStackView.alignment = .trailing
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 4
        
        bottomLabel.font = .systemFont(ofSize: 12)
        bottomLabel.textColor = .black
        bottomLabel.numberOfLines = 0
        
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
