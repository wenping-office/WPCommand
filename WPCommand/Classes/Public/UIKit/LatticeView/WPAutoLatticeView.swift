//
//  WPAutoLatticeView.swift
//  WPCommand
//
//  Created by Wen on 2023/10/16.
//

import UIKit


/// 支持自适应布局格子视图
public class WPAutoLatticeView: UIView {
        
        public enum EqualType {
            case equal(_ num: CGFloat)
            case greaterThanOrEqualTo(_ num: CGFloat)
            case lessThanOrEqualTo(_ num: CGFloat)
        }
        
        /// 内容视图
        public var views:[UIView]{
            didSet{
                contentView.wp.removeAllArrangedSubviews()
                resetSubView()
            }
        }
        /// 所有内容视图 包括占位view
        public var allViews:[UIView]{
            var newViews = views
            let placeCount = col - views.count % col
            
            if placeCount == col{
                return newViews
            }

            for _ in 0..<placeCount{
                newViews.append(placeholderView())
            }
            return newViews
        }
        let col:Int
        let contentView = UIStackView()
        let itemHeight:EqualType?
        
        public var rowSpacing:CGFloat{
            set{
                contentView.spacing = newValue
            }
            get{
                return contentView.spacing
            }
        }
        
        public var colDistribution = UIStackView.Distribution.fillEqually{
            didSet{
                contentView.arrangedSubviews.forEach { view in
                    (view as? UIStackView)?.distribution = colDistribution
                }
            }
        }
        public var colAlignment = UIStackView.Alignment.center{
            didSet{
                contentView.arrangedSubviews.forEach { view in
                    (view as? UIStackView)?.alignment = colAlignment
                }
            }
        }
        public var colSpacing:CGFloat = 0{
            didSet{
                contentView.arrangedSubviews.forEach { view in
                    (view as? UIStackView)?.spacing = colSpacing
                }
            }
        }

        public init(views:[UIView], col:Int,itemHeight:EqualType? = nil) {
            self.views = views
            self.col = col
            self.itemHeight = itemHeight
            super.init(frame: .zero)

            contentView.axis = .vertical
            addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            resetSubView()
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        func resetSubView(){
            let newViews = allViews.wp_section(with: col)
            
            for row in 0..<newViews.count{
                let subViews = newViews[row]
                for view in subViews {
                    getRow(row).addArrangedSubview(view)
                    if let height = self.itemHeight {
                        view.snp.makeConstraints { make in
                            switch height{
                            case .equal(let num):
                                make.height.width.equalTo(num).priority(.high)
                            case .greaterThanOrEqualTo(let num):
                                make.height.width.greaterThanOrEqualTo(num).priority(.high)
                            case .lessThanOrEqualTo(let num):
                                make.height.width.lessThanOrEqualTo(num).priority(.high)
                            }
                        }
                    }
                }
            }
        }
        
        func placeholderView() ->UIView {
            let view = UIView()
            view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            view.setContentHuggingPriority(.defaultHigh, for: .vertical)
            view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            return view
        }

        public func checkRowViewHidden(){
            contentView.arrangedSubviews.forEach { view in
                view.isHidden = !view.subviews.wp_isContent(in: { view in
                    return !view.isHidden
                })
            }
        }
        
        public func clear(){
            contentView.arrangedSubviews.forEach { view in
                (view as? UIStackView)?.wp.removeAllArrangedSubviews()
            }
        }

        func getRow(_ row :Int) -> UIStackView {
            let target = contentView.arrangedSubviews.wp_get(of: row)
            if target == nil{
                let stackView = UIStackView()
                stackView.spacing = colSpacing
                stackView.alignment = colAlignment
                stackView.distribution = colDistribution
                contentView.addArrangedSubview(stackView)
                stackView.distribution = .equalSpacing
                stackView.alignment = .center
                return stackView
                
            }else{
                return target as! UIStackView
            }
        }

    }

