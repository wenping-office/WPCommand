//
//  WPAutoLatticeView.swift
//  WPCommand
//
//  Created by Wen on 2023/10/16.
//

import SnapKit
import UIKit

/// 支持自适应布局格子视图
public class WPAutoLatticeView: UIView {
    public enum EqualType {
        case equal(_ num: CGFloat, _ priority: ConstraintPriority = .required)
        case greaterThanOrEqualTo(_ num: CGFloat, _ priority: ConstraintPriority = .required)
        case lessThanOrEqualTo(_ num: CGFloat, _ priority: ConstraintPriority = .required)
    }

    /// 内容视图
    public var views: [UIView] {
        didSet {
            contentView.wp.removeAllSubView()
            resetSubView()
        }
    }

    /// 所有内容视图 包括占位view
    public var allViews: [UIView] {
        var newViews = views
        let placeCount = col - views.count % col

        if placeCount == col {
            return newViews
        }

        for _ in 0..<placeCount {
            newViews.append(placeholderView())
        }
        return newViews
    }
    
    /// 列
    let col: Int
    /// 内容视图
    let contentView = UIStackView()
    /// item高度
    let itemHeight: EqualType?
    /// item宽度
    let itemWidth: EqualType?
    
    /// 每一行间距
    public var rowSpacing: CGFloat {
        set {
            contentView.spacing = newValue
        }
        get {
            return contentView.spacing
        }
    }
    
    /// 填充方式
    public var colDistribution = UIStackView.Distribution.fillEqually {
        didSet {
            contentView.arrangedSubviews.forEach { view in
                (view as? UIStackView)?.distribution = colDistribution
            }
        }
    }
    
    /// 列对其方式
    public var colAlignment = UIStackView.Alignment.center {
        didSet {
            contentView.arrangedSubviews.forEach { view in
                (view as? UIStackView)?.alignment = colAlignment
            }
        }
    }
    
    /// 列间距
    public var colSpacing: CGFloat = 0 {
        didSet {
            contentView.arrangedSubviews.forEach { view in
                (view as? UIStackView)?.spacing = colSpacing
            }
        }
    }
    
    /// 格子视图
    /// - Parameters:
    ///   - views: 视图
    ///   - col: 列
    ///   - itemHeight: item高度
    ///   - itemWidth: item宽度
    public init(views: [UIView], col: Int, itemHeight: EqualType? = nil,itemWidth: EqualType? = nil) {
        self.views = views
        self.col = col
        self.itemHeight = itemHeight
        self.itemWidth = itemWidth
        super.init(frame: .zero)

        contentView.axis = .vertical
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        resetSubView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 重置视图
    func resetSubView() {
        let newViews = allViews.wp_section(with: col)

        for row in 0..<newViews.count {
            let subViews = newViews[row]
            for view in subViews {
                getRow(row).addArrangedSubview(view)
                if let height = self.itemHeight {
                    view.snp.makeConstraints { make in
                        switch height {
                        case .equal(let num, let pri):
                            make.height.equalTo(num).priority(pri)
                        case .greaterThanOrEqualTo(let num, let pri):
                            make.height.greaterThanOrEqualTo(num).priority(pri)
                        case .lessThanOrEqualTo(let num, let pri):
                            make.height.lessThanOrEqualTo(num).priority(pri)
                        }
                        
                    }
                }
                
                if let width = self.itemWidth {
                    view.snp.makeConstraints { make in
                        switch width {
                        case .equal(let num, let pri):
                            make.width.equalTo(num).priority(pri)
                        case .greaterThanOrEqualTo(let num, let pri):
                            make.width.greaterThanOrEqualTo(num).priority(pri)
                        case .lessThanOrEqualTo(let num, let pri):
                            make.width.lessThanOrEqualTo(num).priority(pri)
                        }
                        
                    }
                }
            }
        }
    }
    
    /// 占位视图
    func placeholderView() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return view
    }
    
    /// 刷新检查每一行占位视图
    public func checkRowViewHidden() {
        contentView.arrangedSubviews.forEach { view in
            view.isHidden = !view.subviews.wp_isContent(in: { view in
                !view.isHidden
            })
        }
    }
    
    /// 清除所有视图
    public func clear() {
        contentView.arrangedSubviews.forEach { view in
            (view as? UIStackView)?.wp.removeAllSubView()
            contentView.wp.remove(view)
        }
        
        views.forEach { view in
            view.removeFromSuperview()
        }
        views = []
    }

    func getRow(_ row: Int) -> UIStackView {
        let target = contentView.arrangedSubviews.wp_get(of: row)
        if target == nil {
            let stackView = UIStackView()
            stackView.spacing = colSpacing
            stackView.alignment = colAlignment
            stackView.distribution = colDistribution
            contentView.addArrangedSubview(stackView)
            stackView.distribution = .equalSpacing
            stackView.alignment = .center
            return stackView

        } else {
            return target as! UIStackView
        }
    }
}
