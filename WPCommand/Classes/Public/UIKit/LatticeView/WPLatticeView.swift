//
//  WPLatticeView.swift
//  Worker
//
//  Created by WenPing on 2021/4/14.
//

import UIKit

open class WPLatticeView<cellT: WPLatticeCell, itemT: WPLatticeItem>: UIView {
    private lazy var contentView = WPCollectionAutoLayoutView(cellClass: cellT.self, scrollDirection: .vertical) { [weak self] item in
        self?.action?(item as! itemT)
    }
    
    /// 内容group
    public let contentGroup = WPCollectionGroup()
    
    /// 每一个itemSize的尺寸
    public var itemSize: CGSize {
        return CGSize(width: (maxWidth - (CGFloat(col - 1) * padding)) / CGFloat(col), height: itemHeight)
    }
    
    /// 当前内容的高度
    public var contentHeight: CGFloat {
        return CGFloat(row) * itemHeight + CGFloat(row - 1) * padding
    }
    
    /// 总共多少行
    public var row: Int {
        var count = contentGroup.items.count
        if count > maxCount {
            count = count - 1
        }
        return count % col == 0 ? count / col : count / col + 1
    }
    
    /// 是否显示占位
    public var isShowPlaceholder = false {
        didSet {
            var searchResualt = false
            
            for item in contentGroup.items as! [itemT] {
                if item.isPlaceholder {
                    searchResualt = true
                }
            }
            if isShowPlaceholder, searchResualt != true {
                let plus = itemT(isPlaceholder: true)
                plus.itemSize = itemSize
                contentGroup.items.append(plus)
            } else if isShowPlaceholder == false, searchResualt {
                contentGroup.items.removeLast()
            }
            contentView.reloadData()
        }
    }
    /// 多少列
    public let col: Int
    /// 内容间距
    public let padding: CGFloat
    /// LatticeView的宽
    public let maxWidth: CGFloat
    /// 每一个Item的Height
    public let itemHeight: CGFloat
    /// 总共能加多少个Item plusItem除外
    public let maxCount: Int
    /// 点击了item的动作
    public var action: ((_ item: itemT)->Void)?
    
    /// 初始化一个九宫格试图
    /// - Parameters:
    ///   - col: 多少列
    ///   - padding: 间距
    ///   - maxWidth: 最大的宽
    ///   - itemHeight: 每个小格的高
    ///   - maxCount: 总共显示多少个
    ///   - action: 点击了每一个小格的动作
    public init(col: Int, padding: CGFloat, maxWidth: CGFloat, itemHeight: CGFloat, maxCount: Int, action: ((_ item: itemT)->Void)? = nil) {
        self.col = col
        self.padding = padding
        self.maxWidth = maxWidth
        self.itemHeight = itemHeight
        self.maxCount = maxCount
        self.action = action
        super.init(frame: CGRect.zero)
        contentGroup.minimumLineSpacing = padding
        contentGroup.minimumInteritemSpacing = padding
        contentView.groups.append(contentGroup)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        contentView.isScrollEnabled = false
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    /// 添加一组subItem
    /// - Parameter Lattices: 一组Item
    public func set(_ lattices: [itemT]) {
        let totalCount = lattices.count + contentGroup.items.count + (isShowPlaceholder ? -1 : 0)
        if totalCount > maxCount { print("WPLatticeView 超过了最大数量"); return }
        for item in lattices {
            item.itemSize = itemSize
        }
        contentGroup.items.insert(contentsOf: lattices, at: 0)
        contentView.reloadData()
    }
    
    /// 清除
    public func clear() {
        contentGroup.items.removeAll()
        if isShowPlaceholder {
            let plus = itemT(isPlaceholder: true)
            plus.itemSize = itemSize
            contentGroup.items.append(plus)
        }
        contentView.reloadData()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


