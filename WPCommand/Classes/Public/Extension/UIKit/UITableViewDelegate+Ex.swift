//
//  UITableViewDelegate+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/18.
//

import UIKit

fileprivate var WPTableViewDelegatePointer = "WPTableViewDelegatePointer"

public extension UITableView{
    
    override var wp_delegate: WPScrollViewDelegate{
        set{
            WPRunTime.set(self, newValue, &WPTableViewDelegatePointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = newValue as? UITableViewDelegate
        }
        get{
            guard let wp_delegate : WPTableViewDelegate = WPRunTime.get(self, &WPTableViewDelegatePointer) else {
                let wp_delegate = WPTableViewDelegate()
                self.wp_delegate = wp_delegate
                return wp_delegate
            }
            return wp_delegate
        }
    }
}

public class WPTableViewDelegate: WPScrollViewDelegate {
    
    /// 选中一行掉用
    var didSelectRowAt : ((UITableView,IndexPath) -> Void)?
    /// 每一行的高度
    var heightForRowAt : ((UITableView,IndexPath) -> CGFloat)?
    /// 编辑按钮的点击时间
    var commitEditingStyle : ((UITableView,IndexPath) -> Void)?
    /// 这一组header高度
    var heightForHeaderInSection : ((UITableView,Int) -> CGFloat)?
    /// 这一组footer高度
    var heightForFooterInSection : ((UITableView,Int) -> CGFloat)?
    /// 这一组的headerView
    var viewForHeaderInSection : ((UITableView,Int) -> UIView?)?
    /// 这一组的footerView
    var viewForFooterInSection : ((UITableView,Int) -> UIView?)?
    /// cell即将显示
    var willDisplayCell : ((UITableView,UITableViewCell,IndexPath) -> Void)?
    /// 这一组headerView即将显示
    var willDisplayHeaderView : ((UITableView,UIView,Int) ->Void)?
    /// 这一组foogerView即将显示
    var willDisplayFooterView : ((UITableView,UIView,Int) ->Void)?
    
}

extension WPTableViewDelegate:UITableViewDelegate{
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let item = tableView.wp_source.groups.wp_safeGet(of: indexPath.section)?.items.wp_safeGet(of: indexPath.row)
        
        if heightForRowAt != nil {
            return heightForRowAt!(tableView,indexPath)
        }else if item != nil {
            return item!.cellHeight
        }else{
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let group = tableView.wp_source.groups.wp_safeGet(of: indexPath.section)
        
        if let item = group?.items.wp_safeGet(of: indexPath.row){
            item.didCommitEditBlock != nil ? item.didCommitEditBlock!(item,group!) : print()
        }
        
        commitEditingStyle != nil ? commitEditingStyle!(tableView,indexPath) : print()
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let group = tableView.wp_source.groups.wp_safeGet(of:section)
        
        if heightForHeaderInSection != nil {
            return heightForHeaderInSection!(tableView,section)
        }else if (group != nil){
            return group!.headerHeight
        }else{
            return 0.01
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        let group = tableView.wp_source.groups.wp_safeGet(of:section)
        if heightForFooterInSection != nil {
            return heightForFooterInSection!(tableView,section)
        }else if (group != nil){
            return group!.footerHeight
        }else{
            return 0.01
        }
        
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if viewForHeaderInSection != nil {
            return viewForHeaderInSection!(tableView,section)
        }else if let group = tableView.wp_source.groups.wp_safeGet(of:section){
            
            guard let idStr = group.headViewReuseIdentifier else {
                return nil
            }
            guard let headView = tableView.dequeueReusableHeaderFooterView(withIdentifier: idStr)  else {
                tableView.register(group.headViewClass, forHeaderFooterViewReuseIdentifier: idStr)
                let newHeadView = tableView.dequeueReusableHeaderFooterView(withIdentifier: idStr)!
                newHeadView.group = group
                return newHeadView
            }
            headView.reloadGroup(group: group)
        }else{
            return nil
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if viewForFooterInSection != nil {
            return viewForFooterInSection!(tableView,section)
        }else if let group = tableView.wp_source.groups.wp_safeGet(of:section){
            guard let idStr = group.footViewReuseIdentifier else {
                return nil
            }
            guard let footView = tableView.dequeueReusableHeaderFooterView(withIdentifier: idStr)  else {
                tableView.register(group.footViewClass, forHeaderFooterViewReuseIdentifier: idStr)
                let newFootView = tableView.dequeueReusableHeaderFooterView(withIdentifier: idStr)!
                newFootView.group = group
                return newFootView
            }
            footView.reloadGroup(group: group)
        }else{
            return nil
        }
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        didSelectRowAt != nil ? didSelectRowAt!(tableView,indexPath) : print()
        if let item = tableView.wp_source.groups.wp_safeGet(of: indexPath.section)?.items.wp_safeGet(of: indexPath.row){
            let cell = tableView.cellForRow(at: indexPath)
            item.didSelectedBlock != nil ? item.didSelectedBlock!(cell!) : print("")
        }
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        willDisplayCell != nil ? willDisplayCell!(tableView,cell, indexPath) : print()
        
        if let item = tableView.wp_source.groups.wp_safeGet(of: indexPath.section)?.items.wp_safeGet(of: indexPath.row){
            item.willDisplay != nil ? item.willDisplay!(cell) : print("")
            cell.didSetItemInfo(info: item.info)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        willDisplayHeaderView != nil ? willDisplayHeaderView!(tableView,view,section) : print()
        
        if let group = tableView.wp_source.groups.wp_safeGet(of:section){
            let headerView = view as! UITableViewHeaderFooterView
            headerView.reloadGroup(group: group)
            group.headWillDisplayBlock != nil ? group.headWillDisplayBlock!(headerView) : print()
        }
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        willDisplayFooterView != nil ? willDisplayFooterView!(tableView,view,section) : print()
        
        if let group = tableView.wp_source.groups.wp_safeGet(of:section){
            let footerView = view as! UITableViewHeaderFooterView
            footerView.reloadGroup(group: group)
            group.footWillDisplayBlock != nil ? group.headWillDisplayBlock!(footerView) : print()
        }
    }
}
