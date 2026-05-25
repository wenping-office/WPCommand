//
//  WPAccuracyProtocol.swift
//  WPCommand
//
//  Created by Wen_Ping on 2022/12/15.
//

import Foundation

public extension WPSpace where Base: BinaryFloatingPoint {
    
    /// 保留小数
    /// - Parameters:
    ///   - length: 小数长度
    ///   - approximately: 是否四舍五入
    /// - Returns: 结果
    func formatString(length: Int = 2,
                approximately: Bool = true) -> String {
        let value = Double(base)  // 转 Double 使用 String(format:)
        guard length > 0 else { return "\(Int(value))" }
        
        var number = value
        if !approximately {
            let factor = pow(10.0, Double(length))
            number = Double(Int(number * factor)) / factor
        }
        
        var formatted = String(format: "%.\(length)f", number)
        // 去掉末尾多余的 0 和小数点
        while formatted.last == "0" { formatted.removeLast() }
        if formatted.last == "." { formatted.removeLast() }
        
        return formatted
    }
    
    
    /// 获取小数部分转String
    /// - Parameters:
    ///   - length: 小数长度
    ///   - approximately: 是否四舍五入
    /// - Returns: 结果
    func decimalString(length: Int = 18, approximately: Bool = true) -> String {
        var value = Double(base)
        // 取小数部分
        value = value - floor(value)
        
        guard length > 0 else { return "" }
        
        if !approximately {
            let factor = pow(10.0, Double(length))
            value = Double(Int(value * factor)) / factor
        }
        
        var formatted = String(format: "%.\(length)f", value)
        
        // 去掉开头的 "0."
        if formatted.hasPrefix("0.") {
            formatted = String(formatted.dropFirst(2))
        }
        
        // 去掉末尾多余的 0
        while formatted.last == "0" {
            formatted.removeLast()
        }
        
        return formatted
    }
    
    /// 将任意浮点类型转换成任意整数类型
     /// - Parameter roundingRule: 舍入规则，默认 .toNearestOrAwayFromZero
     /// - Returns: 转换后的整数
    func toInt<T: FixedWidthInteger>(roundingRule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> T {
        let rounded = base.rounded(roundingRule)
        let maxValue = Base(T.max)
        let minValue = Base(T.min)
        
        if rounded >= maxValue {
            return T.max
        } else if rounded <= minValue {
            return T.min
        } else {
            return T(exactly: rounded) ?? T.max
        }
    }
}

