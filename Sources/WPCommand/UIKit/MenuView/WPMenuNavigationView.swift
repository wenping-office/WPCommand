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
    class CollectionView: UICollectionView {
        
    }

    let layout = UICollectionViewFlowLayout()
    /// 内容视图
    lazy var collectionView = CollectionView(frame: .zero, collectionViewLayout: layout)
    /// 背景视图
    let backView = UIView()
    /// 当前数据源
    var data: [WPMenuNavigationItem] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    /// 左边视图
    var leftView:UIView?{
        didSet{
            for view in contentView.subviews{
                if !(view is CollectionView){
                    view.removeFromSuperview()
                }
            }

            if let view = leftView{
                contentView.addSubview(view)
            }
            
            if let view = rightView{
                contentView.addSubview(view)
            }
        }
    }
    /// 右边视图
    var rightView:UIView?{
        didSet{
            for view in contentView.subviews{
                if !(view is CollectionView){
                    view.removeFromSuperview()
                }
            }

            if let view = leftView{
                contentView.addSubview(view)
            }
            
            if let view = rightView{
                contentView.addSubview(view)
            }
        }
    }
    /// 导航栏选中样式
    var selectedStyle: WPMenuView.NavigationSelectedStyle = .center
    /// 导航栏选中动画样式
    private var navSelectedStyle: UICollectionView.ScrollPosition {
        switch selectedStyle {
        case .none:
            break
        case .left:
            return .left
        case .right:
            return .right
        case .center:
            return .centeredHorizontally
        }
        return .bottom
    }
    
    /// 下划线
    let lineView : WPMenuView.LineView = .init()
    /// 内部视图
    lazy var stackView = UIStackView(arrangedSubviews: [collectionView])
    /// 选中按钮回调
    var didSelected: ((Int) -> Void)?
    /// 滚动时试图还为创建记是否要第一次滚动
    private var scrollTo = false
    /// 记是否要第一次滚动
    private var scrollNormalIndex : Int?

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
        backgroundView = backView
        contentView.addSubview(collectionView)

        collectionView.addSubview(lineView)
        lineView.backgroundColor = .red
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        leftView?.sizeToFit()
        rightView?.sizeToFit()
        
        let leftViewWidth = leftView?.wp.width ?? 0
        let rightViewWidth = rightView?.wp.width ?? 0
        
        leftView?.wp_orgin = .init(x: 0, y: (wp_height - (leftView?.wp_height ?? 0)) * 0.5)
        rightView?.wp_orgin = .init(x: wp_width - rightViewWidth, y: (wp_height - (rightView?.wp_height ?? 0)) * 0.5)
        
        collectionView.frame = .init(x: leftViewWidth, y: 0, width: wp.width - leftViewWidth - rightViewWidth, height: wp.height)

        lineView.wp_height = lineView.lineHeight
        lineView.wp_y = wp_height - lineView.lineHeight + lineView.offsetY
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
    
    
    /// 选中 下划线滚动
    func selected(_ index:Int){

        // 如果已经被加载到视图时候
        if let view = data.wp.get(index)?.navigationItem.superview{
            lineView.wp_width = lineView.lineWidth.width(with: data.wp.get(index)?.navigationItem)
            lineView.wp_centerX = view.wp_centerX

            // 导航条item滚动到当前
            if selectedStyle != .none {
                collectionView.scrollToItem(at: .init(row: index, section: 0), at: navSelectedStyle, animated: true)
            } else {
                collectionView.scrollToItem(at: .init(row: index, section: 0), at: navSelectedStyle, animated: false)
            }
        }else{
            // 标记 等有视图时候滚动一次
            scrollTo = true
            scrollNormalIndex = index
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
        
        if scrollTo{
            if let index = scrollNormalIndex{
                scrollTo = false
                selected(index)
            }
        }
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
                wp.removeAllSubView()
                addSubview(item.navigationItem)
                item.navigationItem.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        }
    }
}
