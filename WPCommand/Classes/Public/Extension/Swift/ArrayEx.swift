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

    
    /// 获取某个元素的下标
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
            var tempArray : [(index:Int,key:String,obj:Element)] = []

            for index in 0..<count {
                let obj = self[index]
                tempArray.append((index,obj.wp_repeatKey(),obj))
            }

            var json : [String:(index:Int,key:String,obj:Element)] = [:]
            
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
            var tempTowArr : [(index:Int,key:String,obj:Element)] = []

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
            
            var json : [String:Element] = [:]
            forEach { elmt in
                json[elmt.wp_repeatKey()] = elmt
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




