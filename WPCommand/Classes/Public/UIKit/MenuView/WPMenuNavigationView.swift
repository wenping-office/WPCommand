//
//  WPMenuNavigationView.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/15.
//

import UIKit

class WPMenuNavigationItem: WPMenuView.Item {
    /// 每一个item的size
    let size: CGSize
    /// item
    let navigationItem: WPMenuNavigationViewProtocol

    init(size: CGSize,
         index: Int,
         item: WPMenuNavigationViewProtocol)
    {
        self.size = size
        self.navigationItem = item
        super.init(index: index)
    }
}

class WPMenuNavigationView: UITableViewHeaderFooterView {
    let layout = UICollectionViewFlowLayout()
    /// 内容视图
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    /// 当前数据源
    var data: [WPMenuNavigationItem] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    /// 选中按钮回调
    var didSelected: ((Int) -> Void)?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        let backView = UIView()
        backView.backgroundColor = .clear
        backgroundView = backView
        contentView.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.top.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 注册视图
    func registerCell() {
        for index in 0 ..< data.count {
            let reuseIdentifier = NSStringFromClass(WPMenuNavigationCell.self) + index.description
            collectionView.register(WPMenuNavigationCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        }
    }
}

extension WPMenuNavigationView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return data[indexPath.row].size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelected?(indexPath.row)
    }
}

extension WPMenuNavigationView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = NSStringFromClass(WPMenuNavigationCell.self) + indexPath.row.description
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WPMenuNavigationCell
        cell.navItem = data[indexPath.row]
        return cell
    }
}

/// 菜单视图
class WPMenuNavigationCell: WPBaseCollectionViewCell {
    override func initSubView() {
        backgroundColor = .clear
    }

    /// 导航栏item
    var navItem: WPMenuNavigationItem? {
        didSet {
            if let item = navItem {
                if let menuView = superview?.superview?.superview as? WPMenuView {
                    item.navigationItem.menuViewChildViewUpdateStatus(menuView: menuView, status: .normal)
                }
                wp.removeAllSubViewFromSuperview()
                addSubview(item.navigationItem)
                item.navigationItem.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        }
    }
}
