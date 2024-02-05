//
//  UITableViewDelegate+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/18.
//

import UIKit

private var WPTableViewDelegatePointer = "WPTableViewDelegatePointer"

extension UITableView {
    var wp_delegate: WPTableViewDelegate {
        set {
            WPRunTime.set(self, newValue, withUnsafePointer(to: &WPTableViewDelegatePointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = newValue
        }
        get {
            guard let wp_delegate: WPTableViewDelegate = WPRunTime.get(self, withUnsafePointer(to: &WPTableViewDelegatePointer, {$0})) else {
                let wp_delegate = WPTableViewDelegate()
                self.wp_delegate = wp_delegate
                return wp_delegate
            }
            return wp_delegate
        }
    }
}

public extension WPSpace where Base: UITableView {
    /// 桥接代理
    var delegate: WPTableViewDelegate {
        return base.wp_delegate
    }
}

public class WPTableViewDelegate: WPScrollViewDelegate {
    /// 选中一行掉用
   public var didSelectRowAt: ((UITableView, IndexPath) -> Void)?
    /// 每一行的高度
    public var heightForRowAt: ((UITableView, IndexPath) -> CGFloat)?
    /// 编辑按钮的点击时间
    public var commitEditingStyle: ((UITableView, IndexPath) -> Void)?
    /// 这一组header高度
    public var heightForHeaderInSection: ((UITableView, Int) -> CGFloat)?
    /// 这一组footer高度
    public var heightForFooterInSection: ((UITableView, Int) -> CGFloat)?
    /// 这一组的headerView
    public var viewForHeaderInSection: ((UITableView, Int) -> UIView?)?
    /// 这一组的footerView
    public  var viewForFooterInSection: ((UITableView, Int) -> UIView?)?
    /// cell即将显示
    public  var willDisplayCell: ((UITableView, UITableViewCell, IndexPath) -> Void)?
    /// 这一组headerView即将显示
    public var willDisplayHeaderView: ((UITableView, UIView, Int) -> Void)?
    /// 这一组foogerView即将显示
    public var willDisplayFooterView: ((UITableView, UIView, Int) -> Void)?
}

extension WPTableViewDelegate: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = tableView.wp_source.groups.wp_get(of: indexPath.section)?.items.wp_get(of: indexPath.row)
        
        if heightForRowAt != nil {
            return heightForRowAt!(tableView, indexPath)
        } else if item != nil {
            return item!.cellHeight
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let group = tableView.wp_source.groups.wp_get(of: indexPath.section)
        
        if let item = group?.items.wp_get(of: indexPath.row) {
            item.didCommitEditBlock?(item, group!)
        }
        
        commitEditingStyle?(tableView, indexPath)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let group = tableView.wp_source.groups.wp_get(of: section)
        
        if heightForHeaderInSection != nil {
            return heightForHeaderInSection!(tableView, section)
        } else if group != nil {
            return group!.headerHeight
        } else {
            return 0.01
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let group = tableView.wp_source.groups.wp_get(of: section)
        if heightForFooterInSection != nil {
            return heightForFooterInSection!(tableView, section)
        } else if group != nil {
            return group!.footerHeight
        } else {
            return 0.01
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if viewForHeaderInSection != nil {
            return viewForHeaderInSection!(tableView, section)
        } else if let group = tableView.wp_source.groups.wp_get(of: section) {
            var headView: UITableViewHeaderFooterView?
            
            if let idStr = group.headViewReuseIdentifier {
                headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: idStr)
                if headView == nil {
                    tableView.register(group.headViewClass, forHeaderFooterViewReuseIdentifier: idStr)
                    headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: idStr)
                }
                headView?.group = group
                headView?.reloadGroup(group: group)
            }
            return headView
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if viewForFooterInSection != nil {
            return viewForFooterInSection!(tableView, section)
        } else if let group = tableView.wp_source.groups.wp_get(of: section) {
            var foodView: UITableViewHeaderFooterView?
            
            if let idStr = group.footViewReuseIdentifier {
                foodView = tableView.dequeueReusableHeaderFooterView(withIdentifier: idStr)
                if foodView == nil {
                    tableView.register(group.footViewClass, forHeaderFooterViewReuseIdentifier: idStr)
                    foodView = tableView.dequeueReusableHeaderFooterView(withIdentifier: idStr)
                }
                foodView?.group = group
                foodView?.reloadGroup(group: group)
            }
            return foodView
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAt?(tableView, indexPath)
        if let item = tableView.wp_source.groups.wp_get(of: indexPath.section)?.items.wp_get(of: indexPath.row) {
            let cell = tableView.cellForRow(at: indexPath)
            item.didSelectedBlock?(cell!)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        willDisplayCell?(tableView, cell, indexPath)
        
        if let item = tableView.wp_source.groups.wp_get(of: indexPath.section)?.items.wp_get(of: indexPath.row) {
            cell.separatorInset = item.separatorInset
            item.willDisplay?(cell)
            cell.didSetItemInfo(info: item.info)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        willDisplayHeaderView?(tableView, view, section)
        
        if let group = tableView.wp_source.groups.wp_get(of: section) {
            let headerView = view as! UITableViewHeaderFooterView
            headerView.reloadGroup(group: group)
            group.headWillDisplayBlock?(headerView)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        willDisplayFooterView?(tableView, view, section)
        
        if let group = tableView.wp_source.groups.wp_get(of: section) {
            let footerView = view as! UITableViewHeaderFooterView
            footerView.reloadGroup(group: group)
            group.headWillDisplayBlock?(footerView)
        }
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let dataSource = tableView.wp.dataSource
        let group = dataSource.groups.wp_get(of: indexPath.section)
        let item = group?.items.wp_get(of: indexPath.row)
        
        if item?.swipeActionsConfiguration != nil {
            return item?.swipeActionsConfiguration
        }

        if item?.didCommitEditBlock != nil{
            return .init(actions: [.init(style: .destructive, title: "删除", handler: { action, view, actionBlock in
                if let item,let group{
                    item.didCommitEditBlock?(item,group)
                }
            })])
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let dataSource = tableView.wp.dataSource
        let item = dataSource.groups.wp_get(of: indexPath.section)?.items.wp_get(of: indexPath.row)
        
        if dataSource.editingStyleForRowAt != nil {
            return dataSource.editingStyleForRowAt!(tableView, indexPath)
        }
        if item != nil {
            return item!.editingStyle
        }
        return .none
    }
}
