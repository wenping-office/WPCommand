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
//        let normalTitle
    }
}

/// 菜单视图
public class WPMenuView: WPBaseView {
    
    /// 当前导航视图
    private let navView : WPMenuNavigationView = WPMenuNavigationView()
    
    public init(navigationHeight:CGFloat) {
        super.init(frame: .zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class WPMenuNavigationView: WPBaseView {
    let contentView = WPCollectionAutoLayoutView(cellClass: WPMenuNavigationViewCell.self)
    
    
}


/// 菜单视图
class WPMenuNavigationViewCell: UICollectionViewCell{
    /// 标题
    var title : String?
}
