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
    
    /// 桥接代理
    var wp_bridgeDelegate : WPTableViewDelegate{
        return wp_delegate as! WPTableViewDelegate
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
        
        let item = tableView.wp_source.groups.wp_get(of: indexPath.section)?.items.wp_get(of: indexPath.row)
        
        if heightForRowAt != nil {
            return heightForRowAt!(tableView,indexPath)
        }else if item != nil {
            return item!.cellHeight
        }else{
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let group = tableView.wp_source.groups.wp_get(of: indexPath.section)
        
        if let item = group?.items.wp_get(of: indexPath.row){
            item.didCommitEditBlock?(item,group!)
        }
        
        commitEditingStyle?(tableView,indexPath)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let group = tableView.wp_source.groups.wp_get(of:section)
        
        if heightForHeaderInSection != nil {
            return heightForHeaderInSection!(tableView,section)
        }else if (group != nil){
            return group!.headerHeight
        }else{
            return 0.01
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        let group = tableView.wp_source.groups.wp_get(of:section)
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
        }else if let group = tableView.wp_source.groups.wp_get(of:section){
            var headView : UITableViewHeaderFooterView?
            
            if let idStr = group.headViewReuseIdentifier{
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
            return viewForFooterInSection!(tableView,section)
        }else if let group = tableView.wp_source.groups.wp_get(of:section){
            var foodView : UITableViewHeaderFooterView?
            
            if let idStr = group.footViewReuseIdentifier{
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
        
        didSelectRowAt?(tableView,indexPath)
        if let item = tableView.wp_source.groups.wp_get(of: indexPath.section)?.items.wp_get(of: indexPath.row){
            let cell = tableView.cellForRow(at: indexPath)
            item.didSelectedBlock?(cell!)
        }
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        willDisplayCell?(tableView,cell, indexPath)
        
        if let item = tableView.wp_source.groups.wp_get(of: indexPath.section)?.items.wp_get(of: indexPath.row){
            item.willDisplay?(cell)
            cell.didSetItemInfo(info: item.info)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        willDisplayHeaderView?(tableView,view,section)
        
        if let group = tableView.wp_source.groups.wp_get(of:section){
            let headerView = view as! UITableViewHeaderFooterView
            headerView.reloadGroup(group: group)
            group.headWillDisplayBlock?(headerView)
        }
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        willDisplayFooterView?(tableView,view,section)
        
        if let group = tableView.wp_source.groups.wp_get(of:section){
            let footerView = view as! UITableViewHeaderFooterView
            footerView.reloadGroup(group: group)
            group.headWillDisplayBlock?(footerView)
        }
    }
}
