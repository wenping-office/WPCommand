//
//  UITableViewDataSource.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/18.
//

import UIKit

fileprivate var WPTableViewDataSourcePointer = "WPTableViewDataSourcePointer"

/// 扩展数据源
public extension UITableView{
    /// 数据源
    var wp_source : WPTableViewSource{
        set{
            WPRunTime.set(self, newValue, &WPTableViewDataSourcePointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = self.wp_delegate as? UITableViewDelegate
            dataSource = newValue
        }
        get{
            guard let source : WPTableViewSource = WPRunTime.get(self, &WPTableViewDataSourcePointer) else {
                let wp_source = WPTableViewSource(tableView: self)
                self.wp_source = wp_source
                return wp_source
            }
            return source
        }
    }
}

public extension WPTableViewSource{
    enum ReloadMode{
        /// 默认模式 手动刷新
        case `default`
        /// 当新增了group时自动刷新
        case group
        /// 当新增了item时自动刷新
        case item
    }
}

public class WPTableViewSource:NSObject {
    
    /// 当前的tableView
    weak var tableView : UITableView!
    /// 初始化一个数据源
    /// - Parameter tableView: 对应的tableView
    public init(tableView:UITableView) {
        self.tableView = tableView
        super.init()
    }
    /// 是否添加到superView
    private var isAddToSuperView = false
    /// 刷新模式 暂未测
    public var reloadMode : ReloadMode = .default
    /// 每一组
    public var groups : [WPTableGroup] = []{
        didSet{
            switch reloadMode {
            case .item:
                
                for group in groups {
                    group.didAddItem = { (section,style)->() in
                        DispatchQueue.main.async { [unowned self] in
                            if isAddToSuperView{
                                tableView.reloadSections([section], with: style)
                            }else{
                                tableView.reloadData()
                            }
                        }
                    }
                }
                break
                
            case .group:
                tableView.reloadData()
                break
            default:
                tableView.reloadData()
                break
            }
        }
    }
    /// 这一行的编辑样式
    var editingStyleForRowAt: ((UITableView,IndexPath) -> UITableViewCell.EditingStyle)?
    /// 这一组header的标题
    var titleForHeaderInSection : ((UITableView,Int) -> String?)?
    /// 这一组Footer的标题
    var titleForFooterInSection : ((UITableView,Int) -> String?)?
}

extension WPTableViewSource:UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups[section].section = section
        return groups[section].items.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = groups[indexPath.section].items[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier)
        
        item.uploadItemBlock = { item in
            let cell = tableView.cellForRow(at: indexPath)
            cell?.didSetItem(item: item)
        }
        
        if (cell == nil) {
            tableView.register(item.cellClass, forCellReuseIdentifier: item.reuseIdentifier)
            cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier)
            cell?.item = item
        }else{
            cell?.item = item
        }
        
        item.selectedToSelfBlock = { item in
            guard
                let indexPath = item.indexPath
            else { return }
            self.tableView.delegate?.tableView?(self.tableView, didSelectRowAt: indexPath)
        }
        
        item.indexPath = indexPath
        cell?.didSetItemInfo(info: cell?.item?.info)
        cell?.didSetItem(item: item)
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let group = groups.wp_safeGet(of:section)
        
        if titleForHeaderInSection != nil {
            return titleForHeaderInSection!(tableView,section)
        }else if (group != nil){
            return group?.headerTitle
        }else{
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let group = groups.wp_safeGet(of:section)
        
        if titleForFooterInSection != nil {
            return titleForFooterInSection!(tableView,section)
        }else if (group != nil){
            return group?.footerTitle
        }else{
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        let item = groups.wp_safeGet(of: indexPath.section)?.items.wp_safeGet(of: indexPath.row)
        
        if editingStyleForRowAt != nil {
            return editingStyleForRowAt!(tableView,indexPath)
        }else if item != nil {
            return item!.editingStyle
        }else{
            return .none
        }
    }
}


/*
 extension WPTableViewDelegate:UITableViewDelegate{
 
 public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
 return groups[indexPath.section].items[indexPath.row].cellHeight
 }
 
 public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
 let item = groups[indexPath.section].items[indexPath.row]
 return item.editingStyle
 }
 
 public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
 let item = groups[indexPath.section].items[indexPath.row]
 let group = groups[indexPath.section]
 
 item.didDeleteBlock != nil ? item.didDeleteBlock!(item,group) : print("")
 }
 
 public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 let item = groups[indexPath.section].items[indexPath.row]
 let baseCell = tableView.cellForRow(at: indexPath)
 item.didSelectedBlock != nil ? item.didSelectedBlock!(baseCell!) : print("")
 }
 
 public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
 
 return groups[section].headerTitle
 }
 
 public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
 return groups[section].footerTitle
 }
 
 public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
 return groups[section].headerHeight
 }
 
 public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
 return groups[section].footerHeight
 }
 
 public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
 let group = groups[section]
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
 return headView
 }
 
 public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
 
 let group = groups[section]
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
 return footView
 }
 
 public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
 
 let item = groups[indexPath.section].items[indexPath.row]
 item.willDisplay != nil ? item.willDisplay!(cell) : print("")
 cell.didSetItemInfo(info: item.info)
 }
 
 public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
 
 let group = groups[section]
 let headerView = view as! UITableViewHeaderFooterView
 headerView.reloadGroup(group: group)
 group.headWillDisplayBlock != nil ? group.headWillDisplayBlock!(headerView) : print("")
 
 }
 
 public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
 let group = groups[section]
 let footerView = view as! UITableViewHeaderFooterView
 footerView.reloadGroup(group: group)
 group.footWillDisplayBlock != nil ? group.headWillDisplayBlock!(footerView) : print("")
 }
 }
 
 */
