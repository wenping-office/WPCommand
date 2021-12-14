//
//  WPMenuView.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/5.
//

import UIKit

public extension WPMenuView{
    /// 身体视图是否执行选中动画
    var bodyViewSelecteAnimate: Bool {
        set {
            contentView.bodyView.selectedAnimate = newValue
        }
        get {
            return contentView.bodyView.selectedAnimate
        }
    }
    /// 头部视图
    var headerView: UIView? {
        set {
            tableView.tableHeaderView = newValue
        }
        get {
            return tableView.tableFooterView
        }
    }
    /// 尾巴部视图
    var footerView: UIView? {
        set {
            tableView.tableFooterView = newValue
        }
        get {
            return tableView.tableFooterView
        }
    }
    /// 导航栏背景视图
    var navigationBackgroundView: UIView{
        get {
            return contentView.navView.backView
        }
    }
    /// 是否显示水平底部滑动条
    var showsHorizontalScrollIndicator: Bool{
        set{
            contentView.bodyView.collectionView.showsHorizontalScrollIndicator = newValue
        }
        get{
            return contentView.bodyView.collectionView.showsHorizontalScrollIndicator
        }
    }
    /// 是否显示垂直滑动条
    var showsVerticalScrollIndicator: Bool{
        set{
            contentView.showsVerticalScrollIndicator = newValue
        }
        get{
            return contentView.showsVerticalScrollIndicator
        }
    }
    /// 可以用来设置上下拉刷新 不可单独设置代理
    var tableView:UITableView{
        return contentView
    }
    
    /// 多手势识别
    var multiGesture : Bool{
        set{
            contentView.multiGesture = newValue
        }
        get{
            return contentView.multiGesture
        }
    }
    
    /// 身体视图
    var bodyView:WPMenuBodyView{
        return contentView.bodyView
    }
    
    /// 滚动到导航栏
    func scrollToNavigation(animated:Bool = true,
                                   position:UITableView.ScrollPosition = .top){
        if contentView.delegate is WPMenuContentTableView {
            contentView.selectRow(at: IndexPath.init(row: 0, section: 1), animated: animated, scrollPosition: position)
        }
    }
    
    /// 滚动到顶部
    func scrollToHeader(animated:Bool = true,
                               position:UITableView.ScrollPosition = .top){
        if contentView.delegate is WPMenuContentTableView {
        contentView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: animated, scrollPosition: position)
        }
    }
}

public extension WPMenuView {
    enum HeaderHeightOption {
        /// 使用autolayout自动布局高度
        case autoLayout
        /// 硬性条件高度
        case height(_ height: CGFloat)
    }
    
    enum MenuViewStatus {
        /// 默认状态
        case normal
        /// 选中状态
        case selected
    }
    
    enum NavigationSelectedStyle {
        /// 无选中动画
        case none
        /// 靠左选中
        case left
        /// 靠右选中
        case right
        /// 居中选中
        case center
    }
    
    /// 导航栏item内边距
    struct NavigationInset {
        var left: CGFloat = 0
        var right: CGFloat = 0
        var spacing: CGFloat = 0
        public init(left: CGFloat,
                    right: CGFloat,
                    spacing: CGFloat)
        {
            self.left = left
            self.right = right
            self.spacing = spacing
        }
    }
}

public protocol WPMenuViewChildViewProtocol: NSObjectProtocol {
    /// 子视图状态更新
    func menuViewChildViewUpdateStatus(menuView: WPMenuView, status: WPMenuView.MenuViewStatus)
}

public extension WPMenuViewChildViewProtocol {
    /// 子视图状态更新
    func menuViewChildViewUpdateStatus(menuView: WPMenuView, status: WPMenuView.MenuViewStatus) {}
}

extension WPMenuView {
    class Item {
        /// 当前item索引
        let index: Int
        /// 是否被选中
        var isSelected = false
        
        init(index: Int) {
            self.index = index
        }
    }
}

/// 菜单视图，table滚动样式
public extension WPMenuView {
    /// 添加一组item
    /// - Parameter items: items
    func setNavigation(_ navigationitems: [WPMenuNavigationViewProtocol]) {
        var headItems: [WPMenuHeaderViewItem] = []
        var navItems: [WPMenuNavigationItem] = []
        var bodyItems: [WPMenuBodyViewItem] = []
        
        for index in 0 ..< navigationitems.count {
            let haederItem = WPMenuHeaderViewItem(index: index, headerView: self.dataSource?.menuHeaderViewForIndex(index: index))
            let bodyItem = WPMenuBodyViewItem(index: index, bodyView: self.dataSource?.menuBodyViewForIndex(index: index))
            let navItem = WPMenuNavigationItem(size: .init(width: navigationitems[index].menuItemWidth(), height: navigationHeight), index: index, item: navigationitems[index])
            bodyItems.append(bodyItem)
            navItems.append(navItem)
            headItems.append(haederItem)
        }
        contentView.headerView.datas = headItems
        contentView.navView.data = navItems
        contentView.navView.registerCell()
        contentView.bodyView.data = bodyItems
        contentView.bodyView.registerCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bodyHeight = wp.height - navigationHeight
        if bodyHeight > 0 {
            contentView.bodyView.setCollectionSize(.init(width: wp.width, height: bodyHeight))
            contentView.reloadData()
        }
    }
}

/// 菜单视图
public class WPMenuView: WPBaseView {
    /// 导航条高度
    private let navigationHeight: CGFloat
    /// 内容视图
    private let contentView: WPMenuContentTableView
    /// 导航栏选中样式
    public var navigationSelectedStyle: NavigationSelectedStyle = .center
    /// 导航栏选中动画样式
    private var navSelectedStyle: UICollectionView.ScrollPosition {
        switch navigationSelectedStyle {
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

    /// 数据源
    public weak var dataSource: WPMenuViewDataSource?
    /// 代理
    public weak var delegate: WPMenuViewDelegate?
    /// 导航栏item内边距
    public var navigationInset: NavigationInset = .init(left: 0, right: 0, spacing: 0) {
        didSet {
            contentView.navView.layout.minimumLineSpacing = navigationInset.spacing
            contentView.navView.collectionView.contentInset = .init(top: 0,
                                                                    left: navigationInset.left,
                                                                    bottom: 0,
                                                                    right: navigationInset.right)
        }
    }
    
    public init(navigationHeight: CGFloat) {
        self.navigationHeight = navigationHeight
        contentView = .init(navigationHeight: navigationHeight, style: .plain)
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func initSubView() {
        contentView.estimatedRowHeight = 0.0
        contentView.estimatedSectionHeaderHeight = 0
        contentView.estimatedSectionFooterHeight = 0
        contentView.showsHorizontalScrollIndicator = false
        contentView.showsVerticalScrollIndicator = false
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override public func observeSubViewEvent() {
        contentView.bodyView.contentOffSet = { _ in
        }
        
        contentView.bodyView.didSelected = { [weak self] index in
            // 代理回掉
            self?.delegate?.menuViewDidSelected(index: index)
            // 设置翻页
            self?.selectedPage(index: index)
            // 设置header头
            let headerItem = self?.contentView.headerView.datas.wp_get(of: index)
            
            guard let self = self else { return }

            // 导航条item滚动到当前
            if self.navigationSelectedStyle != .none {
                self.contentView.navView.collectionView.scrollToItem(at: .init(row: index, section: 0), at: self.navSelectedStyle, animated: true)
            } else {
                self.contentView.navView.collectionView.scrollToItem(at: .init(row: index, section: 0), at: self.navSelectedStyle, animated: false)
            }
            
            // 选中headr
            self.contentView.headerView.setHeaderView(of: headerItem?.headerView, complete: { [weak self] _ in
                self?.contentView.reloadData()
            })
        }
        
        contentView.navView.didSelected = { [weak self] index in
            self?.contentView.bodyView.selected(index)
            self?.contentView.bodyView.didSelected?(index)
        }
    }
    
    /// 选中一页内部使用
    /// - Parameter index:
    private func selectedPage(index: Int) {
        contentView.navView.data.forEach { item in
            if item.isSelected {
                item.navigationItem.menuViewChildViewUpdateStatus(menuView: self, status: .normal)
            }
            item.isSelected = false
        }
        let navItem = contentView.navView.data.wp_get(of: index)
        navItem?.isSelected = true
        navItem?.navigationItem.menuViewChildViewUpdateStatus(menuView: self, status: .selected)
        
        contentView.bodyView.data.forEach { item in
            if item.isSelected {
                item.bodyView?.menuViewChildViewUpdateStatus(menuView: self, status: .normal)
            }
            item.isSelected = false
        }
        let bodyItem = contentView.bodyView.data.wp_get(of: index)
        bodyItem?.isSelected = true
        bodyItem?.bodyView?.menuViewChildViewUpdateStatus(menuView: self, status: .selected)
        
        contentView.headerView.datas.forEach { item in
            if item.isSelected {
                item.headerView?.menuViewChildViewUpdateStatus(menuView: self, status: .normal)
            }
            item.isSelected = false
        }
        let headItem = contentView.headerView.datas.wp_get(of: index)
        headItem?.isSelected = true
        headItem?.headerView?.menuViewChildViewUpdateStatus(menuView: self, status: .selected)
    }
}

public extension WPMenuView {
    /// 选中一个item
    func selected(_ index: Int) {
        contentView.navView.didSelected?(index)
    }
}

class WPMenuContentTableView: UITableView,UIGestureRecognizerDelegate {
    /// 导航条高度
    let navigationHeight: CGFloat
    /// 头部视图
    let headerView = WPMenuHeaderView()
    /// 菜单视图
    let bodyView = WPMenuBodyView()
    /// 当前导航视图
    let navView = WPMenuNavigationView()
    /// 多手势识别
    var multiGesture : Bool = false
    
    init(navigationHeight: CGFloat, style: UITableView.Style) {
        self.navigationHeight = navigationHeight
        super.init(frame: .zero, style: style)
        backgroundColor = .clear
        delegate = self
        dataSource = self
        separatorStyle = .none
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return multiGesture
    }
}

extension WPMenuContentTableView: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return headerView
        case 1:
            return bodyView
        default:
            return UITableViewCell(frame: .zero)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section <= 0 ? 0 : navigationHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section <= 0 ? nil : navView
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let bodyHeight = wp.height - navigationHeight
        
        if indexPath.section <= 0 {
            switch headerView.headerHeight {
            case .autoLayout:
                return UITableView.automaticDimension
            case .height(let height):
                return height
            }
        } else if indexPath.section == 1 {
            return bodyHeight <= 0 ? 0 : bodyHeight
        } else {
            return 0
        }
    }
}


