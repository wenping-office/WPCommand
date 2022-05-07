//
//  ArrayEx.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/24.
//

import UIKit
public extension Array{
    /// 排序规则
    enum YPSortMode {
        /// 不排序
        case `default`
        /// 保留第一次出现的元素
        case fist
        /// 保留最后一次出现的元素
        case last
    }

    /// 去重操作
    /// - Parameter sortMode: 排序规则
    mutating func yp_repeat<V:Hashable,P:KeyPath<Element,V>>(retain sortMode: YPSortMode = .default,path:P) {
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
                    if json[elmt.key] == nil {
                        json[elmt.key] = elmt
                    }
                } else {
                    json[elmt.key] = elmt
                }
            }

            var tempTowArr: [(index: Int, key: V, obj: Element)] = []

            json.forEach { subDict in
                tempTowArr.append(subDict.value)
            }

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
    /// 过滤元素 返回ture过滤 否则不过滤
    /// - Parameter resualt: 过滤结果会改变自身 数组应该为可变属性
    mutating func yp_filter(by resultBlock: @escaping (Element)->Bool) {
        var result: [Element] = []
        forEach { elmt in
            if !resultBlock(elmt) {
                result.append(elmt)
            }
        }
        self = result
    }
    
    /// 安全插入一个元素
    /// - Parameters:
    ///   - newElmt: 元素
    ///   - index: 索引
    mutating func yp_insert(_ newElmt: Element, at index: Int) {
        if index <= 0, index < count {
            insert(newElmt, at: index)
        } else if index <= 0 {
            insert(newElmt, at: 0)
        } else {
            append(newElmt)
        }
    }
    
    /// 安全移除一个元素
    /// - Parameter index: 索引
    mutating func yp_remove(at index: Int) {
        if count > index - 1, index >= 0 {
            remove(at: index)
        }
    }
    
    /// 判断是否包含某个元素
    /// - Parameter resualtBlock: 条件
    /// - Returns: 结果
    func yp_isContent(in resualtBlock: @escaping (Element)->Bool)->Bool {
        for index in 0..<count {
            let elmt = self[index]
            if resualtBlock(elmt) {
                return true
            }
        }
        return false
    }
    
    /// 安全获取一个元素
    /// - Parameter index: 所有
    /// - Returns: 元素
    func yp_get(of index: Int)->Element? {
        if index <= count - 1, index >= 0 {
            return self[index]
        } else {
            return nil
        }
    }
    
    /// 交换元素
    /// - Parameters:
    ///   - index: 交换元素的索引
    ///   - newElmt: 元素
    mutating func yp_exchange(of index: Int, _ newElmt: Element) {
        yp_remove(at: index)
        
        yp_insert(newElmt, at: index)
    }
    
    /// 查找一组符合条件的元素
    /// - Parameter resualtBlock: 条件
    /// - Returns: 结果
    func yp_elmts(of resualtBlock: @escaping (Element)->Bool)->[Element] {
        var res: [Element] = []
        for index in 0..<count {
            let elmt = self[index]
            if resualtBlock(elmt) {
                res.append(elmt)
            }
        }
        return res
    }
    
    /// 查找某个符合条件的元素
    /// - Parameter resualtBlock: 条件
    /// - Returns: 结果
    func yp_elmt(of resualtBlock: @escaping (Element)->Bool)->Element? {
        var res: Element?
        for index in 0..<count {
            let elmt = self[index]
            if resualtBlock(elmt) {
                res = elmt
                break
            }
        }
        return res
    }
    
    /// 获取某个元素的下标 如果没有则返回空
    /// - Parameter resualtBlock: 条件block
    /// - Returns: 结果
    func yp_index(of resualtBlock: @escaping (Element)->Bool)->UInt? {
        var index: UInt?
        for subIndex in 0..<count {
            if resualtBlock(self[subIndex]) {
                index = UInt(subIndex)
                break
            }
        }
        return index
    }
    
    /// 从头部开始取值 数量不足则返回所有
    /// - Parameter count: 个数
    /// - Returns: 结果
    func yp_first(of count: Int)->[Element] {
        return yp_subArray(of: .init(location: 0, length: count))
    }
    
    /// 从尾部开始取值 数量不足则返回所有
    /// - Parameter count: 个数
    /// - Returns: 结果
    func yp_last(of count: Int)->[Element] {
        let location = self.count - count
        if count <= self.count {
            return Array(self[location..<self.count])
            
        } else {
            return Array(self[0..<self.count])
        }
    }
    
    /// 截取数组 如果lenght越界 则返回最大的可取范围
    /// - Parameter range: 返回
    /// - Returns: 结果
    func yp_subArray(of range: NSRange)->[Element] {
        let lenght = range.length
        let maxLenght = self.count - range.location
        if lenght <= maxLenght {
            let count = range.location + range.length
            return Array(self[range.location..<count])
        } else {
            return Array(self[range.location..<self.count])
        }
    }
    
    /// 递归 注：非交叉递归 如果会交叉那么会死循环，向上递归的时候会做去重
    /// - Parameters:
    ///   - obj: 目标对象
    ///   - topPath: 向上递归的path
    ///   - Path: 目标对象需要递归的属性必须是个数组
    ///   - option: 选择
    static func yp_recursion<T,
        O:KeyPath<T,T?>,
        P:KeyPath<T,[T]>>(_ obj:T ,topPath:O? = nil,path:P,
                          option:(T)->Bool = {_ in return true})->[T]{
        var resualt : [T] = []
    
        if topPath != nil{
            if obj[keyPath: topPath!] != nil{
                let topObj : T = obj[keyPath: topPath!]!
            
                for elmt in topObj[keyPath: path]{
                    if option(elmt){
                        resualt.append(elmt)
                    }
                    resualt.append(contentsOf: yp_recursion(topObj, topPath: topPath, path: path, option: option))
                }
            }
        }else{
            for elmt in obj[keyPath: path]{
                if option(elmt){
                    resualt.append(elmt)
                }
                resualt.append(contentsOf: yp_recursion(elmt, topPath: nil, path: path, option: option))
            }
        }
        return resualt
    }
}

