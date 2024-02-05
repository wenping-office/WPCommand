//
//  UITableViewEx.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/20.
//

import UIKit

public extension WPSpace where Base: UITableView {
    /// 注册xibCell
    /// - Parameter aClass: 类型
    func register<T: UITableViewCell>(withNib cellType: T.Type) {
        let name = String(describing: cellType)
        let nib = UINib(nibName: name, bundle: nil)
        base.register(nib, forCellReuseIdentifier: name)
    }

    /// 注册一个cell
    /// - Parameter aClass: cell
    func register<T: UITableViewCell>(with cellType: T.Type) {
        let name = String(describing: cellType)
        base.register(cellType, forCellReuseIdentifier: name)
    }

    /// 获取一个注册的cell
    /// - Parameter aClass: cell类型
    /// - Returns: cell
    func dequeue<T: UITableViewCell>(of cellType: T.Type) -> T! {
        let name = String(describing: cellType)
        guard let cell = base.dequeueReusableCell(withIdentifier: name) as? T else {
            fatalError("*\(name)* 未注册")
        }
        return cell
    }

    /// 注册一个Xib的header或footer
    /// - Parameter aClass: 类型
    func registerHeaderFooter<T: UIView>(withNib headerFooterType: T.Type) {
        let name = String(describing: headerFooterType)
        let nib = UINib(nibName: name, bundle: nil)
        base.register(nib, forHeaderFooterViewReuseIdentifier: name)
    }

    /// 注册一个header或footer
    /// - Parameter aClass: 类型
    func registerHeaderFooter<T: UIView>(with headerFooterType: T.Type) {
        let name = String(describing: headerFooterType)
        base.register(headerFooterType, forHeaderFooterViewReuseIdentifier: name)
    }

    /// 获取一个注册的header或者footer
    /// - Parameter aClass: 类型
    /// - Returns: headerfooter
    func dequeueHeaderFooter<T: UIView>(of headerFooterType: T.Type) -> T! {
        let name = String(describing: headerFooterType)
        guard let cell = base.dequeueReusableHeaderFooterView(withIdentifier: name) as? T else {
            fatalError("\(name) 未注册")
        }
        return cell
    }
}

public extension WPSpace where Base: UITableView{
    
    @discardableResult
    func dataSource(_ dataSource:UITableViewDataSource?) -> Self{
        base.dataSource = dataSource
        return self
    }
    
    @discardableResult
    func delegate(_ delegate:UITableViewDelegate?) -> Self{
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func prefetchDataSource(_ prefetchDataSource: UITableViewDataSourcePrefetching?) -> Self {
        base.prefetchDataSource = prefetchDataSource
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func isPrefetchingEnabled(_ isPrefetchingEnabled:Bool) -> Self {
        base.isPrefetchingEnabled = isPrefetchingEnabled
        return self
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func dragDelegate(_ dragDelegate: UITableViewDragDelegate?) -> Self {
        base.dragDelegate = dragDelegate
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func dropDelegate(_ dropDelegate: UITableViewDropDelegate?) -> Self {
        base.dropDelegate = dropDelegate
        return self
    }
    
    @discardableResult
    func rowHeight(_ rowHeight: CGFloat) -> Self {
        base.rowHeight = rowHeight
        return self
    }
    
    @discardableResult
    func sectionHeaderHeight(_ sectionHeaderHeight: CGFloat) -> Self {
        base.sectionHeaderHeight = sectionHeaderHeight
        return self
    }
    
    @discardableResult
    func sectionFooterHeight(_ sectionFooterHeight: CGFloat) -> Self {
        base.sectionFooterHeight = sectionFooterHeight
        return self
    }
    
    @discardableResult
    func estimatedRowHeight(_ estimatedRowHeight: CGFloat) -> Self {
        base.estimatedRowHeight = estimatedRowHeight
        return self
    }
    
    @discardableResult
    func estimatedSectionHeaderHeight(_ estimatedSectionHeaderHeight: CGFloat) -> Self {
        base.estimatedSectionHeaderHeight = estimatedSectionHeaderHeight
        return self
    }
    
    @discardableResult
    func estimatedSectionFooterHeight(_ estimatedSectionFooterHeight: CGFloat) -> Self {
        base.estimatedSectionFooterHeight = estimatedSectionFooterHeight
        return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func fillerRowHeight(_ fillerRowHeight: CGFloat) -> Self {
        base.fillerRowHeight = fillerRowHeight
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func sectionHeaderTopPadding(_ sectionHeaderTopPadding: CGFloat) -> Self {
        base.sectionHeaderTopPadding = sectionHeaderTopPadding
        return self
    }
    
    @discardableResult
    func separatorInset(_ separatorInset: UIEdgeInsets) -> Self {
        base.separatorInset = separatorInset
        return self
    }
    
    @discardableResult
    func separatorInsetReference(_ separatorInsetReference: UITableView.SeparatorInsetReference) -> Self {
        base.separatorInsetReference = separatorInsetReference
        return self
    }
    
    @available(iOS 16.0, *)
    @discardableResult
    func selfSizingInvalidation(_ selfSizingInvalidation: UITableView.SelfSizingInvalidation) -> Self {
        base.selfSizingInvalidation = selfSizingInvalidation
        return self
    }
    
    @discardableResult
    func backgroundView(_ backgroundView: UIView?) -> Self {
        base.backgroundView = backgroundView
        return self
    }

    @discardableResult
    func isEditing(_ isEditing: Bool) -> Self {
        base.isEditing = isEditing
        return self
    }
    
    @discardableResult
    func allowsSelection(_ allowsSelection: Bool) -> Self {
        base.allowsSelection = allowsSelection
        return self
    }
    
    @discardableResult
    func allowsSelectionDuringEditing(_ allowsSelectionDuringEditing: Bool) -> Self {
        base.allowsSelectionDuringEditing = allowsSelectionDuringEditing
        return self
    }
    
    @discardableResult
    func allowsMultipleSelection(_ allowsMultipleSelection: Bool) -> Self {
        base.allowsMultipleSelection = allowsMultipleSelection
        return self
    }
    
    @discardableResult
    func allowsMultipleSelectionDuringEditing(_ allowsMultipleSelectionDuringEditing: Bool) -> Self {
        base.allowsMultipleSelectionDuringEditing = allowsMultipleSelectionDuringEditing
        return self
    }

    @discardableResult
    func sectionIndexMinimumDisplayRowCount(_ sectionIndexMinimumDisplayRowCount: Int) -> Self {
        base.sectionIndexMinimumDisplayRowCount = sectionIndexMinimumDisplayRowCount
        return self
    }
    
    @discardableResult
    func sectionIndexColor(_ sectionIndexColor: UIColor?) -> Self {
        base.sectionIndexColor = sectionIndexColor
        return self
    }
    
    @discardableResult
    func sectionIndexBackgroundColor(_ sectionIndexBackgroundColor: UIColor?) -> Self {
        base.sectionIndexBackgroundColor = sectionIndexBackgroundColor
        return self
    }
    
    @discardableResult
    func sectionIndexTrackingBackgroundColor(_ sectionIndexTrackingBackgroundColor: UIColor?) -> Self {
        base.sectionIndexTrackingBackgroundColor = sectionIndexTrackingBackgroundColor
        return self
    }
    
    @discardableResult
    func separatorStyle(_ separatorStyle: UITableViewCell.SeparatorStyle) -> Self {
        base.separatorStyle = separatorStyle
        return self
    }
    
    @discardableResult
    func separatorColor(_ separatorColor: UIColor?) -> Self {
        base.separatorColor = separatorColor
        return self
    }

    @discardableResult
    func separatorEffect(_ separatorEffect: UIVisualEffect?) -> Self {
        base.separatorEffect = separatorEffect
        return self
    }
    
    @discardableResult
    func cellLayoutMarginsFollowReadableWidth(_ cellLayoutMarginsFollowReadableWidth: Bool) -> Self {
        base.cellLayoutMarginsFollowReadableWidth = cellLayoutMarginsFollowReadableWidth
        return self
    }
    
    @discardableResult
    func insetsContentViewsToSafeArea(_ insetsContentViewsToSafeArea: Bool) -> Self {
        base.insetsContentViewsToSafeArea = insetsContentViewsToSafeArea
        return self
    }
    
    @discardableResult
    func tableHeaderView(_ tableHeaderView: UIView?) -> Self {
        base.tableHeaderView = tableHeaderView
        return self
    }
    
    @discardableResult
    func tableFooterView(_ tableFooterView: UIView?) -> Self {
        base.tableFooterView = tableFooterView
        return self
    }
    
    @discardableResult
    func remembersLastFocusedIndexPath(_ remembersLastFocusedIndexPath: Bool) -> Self {
        base.remembersLastFocusedIndexPath = remembersLastFocusedIndexPath
        return self
    }

    @available(iOS 14.0, *)
    @discardableResult
    func selectionFollowsFocus(_ selectionFollowsFocus: Bool) -> Self {
        base.selectionFollowsFocus = selectionFollowsFocus
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func allowsFocus(_ allowsFocus: Bool) -> Self {
        base.allowsFocus = allowsFocus
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func allowsFocusDuringEditing(_ allowsFocusDuringEditing: Bool) -> Self {
        base.allowsFocusDuringEditing = allowsFocusDuringEditing
        return self
    }
    
    @discardableResult
    func dragInteractionEnabled(_ dragInteractionEnabled: Bool) -> Self {
        base.dragInteractionEnabled = dragInteractionEnabled
        return self
    }
}


