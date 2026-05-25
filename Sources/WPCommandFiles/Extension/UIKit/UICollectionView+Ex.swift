//
//  UICollectionView+Ex.swift
//  WPCommand
//
//  Created by Wen on 2024/1/16.
//

import UIKit

public extension WPSpace where Base: UICollectionView{
    
    @discardableResult
    func layout(_ layout: UICollectionViewLayout) -> Self {
        base.collectionViewLayout = layout
        return self
    }
    
    @discardableResult
    func delegate(_ delegate: UICollectionViewDelegate?) -> Self {
        base.delegate = delegate
        return self
    }
    
    @discardableResult
    func dataSource(_ dataSource: UICollectionViewDataSource?) -> Self {
        base.dataSource = dataSource
        return self
    }
    
    @discardableResult
    func prefetchDataSource(_ prefetchDataSource: UICollectionViewDataSourcePrefetching?) -> Self {
        base.prefetchDataSource = prefetchDataSource
        return self
    }

    @discardableResult
    func isPrefetchingEnabled(_ isPrefetchingEnabled: Bool) -> Self {
        base.isPrefetchingEnabled = isPrefetchingEnabled
        return self
    }
    
    @discardableResult
    func dragDelegate(_ dragDelegate: UICollectionViewDragDelegate?) -> Self {
        base.dragDelegate = dragDelegate
        return self
    }
    
    @discardableResult
    func dropDelegate(_ dropDelegate: UICollectionViewDropDelegate?) -> Self {
        base.dropDelegate = dropDelegate
        return self
    }
    
    @discardableResult
    func dragInteractionEnabled(_ dragInteractionEnabled: Bool) -> Self {
        base.dragInteractionEnabled = dragInteractionEnabled
        return self
    }
    
    @discardableResult
    func reorderingCadence(_ reorderingCadence: UICollectionView.ReorderingCadence) -> Self {
        base.reorderingCadence = reorderingCadence
        return self
    }
    
    @available(iOS 16.0, *)
    @discardableResult
    func selfSizingInvalidation(_ selfSizingInvalidation: UICollectionView.SelfSizingInvalidation) -> Self {
        base.selfSizingInvalidation = selfSizingInvalidation
        return self
    }
    
    @discardableResult
    func backgroundView(_ backgroundView: UIView?) -> Self {
        base.backgroundView = backgroundView
        return self
    }

    @discardableResult
    func allowsSelection(_ allowsSelection: Bool) -> Self {
        base.allowsSelection = allowsSelection
        return self
    }
    
    @discardableResult
    func allowsMultipleSelection(_ allowsMultipleSelection: Bool) -> Self {
        base.allowsMultipleSelection = allowsMultipleSelection
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
    
    @available(iOS 14.0, *)
    @discardableResult
    func isEditing(_ isEditing: Bool) -> Self {
        base.isEditing = isEditing
        return self
    }
    
    @available(iOS 14.0, *)
    @discardableResult
    func allowsSelectionDuringEditing(_ allowsSelectionDuringEditing: Bool) -> Self {
        base.allowsSelectionDuringEditing = allowsSelectionDuringEditing
        return self
    }

    @available(iOS 14.0, *)
    @discardableResult
    func allowsMultipleSelectionDuringEditing(_ allowsMultipleSelectionDuringEditing: Bool) -> Self {
        base.allowsMultipleSelectionDuringEditing = allowsMultipleSelectionDuringEditing
        return self
    }
}

public extension WPSpace where Base: UICollectionView{
    enum KindSectionStyle{
        case Header
        case Footer
        
       fileprivate var kind:String{
            switch self {
            case .Header:
                return UICollectionView.elementKindSectionHeader
            case .Footer:
                return UICollectionView.elementKindSectionFooter
            }
        }
    
    }

    /// 注册 Cell（类名作为 reuseIdentifier）
    func registerClass<T: UICollectionViewCell>(_ cellType: T.Type) {
        
        base.register(cellType, forCellWithReuseIdentifier: String(describing: cellType))
    }
    
    /// 复用 Cell（类名作为 reuseIdentifier）
    func dequeueReusable<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        let identifier = String(describing: cellType)
        
        guard let cell = base.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Cell 未注册: \(identifier)")
        }
        return cell
    }
    
    /// 注册 HeaderFooter（类名作为 reuseIdentifier）
    func registerHederOrFooter<T: UICollectionReusableView>(_ viewType: T.Type,_ kind:KindSectionStyle) {
        base.register(viewType.self, forSupplementaryViewOfKind: kind.kind, withReuseIdentifier: String(describing: viewType))
    }
    
    /// 复用 HeaderFooter（类名作为 reuseIdentifier）
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(_ viewType: T.Type,_ kind:KindSectionStyle, for indexPath: IndexPath) -> T {
        let identifier = String(describing: viewType)
        
        guard let cell = base.dequeueReusableSupplementaryView(ofKind: kind.kind, withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("View 未注册: \(identifier)")
        }
        return cell
    }
}
