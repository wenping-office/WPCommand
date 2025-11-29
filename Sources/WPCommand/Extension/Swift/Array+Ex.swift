//
//  ArrayEx.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/24.
//

import UIKit
public extension Array{
    /// 排序规则
    enum WPSortMode {
        /// 不排序
        case `default`
        /// 保留第一次出现的元素
        case fist
        /// 保留最后一次出现的元素
        case last
    }

    /// 去重操作
    /// - Parameter sortMode: 排序规则
    mutating func wp_repeat<V:Hashable,P:KeyPath<Element,V>>(retain sortMode: WPSortMode = .default,path:P) {
        var resualtArray: [Element] = []

        if sortMode == .fist || sortMode == .last {
            var tempArray: [(index: Int, key: V, obj: Element)] = []

            for index in 0..<count {
                let obj = self[index]
                tempArray.append((index, obj[keyPath: path], obj))
            }

            var json: [V: (index: Int, key: V, obj: Element)] = [:]

            tempArray.forEach { elmt in

                if sortMode == .fist {
                    if json[elmt.key] == nil { // 添加第一次出现的元素
                        json[elmt.key] = elmt
                    }
                } else { // 保留最后一次出现的元素
                    json[elmt.key] = elmt
                }
            }

            /// 去重以后的arr
            var tempTowArr: [(index: Int, key: V, obj: Element)] = []

            json.forEach { subDict in
                tempTowArr.append(subDict.value)
            }

            // 排序
            let tempThreeArr = tempTowArr.sorted { obj1, obj2 in
                obj1.index < obj2.index
            }

            tempThreeArr.forEach { elmt in
                resualtArray.append(elmt.obj)
            }
        } else {
            var json: [V: Element] = [:]
            
            forEach { elmt in
                json[elmt[keyPath: path]] = elmt
            }

            json.forEach { subDict in
                resualtArray.append(subDict.value)
            }
        }
        
        self = resualtArray
    }
}

public extension Array {
    /// 直接修改原数组
    /// - Parameter resultBlock: 返回 true 表示要排除该元素
    mutating func wp_filter(exclude resultBlock: (Element) -> Bool) {
        self = filter { !resultBlock($0) }
    }
    
    // MARK: - 安全插入
    /// 安全插入元素（支持负索引：-1 表示插入到最后）
    /// 若索引超出范围，则自动修正到 [0...count]
    mutating func wp_insert(_ element: Element, at index: Int) {
        guard !isEmpty else {
            append(element)
            return
        }
        // 支持负索引
        let actualIndex: Int
        if index < 0 {
            actualIndex = Swift.max(0, count + index + 1)
        } else {
            actualIndex = Swift.min(index, count)
        }
        self.insert(element, at: actualIndex)
    }

    // MARK: - 安全移除
    /// 安全移除指定索引的元素（支持负索引）
    /// 返回被移除的元素（若越界则返回 nil）
    @discardableResult
    mutating func wp_remove(at index: Int) -> Element? {
        guard !isEmpty else { return nil }
        let actualIndex: Int
        if index < 0 {
            actualIndex = count + index
        } else {
            actualIndex = index
        }
        guard actualIndex >= 0 && actualIndex < count else { return nil }
        return remove(at: actualIndex)
    }
    
    // MARK: - 根据条件替换第一个匹配的元素
    /// 根据条件替换第一个匹配的元素
    /// - Parameters:
    ///   - condition: 判断是否匹配
    ///   - newElement: 要替换的新元素
    /// - Returns: 是否成功替换
    @discardableResult
    mutating func wp_replaceFirst(where condition: (Element) -> Bool, with newElement: Element) -> Bool {
        guard let idx = firstIndex(where: condition) else { return false }
        // 使用 replaceSubrange 替换单个元素，避免通过下标直接赋值的限制
        replaceSubrange(idx...idx, with: [newElement])
        return true
    }
    
    // MARK: - 根据条件替换最后一个匹配的元素
    /// 根据条件替换最后一个匹配的元素
    /// - Parameters:
    ///   - condition: 判断是否匹配
    ///   - newElement: 要替换的新元素
    /// - Returns: 是否成功替换
    @discardableResult
    mutating func replaceLast(where condition: (Element) -> Bool, with newElement: Element) -> Bool {
        if let lastIdx = indices.reversed().first(where: { condition(self[$0]) }) {
            replaceSubrange(lastIdx...lastIdx, with: CollectionOfOne(newElement))
            return true
        }
        return false
    }
}

public extension WPSpace where Base: RangeReplaceableCollection,Base.Index == Int {
    /// 返回过滤后的新数组（不修改原数组）
    /// - Parameter resultBlock: 返回 true 表示要排除该元素
    func filter(exclude resultBlock: (Base.Element) -> Bool) -> [Base.Element] {
        base.filter { !resultBlock($0) }
    }

    // MARK: - 安全获取
    /// 安全获取元素（支持负索引）
    func get(_ index: Int) -> Base.Element? {
        guard !base.isEmpty else { return nil }
        let actualIndex: Int
        if index < 0 {
            actualIndex = base.count + index
        } else {
            actualIndex = index
        }
        guard actualIndex >= 0 && actualIndex < base.count else { return nil }
        return base[actualIndex]
    }
    
    /// 查找第一个符合条件的元素
    /// - Parameter condition: 判断条件
    /// - Returns: 元素
    func elementFirst(where condition: (Base.Element) -> Bool) -> Base.Element? {
        base.filter { condition($0) }.first
    }
    
    /// 查找最后一个个符合条件的元素
    /// - Parameter condition: 判断条件
    /// - Returns: 元素
    func elementLast(where condition: (Base.Element) -> Bool) -> Base.Element? {
        base.filter { condition($0) }.reversed().first
    }

    /// 查找所有符合条件的元素
    /// - Parameter condition: 判断条件
    /// - Returns: 符合条件的元素数组
    func elements(where condition: (Base.Element) -> Bool) -> [Base.Element] {
        base.filter { condition($0) }
    }

    /// 查找所有符合条件元素的索引
    /// - Parameter condition: 判断条件
    /// - Returns: 符合条件的索引数组
    func findAllIndexes(where condition: (Base.Element) -> Bool) -> [Int] {
        base.indices.filter { condition(base[$0]) }
    }
    
    /// 根据条件分组
    /// - Parameter areEqual: 条件
    /// - Returns: 结果
    func group(by areEqual: (Base.Element, Base.Element) -> Bool) -> [[Base.Element]] {
        var result: [[Base.Element]] = []
        for item in base {
            if let lastGroup = result.last, let last = lastGroup.last, areEqual(last, item) {
                result[result.count - 1].append(item)
            } else {
                result.append([item])
            }
        }
        
        return result
    }
    
    /// 安全切片
    /// - Parameters:
    ///   - start: 起始索引（支持负数，-1 表示倒数第1个元素）
    ///   - length: 切片长度
    /// - Returns: 一个 Array，长度可能小于指定长度
    func array(from start: Int, length: Int) -> [Base.Element] {
        guard !base.isEmpty, length > 0 else { return [] }
        let safeStart = max(0, min(start, base.count))
        let safeLength = min(length, base.count - safeStart)
        return Array(base[safeStart..<safeStart+safeLength])
    }
    
    /// 按照长度切片
    /// - Parameter length: 长度
    /// - Returns: 结果
    func section(with length: Int) -> [[Base.Element]] {
        guard length > 0, !base.isEmpty else { return [] }
        var result: [[Base.Element]] = []
        let subCount = base.count / length + (base.count % length > 0 ? 1 : 0)
        for i in 0..<subCount {
            let start = i * length
            result.append(self.array(from: start, length: length))
        }
        return result
    }
}
