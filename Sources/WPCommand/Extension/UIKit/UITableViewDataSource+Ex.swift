//
//  UITableViewDataSource.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/18.
//

import UIKit

private var WPTableViewDataSourcePointer = "WPTableViewDataSourcePointer"

/// 扩展数据源
extension UITableView {
    /// 数据源
    var wp_source: WPTableViewSource {
        set {
            WPRunTime.set(self, newValue, withUnsafePointer(to: &WPTableViewDataSourcePointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = self.wp_delegate
            dataSource = newValue
        }
        get {
            guard let source: WPTableViewSource = WPRunTime.get(self, withUnsafePointer(to: &WPTableViewDataSourcePointer, {$0})) else {
                let wp_source = WPTableViewSource(tableView: self)
                self.wp_source = wp_source
                return wp_source
            }
            return source
        }
    }
}

public extension WPSpace where Base: UITableView {
    /// 桥接数据源
    var dataSource: WPTableViewSource {
        return base.wp_source
    }
}

public extension WPTableViewSource {
    enum ReloadMode {
        /// 默认模式 手动刷新
        case `default`
        /// 当新增了group时自动刷新
        case group
        /// 当新增了item时自动刷新
        case item
    }
}

public class WPTableViewSource: NSObject {
    /// 当前的tableView
    weak var tableView: UITableView!
    /// 初始化一个数据源
    /// - Parameter tableView: 对应的tableView
    public init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
    }

    /// 索引
    public var sectionIndexTitles:[String]?
    /// 索引事件
    public var sectionForSectionIndexTitleBlock:((String,Int)->Int)?
    /// 是否添加到superView
    private var isAddToSuperView = false
    /// 刷新模式 暂未测
    public var reloadMode: ReloadMode = .default
    /// 每一组
    public var groups: [WPTableGroup] = [] {
        didSet {
            switch reloadMode {
            case .item:
                
                for group in groups {
                    group.didAddItem = { section, style -> () in
                        DispatchQueue.main.async { [unowned self] in
                            if isAddToSuperView {
                                tableView.reloadSections([section], with: style)
                            } else {
                                tableView.reloadData()
                            }
                        }
                    }
                }
                
            case .group:
                tableView.reloadData()
            default:
                tableView.reloadData()
            }
        }
    }

    /// 这一行的编辑样式
    public var editingStyleForRowAt: ((UITableView, IndexPath) -> UITableViewCell.EditingStyle)?
    /// 这一组header的标题
    public var titleForHeaderInSection: ((UITableView, Int) -> String?)?
    /// 这一组Footer的标题
    public var titleForFooterInSection: ((UITableView, Int) -> String?)?
    
    /// 缓存标识符池
    private var identifiers: [String: String] = [:]
    
    /// 获取一个cell
    private func reusableCell(cellClass: UITableViewCell.Type,
                              indexPath: IndexPath) -> UITableViewCell
    {
        let key = NSStringFromClass(cellClass)
        let resualt = (identifiers[key] != nil)
        var id: String!
        if resualt {
            id = identifiers[key]
        } else {
            id = String.wp.random(length: 20)
            tableView.register(cellClass, forCellReuseIdentifier: id)
            identifiers[key] = id
        }

        return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
    }
}

extension WPTableViewSource: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups[section].section = section
        return groups[section].items.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = groups[indexPath.section].items[indexPath.row]
        
        let cell = reusableCell(cellClass: item.cellClass, indexPath: indexPath)
        cell.item = item
        item.uploadItemBlock = { item in
            let cell = tableView.cellForRow(at: indexPath)
            cell?.didSetItem(item: item)
        }
        item.selectedToSelfBlock = { item in
            guard
                let indexPath = item.indexPath
            else { return }
            self.tableView.delegate?.tableView?(self.tableView, didSelectRowAt: indexPath)
        }
        
        item.indexPath = indexPath
        cell.didSetItemInfo(info: cell.item?.info)
        cell.didSetItem(item: item)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = groups.wp.get(section)
        
        if titleForHeaderInSection != nil {
            return titleForHeaderInSection!(tableView, section)
        } else if group != nil {
            return group?.headerTitle
        } else {
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let group = groups.wp.get(section)
        
        if titleForFooterInSection != nil {
            return titleForFooterInSection!(tableView, section)
        } else if group != nil {
            return group?.footerTitle
        } else {
            return nil
        }
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles
    }

    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let action = sectionForSectionIndexTitleBlock{
            return action(title,index)
        }

        return index
    }
    
}
