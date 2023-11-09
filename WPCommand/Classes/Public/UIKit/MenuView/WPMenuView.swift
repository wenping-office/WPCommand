//
//  WPMenuView.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/5.
//

import UIKit

public extension WPMenuView{
    
    final class LineView:WPBaseView{
        /// 线条宽度
        public var lineWidth : LineWidth = .equalText()
        /// 线条高度
        public var lineHeight : CGFloat = 2
        /// Y轴偏移
        public var offsetY : CGFloat = 0
    }
}

public extension WPMenuView{
    /// 滚动选项
    enum ScrollOption {
        /// 选中导航
        case navigation(animated:Bool = true,position:UITableView.ScrollPosition = .top)
        /// 选中头部视图
        case header(animated:Bool = true,position:UITableView.ScrollPosition = .top)
    }
    
    /// 下滑线宽
    enum LineWidth {
        /// 最大宽度
        case max(width:CGFloat)
        /// 等于默认文本宽度
        case equalText(edge:ContentEdge = .zero)
        /// 等于导航栏item宽度
        case equalView(edge:ContentEdge = .zero)
        /// 获取宽度
        func width(with item:WPMenuNavigationViewProtocol?) -> CGFloat {
            var maxWidth : CGFloat = 0
            switch self {
            case .max(let width):
                maxWidth = width
            case .equalText(let edge):
                if let view = item as? DefaultNavigationItem{
                    maxWidth = view.menuItemWidth() - edge.left - edge.right
                }else{
                    maxWidth = 20
                }
            case .equalView(let edge):
                maxWidth = (item?.menuItemWidth() ?? 0) - edge.left - edge.right
            }
            return maxWidth
        }
        /// 是否需要布局
        var isLayout : Bool{
            switch self {
            case .max:
                return false
            case .equalText:
                return true
            case .equalView:
                return true
            }
        }
    }

    /// 左右内容边距
    struct ContentEdge{
        /// 左边内容内边距
        public let left : CGFloat
        /// 右边内容内编剧
        public let right : CGFloat
        
        ///  边距
        /// - Parameters:
        ///   - left: 左边距
        ///   - right : 右边距
        public init(left:CGFloat,
                    right:CGFloat){
            self.left = left
            self.right = right
        }
        
        public static var zero : ContentEdge{
            return .init(left: 0, right: 0)
        }
    }
    
    /// 身体视图是否执行选中动画
    var selectedAnimation: Bool {
        set {
            contentView.bodyView.selectedAnimation = newValue
        }
        get {
            return contentView.bodyView.selectedAnimation
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
    /// 导航栏左边视图 使用frame布局 填frame.size 有效
    var navigationLeftView:UIView?{
        set{
            contentView.navView.leftView = newValue
        }
        get{
            return contentView.navView.leftView
        }
    }
    /// 导航栏右边视图 使用frame布局 填frame.size 有效
    var navigationRightView:UIView?{
        set{
            contentView.navView.rightView = newValue
        }
        get{
            return contentView.navView.rightView
        }
    }
    /// 导航栏视图是否可拖动
    var navigationViewIsScrollEnabled:Bool{
        set{
            contentView.navView.collectionView.isScrollEnabled = newValue
        }
        get{
            return contentView.navView.collectionView.isScrollEnabled
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
    /// 导航栏选中样式
    var navigationSelectedStyle: WPMenuView.NavigationSelectedStyle{
        set{
            contentView.navView.selectedStyle = newValue
        }
        get{
            return contentView.navView.selectedStyle
        }
    }
    /// 下滑线
    var lineView : LineView{
        return contentView.navView.lineView
    }
    /// 可以用来设置上下拉刷新 不可单独设置代理
    var tableView:UITableView{
        return contentView
    }
    /// 多手势识别 默认false
    var multiGesture : Bool{
        set{
            contentView.multiGesture = newValue
        }
        get{
            return contentView.multiGesture
        }
    }
    /// 主视图滚动时禁用身体视图滚动 当multiGesture == true 时生效
    var mainDidScrollCloseBodyScroll : Bool{
        set{
            contentView.mainDidScrollCloseBodyScroll = newValue
        }
        get{
            return contentView.mainDidScrollCloseBodyScroll
        }
    }
    /// 水平手势适配 默认false
    var horizontalGestureAdaptation : Bool{
        set{
            contentView.bodyView.collectionView.horizontalAdaptation = newValue
        }
        get{
            return contentView.bodyView.collectionView.horizontalAdaptation
        }
    }
    /// 身体视图
    var bodyView:WPMenuBodyView{
        return contentView.bodyView
    }
    
    /// 滚动到目标视图
    /// - Parameters:
    ///   - option: 选择
    ///   - complete: 回调
    func scroll(to option:ScrollOption,complete:(()->Void)?=nil){
        contentView.isUserInteractionEnabled = false
        if contentView.delegate is WPMenuContentTableView {
            switch option {
            case .navigation(let animated, let position):
                contentView.selectRow(at: IndexPath.init(row: 0, section: 1), animated: animated, scrollPosition: position)
            case .header(let animated, let position):
                contentView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: animated, scrollPosition: position)
            }
        }
        WPGCD.main_asyncAfter(.now() + 0.2, task: {[weak self] in
            self?.contentView.isUserInteractionEnabled = true
        })
    }
    
    /// 刷新headerview
    /// - Parameter animate:
    func refreshHeader(_ animate:UITableView.RowAnimation = .none) {
        contentView.reloadRows(at: [.init(row: 0, section: 0)], with: animate)
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
    
    /// 横向滚动百分比
    func didHorizontalRolling(with percentage:Double)
}

public extension WPMenuViewChildViewProtocol {
    /// 子视图状态更新
    func menuViewChildViewUpdateStatus(menuView: WPMenuView, status: WPMenuView.MenuViewStatus) {}
    /// 横向滚动百分比
    func didHorizontalRolling(with percentage:Double){}
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
            bodyItem.bodyView?.targetViewDidScroll = {[weak self] scrollView in
                self?.didScoll(did: bodyItem)
            }
            let navItem = WPMenuNavigationItem(size: .init(width: navigationitems[index].menuItemWidth(), height: navigationHeight), index: index, item: navigationitems[index])
            bodyItems.append(bodyItem)
            navItems.append(navItem)
            headItems.append(haederItem)
        }
        contentView.headerView.data = headItems
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
    /// 自动识别bodyView是否为scrollView 自动开启多手势识别 默认true
    public var autoAdaptationScroll = true
    /// 当前选中的索引
    public private(set) var currentIndex:Int?
    /// 数据源
    public weak var dataSource: WPMenuViewDataSource?
    /// 代理
    public weak var delegate: WPMenuViewDelegate?
    /// 导航栏item内边距
    public var navigationInset: NavigationInset = .init(left: 0, right: 0, spacing: 0) {
        didSet {
            contentView.navView.layout.minimumLineSpacing = navigationInset.spacing
            contentView.navView.layout.minimumInteritemSpacing = navigationInset.spacing
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
        contentView.estimatedRowHeight = 44
        contentView.estimatedSectionHeaderHeight = 0
        contentView.estimatedSectionFooterHeight = 0
        contentView.showsHorizontalScrollIndicator = false
        contentView.showsVerticalScrollIndicator = false
        if #available(iOS 15.0, *) {
            contentView.sectionHeaderTopPadding = 0
        }
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override public func observeSubViewEvent() {
        
        contentView.didScroll = {[weak self] view in
            self?.contentViewDidScroll(view)
        }

        contentView.bodyView.contentOffSet = {[weak self] x in
            /// 偏移量
            var offset : Double = 0
            let defaultIndex = Int((x + 0.5))
            /// 需要增量的索引
            let intX = Int(x)
            offset = x - Double(intX)
            if intX < defaultIndex {
                self?.setChildView(offset: 0, with: defaultIndex + 1)
                self?.setChildView(offset: 1 - offset, with: defaultIndex - 1)
                self?.setChildView(offset: offset, with: defaultIndex)
            }else if x > CGFloat(defaultIndex){
                self?.setChildView(offset: 0, with: defaultIndex - 1)
                self?.setChildView(offset: offset, with: defaultIndex + 1)
                self?.setChildView(offset: 1 - offset, with: defaultIndex)
            }

            guard
                let self = self
            else { return }
            
            let bodyItem = self.bodyView.data.wp_get(of: defaultIndex)
            if self.autoAdaptationScroll {
                self.contentView.multiGesture = bodyItem?.bodyView?.menuBodyViewAdaptationScrollView() != nil
            }

            /// 当前导航item
            var currentX: CGFloat = 0.0
            /// 目标导航item
            var targetX : CGFloat = 0.0
            var spacing = 0.0
            var defaultX : CGFloat = 0
            let lineView = self.contentView.navView.lineView
            let targetIndex = intX
            var scrollOffSet : CGFloat = Double(x.wp.decimal()) ?? 0
            // 线条宽度
            var currentLineWidth : CGFloat = 0
            var targetLineWidth : CGFloat = 0
            var lineSpacing = 0.0
            var defalutWidth = 0.0
            
            if intX < defaultIndex {
                scrollOffSet = 1 - offset

                if self.contentView.navView.lineView.lineWidth.isLayout{
                    currentLineWidth = self.contentView.navView.lineView.lineWidth.width(with: self.contentView.navView.data.wp_get(of: defaultIndex)?.navigationItem)
                    targetLineWidth = self.contentView.navView.lineView.lineWidth.width(with: self.contentView.navView.data.wp_get(of: targetIndex)?.navigationItem)
                    lineSpacing = (currentLineWidth - targetLineWidth) / 100
                    defalutWidth = currentLineWidth
                    lineView.wp_width = defalutWidth - scrollOffSet * lineSpacing * 100
                }
                
                currentX = self.contentView.navView.data.wp_get(of: defaultIndex)?.navigationItem.superview?.wp_centerX ?? 0
                targetX = self.contentView.navView.data.wp_get(of: targetIndex)?.navigationItem.superview?.wp_centerX ?? 0
                spacing = (currentX - targetX) / 100
                defaultX = currentX
                lineView.wp_centerX = defaultX - scrollOffSet * spacing * 100

            }else if x > CGFloat(defaultIndex){

                scrollOffSet = offset

                if self.contentView.navView.lineView.lineWidth.isLayout{
                    currentLineWidth = self.contentView.navView.lineView.lineWidth.width(with: self.contentView.navView.data.wp_get(of: targetIndex + 1)?.navigationItem)
                    targetLineWidth = self.contentView.navView.lineView.lineWidth.width(with: self.contentView.navView.data.wp_get(of: defaultIndex)?.navigationItem)
                    lineSpacing = (currentLineWidth - targetLineWidth) / 100
                    defalutWidth = targetLineWidth
                    lineView.wp_width = defalutWidth + scrollOffSet * lineSpacing * 100
                }
                
                currentX = self.contentView.navView.data.wp_get(of: targetIndex + 1)?.navigationItem.superview?.wp_centerX ?? 0
                targetX = self.contentView.navView.data.wp_get(of: defaultIndex)?.navigationItem.superview?.wp_centerX ?? 0
                spacing = (currentX - targetX) / 100
                defaultX = targetX
                lineView.wp_centerX = defaultX + scrollOffSet * spacing * 100
                
            }
        }
        
        contentView.bodyView.didSelected = { [weak self] index in
            self?.currentIndex = index
            // 代理回掉
            self?.delegate?.menuViewDidSelected(index: index)
            // 设置翻页
            self?.selectedPage(index: index)
            // 设置header头
            let headerItem = self?.contentView.headerView.data.wp_get(of: index)
            
            guard let self = self else { return }
            
            self.contentView.navView.selected(index)
            
            // 选中headr
            self.contentView.headerView.setHeaderView(of: headerItem?.headerView, complete: { [weak self] _ in
                self?.refreshHeader()
            })
        }
        
        contentView.navView.didSelected = { [weak self] index in
            /// 是否执行选中动画
            let isAnimation = self?.bodyView.selectedAnimation ?? false
            
            if !isAnimation {
                if let index = self?.currentIndex {
                    self?.setChildView(offset: 0, with: index)
                }
                self?.setChildView(offset: 1, with: index)
            }
            
            self?.currentIndex = index
            self?.contentView.bodyView.selected(index)
            self?.contentView.bodyView.didSelected?(index)
            
            self?.contentView.navView.selected(index)
        }
    }
    
    // contentView滚动
    private func contentViewDidScroll(_ scrollView:UIScrollView){
        
        delegate?.menuViewDidVerticalScroll(scrollView.contentOffset)

        let offsetY = contentView.rectForRow(at: IndexPath.init(row: 0, section: 1)).origin.y - navigationHeight

        if scrollView.contentOffset.y > contentView.lastOffsetY {
            if scrollView.contentOffset.y >= offsetY {
                scrollView.contentOffset = .init(x: 0, y: offsetY)
            }
        }

        if scrollView.contentOffset.y < contentView.lastOffsetY {
            if let index = currentIndex {
                let item = contentView.bodyView.data.wp_get(of: index)
                let subCurrentY = item?.bodyView?.menuBodyViewAdaptationScrollView()?.contentOffset.y ?? 0
                if subCurrentY > 0 {
                    scrollView.contentOffset = .init(x: 0, y: contentView.lastOffsetY)
                }else{
                    if scrollView.contentOffset.y <= 0 {
                        scrollView.contentOffset = .zero
                    }
                }
            }
        }
        contentView.lastOffsetY = scrollView.contentOffset.y
    }
    
    /// 子视图正在滚动
    private func didScoll(did item:WPMenuBodyViewItem){
        
        if contentView.contentOffset.y == 0 { return }
        
        let offsetY = contentView.rectForRow(at: IndexPath.init(row: 0, section: 1)).origin.y - navigationHeight
        
        let subCurrentY = item.bodyView?.menuBodyViewAdaptationScrollView()?.contentOffset.y ?? 0
        let subLastY = item.lastOffset.y

        if offsetY > item.lastOffset.y {
            if contentView.contentOffset.y < offsetY && subLastY >= 0{
                item.bodyView?.menuBodyViewAdaptationScrollView()?.contentOffset = .init(x: 0, y: item.lastOffset.y)
            }
        }

        if subCurrentY < subLastY  {
            if subCurrentY <= 0 && contentView.contentOffset.y > 0 {
                item.bodyView?.menuBodyViewAdaptationScrollView()?.contentOffset = .zero
            }
        }
        
        item.lastOffset = item.bodyView?.menuBodyViewAdaptationScrollView()?.contentOffset ?? .zero
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
        
        contentView.headerView.data.forEach { item in
            if item.isSelected {
                item.headerView?.menuViewChildViewUpdateStatus(menuView: self, status: .normal)
            }
            item.isSelected = false
        }
        let headItem = contentView.headerView.data.wp_get(of: index)
        headItem?.isSelected = true
        headItem?.headerView?.menuViewChildViewUpdateStatus(menuView: self, status: .selected)
    }
    
    /// 设置子视图偏移量
    private func setChildView(offset:Double,with index:Int){
        
        contentView.headerView.data.wp_get(of: index)?.headerView?.didHorizontalRolling(with: offset)
        contentView.navView.data.wp_get(of: index)?.navigationItem.didHorizontalRolling(with: offset)
        contentView.bodyView.data.wp_get(of: index)?.bodyView?.didHorizontalRolling(with: offset)
    }
}

public extension WPMenuView {
    /// 选中一个item
    func selected(_ index: Int) {
        contentView.navView.didSelected?(index)
        setChildView(offset: 1, with: index)
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
    /// 主视图滚动时禁用身体视图滚动 当multiGesture == true 时生效
    var mainDidScrollCloseBodyScroll = true
    /// 上次滚动的Y
    var lastOffsetY : CGFloat = 0
    
    var didScroll : ((UIScrollView)->Void)?

    init(navigationHeight: CGFloat, style: UITableView.Style) {
        self.navigationHeight = navigationHeight
        super.init(frame: .zero, style: style)
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        }
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
        
        if multiGesture{
            if mainDidScrollCloseBodyScroll{
                if otherGestureRecognizer == bodyView.collectionView.panGestureRecognizer{
                    return false
                }
            }
        }
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll?(scrollView)
    }
}
