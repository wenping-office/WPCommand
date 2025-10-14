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
