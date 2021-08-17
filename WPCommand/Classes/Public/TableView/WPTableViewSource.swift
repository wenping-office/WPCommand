//
//  WPTableViewSource.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/17.
//

import UIKit

fileprivate var WPTableViewSourcePointer = "WPTableViewSourcePointer"

/// 扩展数据源
public extension UITableView{

    /// 数据源
    var wp_source : WPTableViewSource{
        set{
            WPRunTime.set(self, newValue, &WPTableViewSourcePointer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = newValue
            dataSource = newValue
        }
        get{
            guard let source : WPTableViewSource = WPRunTime.get(self, &WPTableViewSourcePointer) else {
                let wp_source = WPTableViewSource(tableView: self)
                delegate = wp_source
                dataSource = wp_source
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

public class WPTableViewSource:WPBaseSource {
    
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
            self.tableView(tableView, didSelectRowAt: indexPath)
        }
        
        item.indexPath = indexPath
        cell?.didSetItemInfo(info: cell?.item?.info)
        cell?.didSetItem(item: item)
        return cell!
    }
}

extension WPTableViewSource:UITableViewDelegate{
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




