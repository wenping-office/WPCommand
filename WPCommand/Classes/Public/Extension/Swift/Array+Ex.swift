//
//  ArrayEx.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/24.
//

import UIKit

public extension Array{
    
    /// 复制一个array
    var wp_copy : [Element]{
        let arr = self
        return arr
    }

    /// 过滤元素 返回ture过滤 否则不过滤
    /// - Parameter resualt: 过滤结果会改变自身 数组应该为可变属性
    mutating func wp_filter(by resultBlock:@escaping(Element) -> Bool){
        var result : [Element] = []
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
    mutating func wp_safeInset(_ newElmt:Element ,at index:Int){
        if index <= 0 {
            insert(newElmt, at: 0)
        }else{
            insert(newElmt, at: index)
        }
    }
    
    /// 安全移除一个元素
    /// - Parameter index: 索引
    mutating func wp_safeRemove(at index:Int){
        if count > index-1 && index >= 0{
            remove(at: index)
        }
    }
    
    
    /// 判断是否包含某个元素
    /// - Parameter resualtBlock: 条件
    /// - Returns: 结果
    func wp_isContent(in resualtBlock:@escaping(Element)->Bool) -> Bool {
        for index in 0..<count {
            let elmt = self[index]
            if resualtBlock(elmt){
                return true
            }
        }
        return false
    }

    /// 安全获取一个元素
    /// - Parameter index: 所有
    /// - Returns: 元素
    func wp_safeGet(of index:Int)->Element?{
        
        if index <= count-1 && index >= 0 {
            return self[index]
        }else{
            return nil
        }
    }

    /// 交换元素
    /// - Parameters:
    ///   - index: 交换元素的索引
    ///   - newElmt: 元素
    mutating func wp_exchange(of index:Int,_ newElmt:Element){
        
        wp_safeRemove(at: index)
        
        wp_safeInset(newElmt, at: index)
    }
    
    /// 查找一组符合条件的元素
    /// - Parameter resualtBlock: 条件
    /// - Returns: 结果
    func wp_elmts(by resualtBlock:@escaping(Element)->Bool)->[Element]{
        var res : [Element] = []
        for index in 0..<count {
            let elmt = self[index]
            if resualtBlock(elmt){
                res.append(elmt)
            }
        }
        return res
    }
    
    /// 查找某个符合条件的元素
    /// - Parameter resualtBlock: 条件
    /// - Returns: 结果
    func wp_elmt(by resualtBlock:@escaping(Element)->Bool)->Element?{
        var res : Element?
        for index in 0..<count {
            let elmt = self[index]
            if resualtBlock(elmt){
                res = elmt
                break
            }
        }
        return res
    }
    
    /// 获取某个元素的下标 如果没有则返回空
    /// - Parameter resualtBlock: 条件block
    /// - Returns: 结果
    func wp_index(of resualtBlock:@escaping(Element)->Bool)->UInt?{
        var index : UInt?
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
    func wp_fistTo(_ count:Int) -> ArraySlice<Element>{
        return wp_subArrTo(.init(location: 0, length: count))
    }
    
    /// 从尾部开始取值 数量不足则返回所有
    /// - Parameter count: 个数
    /// - Returns: 结果
    func wp_lastTo(_ count:Int) -> ArraySlice<Element> {

        let location = self.count - count
        if count <= self.count {
            return self[location..<self.count]
        }else{
            return self[0..<self.count]
        }
    }
    
    /// 截取数组 如果lenght越界 则返回最大的可取范围
    /// - Parameter range: 返回
    /// - Returns: 结果
    func wp_subArrTo(_ range:NSRange) -> ArraySlice<Element>{
        let lenght = range.length
        let maxLenght = self.count - range.location
        if lenght <= maxLenght {
            let count = range.location + range.length
            return self[range.location..<count]
        }else{
            return self[range.location..<self.count]
        }

    }
}

public extension Array where Element: WPRepeatProtocol{
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
    mutating func wp_repeat(retain sortMode: WPSortMode = .default){
        var resualtArray : [Element] = []
        
        if sortMode == .fist || sortMode == .last {
            var tempArray : [(index:Int,key:Element.type,obj:Element)] = []

            for index in 0..<count {
                let obj = self[index]
                tempArray.append((index,obj.wp_repeatKey,obj))
            }

            var json : [Element.type:(index:Int,key:Element.type,obj:Element)] = [:]
            
            tempArray.forEach { elmt  in

                if sortMode == .fist{
                    if json[elmt.key] == nil{ // 添加第一次出现的元素
                       json[elmt.key] = elmt
                     }
                }else{ // 保留最后一次出现的元素
                    json[elmt.key] = elmt
                }
            }
            
            /// 去重以后的arr
            var tempTowArr : [(index:Int,key:Element.type,obj:Element)] = []

            json.forEach { subDict in
                tempTowArr.append(subDict.value)
            }

            // 排序
           let tempThreeArr = tempTowArr.sorted { obj1, obj2 in
                return obj1.index < obj2.index
            }

            tempThreeArr.forEach { elmt in
                resualtArray.append(elmt.obj)
            }
        }else{
            
            var json : [Element.type:Element] = [:]
            forEach { elmt in
                json[elmt.wp_repeatKey] = elmt
            }
            
            json.forEach { subDict in
                resualtArray.append(subDict.value)
            }
        }

        self = resualtArray
    }
}

public extension Array where Element:Hashable{

}




