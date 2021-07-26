//
//  WPTableView.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/2.
//

import UIKit


/// 系统代理 可以实现拖动监听手势等
public protocol WPTableViewSystemDelegate : UIScrollViewDelegate{
    
}

/// 默认使用autolayout布局
open class WPTableAutoLayoutView: UITableView {
    
    private var isAddToSuperView = false
    
    public var groups : [WPTableGroup] = []{
        didSet{
            switch reloadModel {
            case .item:
                
                for group in groups {
                    group.didAddItem = { (section,style)->() in
                        DispatchQueue.main.async { [unowned self] in
                            if isAddToSuperView{
                                reloadSections([section], with: style)
                            }else{
                                reloadData()
                            }
                        }
                    }
                }
                break
                
            case .group:
                reloadData()
                break
            default:
                reloadData()
                break
            }
            
        }
    }
    
    /// 继承自系统代理 如果要监听滑动手势等 可以重写
    public var systemDelegate : WPTableViewSystemDelegate?
    /// 暂未测
    public let reloadModel : WPTableAutoLayoutView.ReloadModel
    
    public enum ReloadModel{
        case `default`
        case group
        case item
    }
    
    public init(style:UITableView.Style,reloadModel:WPTableAutoLayoutView.ReloadModel) {
        self.reloadModel = reloadModel
        super.init(frame: CGRect.zero, style: style)
        delegate = self
        dataSource = self
        tableFooterView = UIView()
        sectionFooterHeight = 0.01
        sectionHeaderHeight = 0.01
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WPTableAutoLayoutView : UITableViewDataSource{
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

extension WPTableAutoLayoutView : UITableViewDelegate{
    
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
    
    //    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //        return groups[indexPath.section].items[indexPath.row].actions
    //    }
}

extension WPTableAutoLayoutView : UIScrollViewDelegate{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        systemDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        systemDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
}


