//
//  Collection+Ex.swift
//  WPCommand
//
//  Created by kuaiyin on 2025/9/26.
//

import UIKit

public extension WPSpace where Base: Collection {
    subscript(safe index: Base.Index) -> Base.Element? {
        return base.indices.contains(index) ? base[index] : nil
    }
    
    subscript(safe range: ClosedRange<Base.Index>) -> [Base.Element] {
        guard !base.isEmpty else { return [] }
        let lower = Swift.max(range.lowerBound, base.startIndex)
        let lastValid = base.index(base.endIndex, offsetBy: -1)
        let upper = range.upperBound > lastValid ? lastValid : range.upperBound
        if lower > upper { return [] }
        return Array(base[lower...upper])
    }

    subscript(safe range: Range<Base.Index>) -> [Base.Element] {
        guard !base.isEmpty else { return [] }
        let lower = Swift.max(range.lowerBound, base.startIndex)
        let upper = range.upperBound > base.endIndex ? base.endIndex : range.upperBound
        if lower >= upper { return [] }
        return Array(base[lower..<upper])
    }
    
    subscript(safe range: PartialRangeFrom<Base.Index>) -> [Base.Element] {
        guard !base.isEmpty else { return [] }

        let lower = Swift.max(range.lowerBound, base.startIndex)
        let upper = base.endIndex
        if lower >= upper { return [] }
        return Array(base[lower..<upper])
    }

    subscript(safe range: PartialRangeThrough<Base.Index>) -> [Base.Element] {
        guard !base.isEmpty else { return [] }
        let lower = base.startIndex
        let lastValid = base.index(base.startIndex, offsetBy: base.count - 1)
        let upper = range.upperBound > lastValid ? lastValid : range.upperBound
        if lower > upper { return [] }
        return Array(base[lower...upper])
    }

    subscript(safe range: PartialRangeUpTo<Base.Index>) -> [Base.Element] {
        guard !base.isEmpty else { return [] }
        let lower = base.startIndex
        let upper = range.upperBound > base.endIndex ? base.endIndex : range.upperBound
        if lower >= upper { return [] }
        return Array(base[lower..<upper])
    }
}


public extension WPSpace where Base: Collection, Base.Element: Hashable {

    /// 对比数组找出两个集合不同的元素
    /// - Parameter other: 目标集合
    /// - Returns: 返回当前集合与目标集合中不同的元素
    func difference(from other: Base) -> [Base.Element] {
        let thisSet = Set(base)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}


public extension WPSpace where Base: Collection, Base.Element: UIView {
    /// 水平中心点布局 类似于tabbar的Item效果
    /// - Parameters:
    ///   - maxWidth: 最大的宽
    ///   - block: 回调 包括子视图和当前子视图中心点的位置
    func horizontalCenterX(with maxWidth : CGFloat,block:(UIView,_ point:CGFloat)->Void){
        let count = base.count * 2
        let padding : CGFloat = maxWidth / CGFloat(count)
        var itemIndex = 0
        for index in 0...count {
            if (index % 2) > 0 {
                block(base[itemIndex as! Base.Index],CGFloat(CGFloat(index) * padding))
                itemIndex += 1
            }
        }
    }
    
    /// 设置所有view的抗拉伸等级
    /// - Parameters:
    ///   - priority: 等级
    ///   - axis: 轴
    ///   - option: 选择
    func setContentHugging(_ priority: UILayoutPriority,for axis:NSLayoutConstraint.Axis,option : ((UIView)->Bool) = {_ in return true}) {
        base.forEach { elmt in
            if option(elmt){
                elmt.setContentHuggingPriority(priority, for: axis)
            }
        }
    }
    
    /// 设置抗压缩等级
    /// - Parameters:
    ///   - priority: 等级
    ///   - axis: 轴
    ///   - option: 选择
    func setCompressionResistance(_ priority: UILayoutPriority,
                                  for axis:NSLayoutConstraint.Axis,
                                  option : ((UIView)->Bool) = {_ in return true}) {
        base.forEach { elmt in
            if option(elmt){
                elmt.setContentCompressionResistancePriority(priority, for: axis)
            }
        }
    }
}

public extension WPSpace where Base: Collection, Base.Element == String {
    
    /// 转换成string
    /// - Parameter divider: 分割符
    /// - Returns: 结果
    func string(divider: String = "") -> String {
        var str = ""
        base.forEach { elmt in
            str.append(elmt)
            str.append(divider)
        }
        
        if divider != "" {
            return str.wp[safe: ..<(str.count-1)]
        } else {
            return str
        }
    }
}

public extension WPSpace where Base: Collection, Base.Element == String.SubSequence {
    /// 转换成string
    /// - Parameter divider: 分割符
    /// - Returns: 结果
    func string(divider: String = "") -> String {
        var str = ""
        base.forEach { elmt in
            str.append(contentsOf: elmt)
            str.append(divider)
        }
        
        if divider != "" {
            return str.wp[safe: ..<(str.count-1)]
        } else {
            return str
        }
    }
}
