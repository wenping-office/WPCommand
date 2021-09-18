//
//  WPMenuView.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/5.
//

import UIKit

public extension WPMenuView{
    enum NavigationStatus {
        /// 默认状态
        case normal
        /// 选中状态
        case selected
    }
}

public extension WPMenuView{
    
    /// 添加一组item
    /// - Parameter items: items
    func setItems(items:[WPMenuViewNavigationProtocol]){
        
        var navItems : [WPMenuNavigationItem] = []
        var bodyItems : [WPMenuBodyViewItem] = []
        
        for index in 0..<items.count {
            let bodyItem = WPMenuBodyViewItem(index: index, view: self.dataSource?.menuBodyViewForIndex(index: index))
            let navItem = WPMenuNavigationItem(size: .init(width: items[index].menuItemWidth(), height: navigationHeight), index: index, item: items[index])
            bodyItems.append(bodyItem)
            navItems.append(navItem)
        }
        navView.data = navItems
        navView.registerCell()
        bodyView.data = bodyItems
        bodyView.registerCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let bodyHeight = wp_height - navigationHeight
        if bodyHeight > 0 {
            bodyView.setCollectionSize(.init(width: wp_width, height: bodyHeight))
            contentView.reloadData()
        }
    }
}

/// 菜单视图
public class WPMenuView: WPBaseView {
    /// 导航条高度
    private let navigationHeight : CGFloat
    /// 当前导航视图
    private let navView : WPMenuNavigationView = WPMenuNavigationView()
    /// 内容视图
    private let contentView = UITableView(frame: .zero)
    /// 头部视图
    private let headerView = UITableViewCell()
    /// 菜单视图
    private let bodyView = WPMenuBodyView()
    /// 数据源
    public weak var dataSource : WPMenuViewDataSource?
    /// 代理
    public weak var delegate : WPMenuViewDelegate?
    
    public init(navigationHeight:CGFloat) {
        self.navigationHeight = navigationHeight
        super.init(frame: .zero)
        contentView.register(WPMenuNavigationView.self, forHeaderFooterViewReuseIdentifier: "WPMenuNavigationView")
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func initSubView() {
        contentView.delegate = self
        contentView.dataSource = self
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public override func observeSubViewEvent() {
        
        bodyView.contentOffSet = { offset in
            print(offset)
        }
        bodyView.selectedIndexBlock = {[weak self] index in

            self?.navView.data.forEach { item in
                item.navigationItem.upledeStatus(status: .normal)
            }
            self?.navView.data[index].navigationItem.upledeStatus(status: .selected)
        }
    }
}

extension WPMenuView:UITableViewDelegate,UITableViewDataSource{
    
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

        return section <= 0 ? nil : tableView.dequeueReusableHeaderFooterView(withIdentifier: "WPMenuNavigationView")
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let bodyHeight = wp_height - navigationHeight
        return indexPath.section <= 0 ? 0 : bodyHeight
    }
}


extension WPMenuView{
    
    /// 选中一个item
    private func didSelected(_ index:Int){
        delegate?.menuViewDidSelected(index: index)
        
        let navItem = navView.data[index]

        navView.data.forEach { elmt in
            if elmt.isSelected{
                elmt.navigationItem.upledeStatus(status: .normal)
            }
            elmt.isSelected = false
        }

        navItem.isSelected = true
        navItem.navigationItem.upledeStatus(status: .selected)
    }
}












