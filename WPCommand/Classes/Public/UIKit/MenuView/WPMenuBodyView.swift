//
//  WPMenuChildView.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/15.
//

import UIKit

class WPMenuBodyViewItem: WPMenuView.Item {
    /// 展示的视图
    var bodyView: WPMenuBodyViewProtocol? {
        didSet {
            isAddToSuperView = false
        }
    }

    /// 是否加入到视图
    var isAddToSuperView = false
    /// 重用标识符
    var reuseIdentifier: String {
        return NSStringFromClass(WPMenuBodyCell.self) + index.description
    }

    init(index: Int,
         bodyView: WPMenuBodyViewProtocol?)
    {
        super.init(index: index)
        self.bodyView = bodyView
    }
}

/// 菜单视图
public class WPMenuBodyView: UITableViewCell {
    let layout = UICollectionViewFlowLayout()
    /// 内容视图
    public lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    /// 当前数据源
    var data: [WPMenuBodyViewItem] = []
    /// 内容滚动回调
    var contentOffSet: ((CGFloat) -> Void)?
    /// 当前滚动到的索引
    var didSelected: ((Int) -> Void)?
    /// 是否执行选中动画
    var selectedAnimate = false

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 注册视图
    func registerCell() {
        data.forEach { [weak self] elmt in
            self?.collectionView.register(WPMenuBodyCell.self, forCellWithReuseIdentifier: elmt.reuseIdentifier)
        }
    }

    /// 设置内容size
    func setCollectionSize(_ size: CGSize) {
        layout.itemSize = size
        collectionView.reloadData()
    }

    /// 选中一页
    /// - Parameter index: 索引
    func selected(_ index: Int) {
        collectionView.scrollToItem(at: .init(row: index, section: 0), at: .left, animated: selectedAnimate)
    }
}

extension WPMenuBodyView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        let cell = cell as? WPMenuBodyCell

        if !item.isAddToSuperView {
            cell?.setBodyView(item.bodyView?.menuBodyView())
            item.isAddToSuperView = true
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x / scrollView.wp.width
        contentOffSet?(offSet)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.wp.width + 0.5)
        didSelected?(index)
    }
}

extension WPMenuBodyView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = data[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath)
        return cell
    }
}

class WPMenuBodyCell: WPBaseCollectionViewCell {
    /// 内容视图
    var bodyView: UIView?

    override func initSubView() {
        backgroundColor = .clear
    }

    /// 添加一个视图
    func setBodyView(_ view: UIView?) {
        bodyView = view
        if let view = view {
            contentView.wp.removeAllSubViewFromSuperview()
            contentView.addSubview(view)
        } else {
            contentView.wp.removeAllSubViewFromSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bodyView?.frame = bounds
    }
}
