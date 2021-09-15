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
//        let navGroup = navView.group
//        navGroup.items.removeAll()
//        items.forEach { elmt in
//            elmt.upledeStatus(status: .normal)
//            let item = WPCollectionItem()
//            item.itemSize = .init(width: 100, height: navigationHeight)
//            item.info = elmt
//            navGroup.items.append(item)
//        }
//        navView.contentView.reloadData()
//
//        var index = 0
//        let bodyGroup =  bodyView.group
//        bodyGroup.items.removeAll()
//        items.forEach { elmt in
//            let item = WPCollectionItem()
//            item.customIdentifier = index.description
//            item.willDisplay = {[weak self] item,cell in
//                let bodyCell = cell as? WPMenuChildContentCell
//                bodyCell?.setBodyView(self?.dataSource?.viewForIndex(index: item.indexPath.row))
//            }
//            item.info = elmt
//            bodyGroup.items.append(item)
//            index+=1
//        }
        
//        bodyView.contentCollectionView.reloadData()
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
        navView.backgroundColor = .wp_random
        return section <= 0 ? nil : navView
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let bodyHeight = wp_height - navigationHeight


        return indexPath.section <= 0 ? 0 : bodyHeight
    }
}


extension WPMenuView{
    
    /// 选中一个item
    private func didSelected(item:WPCollectionItem){
//        navView.contentView.groups.forEach { group in
//            group.items.forEach { item in
//                item.status = .normal
//                item.update()
//            }
//        }
//        item.status = .selected
//        item.update()
//
//        let menuItem = item.info as? WPMenuViewNavigationProtocol
//
//        menuItem?.upledeStatus(status: item.status == .normal ? .normal : .selected)
    }
}












