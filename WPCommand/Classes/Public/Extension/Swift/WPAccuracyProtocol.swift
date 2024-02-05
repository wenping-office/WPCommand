//
//  WPAccuracyProtocol.swift
//  WPCommand
//
//  Created by Wen_Ping on 2022/12/15.
//

import Foundation

/// 精度协议
public protocol WPAccuracyProtocol:CustomStringConvertible,BinaryFloatingPoint {}

extension CGFloat: WPAccuracyProtocol {}
extension Double: WPAccuracyProtocol {}

public extension WPSpace where Base: WPAccuracyProtocol {
    
    /// 精度
    func decimalNumber(length:Int = 2) -> NSDecimalNumber {
        return NSDecimalNumber.init(string: String(format: "%.\(length)f",base as! CVarArg))
    }
    
    /// 获取小数位
    /// - Parameters:
    ///   - length: 小数长度
    ///   - approximately: 四舍五入
    /// - Returns: 结果
    func decimal(length:Int = 0,
                 approximately:Bool = false)->String{
        let int = Int(base)

        let resualt = base - Base(Double(int))
        
        let minLength = length == 0 ? base.description.wp.minNumCount : length
        
        var resualtStr : String!

        if approximately{
            resualtStr = .init(format: "%0.\(minLength)f", resualt as! CVarArg)
        }else{
            let point = base.description.wp.of(".")
            
            resualtStr = "0\(base.description.wp.subString(of: .init(location: point.location, length: minLength + 1)))"
            if resualt < 0{
                resualtStr = "-" + resualtStr
            }
        }
        
        if (resualtStr as NSString).doubleValue == 0{
            return "0"
        }else{
            return (resualtStr as NSString).doubleValue.description
        }
    }
    
    /// 精度
    /// - Parameters:
    ///   - length: 小数位长度
    ///   - approximately: 四舍五入
    /// - Returns: 结果
    func accuracy(length:Int = 0,
                  approximately:Bool = false) -> String {
        var resualtStr : String!

        if approximately{
            resualtStr = .init(format: "%0.\(length)f", base as! CVarArg)
        }else{
            let point = base.description.wp.of(".")
            
            if point.length != 1 {
                resualtStr = ""
            }else{
                if length <= 0{
                    resualtStr = base.description.wp.subString(of: .init(location: 0, length:point.location))
                }else{
                    resualtStr = base.description.wp.subString(of: .init(location: 0, length:point.location + length + 1))
                }
            }
        }
        
        if (resualtStr as NSString).doubleValue == 0{
            return "0"
        }else{
            if length == 0{
                return resualtStr
            }else{
                let str = (resualtStr as NSString).doubleValue.description

                if Double(Int(base)) == (str as NSString).doubleValue{
                    return Int(base).description
                }
                return str
            }
        }
    }
}

