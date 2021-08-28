//
//  WPMenuView.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/5.
//

import UIKit

public protocol WPMenuViewDelegate {
    /// 即将选中一个菜单的索引
    func didSelected(at index:Int)
}

public extension WPMenuViewDelegate{
    func didSelected(at index:Int){}
}

extension WPMenuView{
    struct MenuItem {
        let title:String?
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
    private let headerView = WPMenuChildView()
    /// 菜单视图
    private let bodyView = WPMenuChildView()
    
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
    
    public override var frame: CGRect{
        didSet{
            contentView.reloadData()
        }
    }
}

extension WPMenuView:UITableViewDelegate,UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0:
            return headerView
        case 1:
            return bodyView
        default:
           return UITableViewCell(frame: .zero)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return navigationHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return navView
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return wp_height - navigationHeight
    }
}












class WPMenuNavigationView: WPBaseView {
    let contentView = WPCollectionAutoLayoutView(cellClass: WPMenuNavigationViewCell.self)
    override func initSubView() {
        backgroundColor = .wp_random
    }
}

/// 菜单视图
class WPMenuNavigationViewCell: UICollectionViewCell{
    /// 标题
    var title : String?
}

/// 菜单视图
class WPMenuChildView: UITableViewCell{
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        contentView.backgroundColor = .wp_random
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
