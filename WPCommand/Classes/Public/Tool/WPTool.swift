//
//  WPTool.swift
//  WPCommand
//
//  Created by Wen on 2023/10/25.
//

import UIKit

/// 工具类
public class WPTool {
    private static let poly = 0x07
    private static let mask = 0xff
    private static let table: [UInt8] = {
        var table = Array.init(repeating: UInt8(0), count: 256)
        for i in 0..<table.count {
            var c = i
            for _ in 0..<8 {
                if c & 0x80 != 0 {
                    c = (((c << 1) & mask) ^ poly)
                } else {
                    c <<= 1
                }
            }
            table[i] = UInt8(c)
        }
        return table
    }()
}

public extension WPTool{
    /// crc8加密
    /// - Parameter string: 字符串
    /// - Returns: 结果
   static func makeCRC8(string: String) -> UInt8 {
        guard let data = string.data(using: String.Encoding.utf8) else { return 0 }
       return makeCRC8(data: data)
    }
    
    /// crc8加密
    /// - Parameter data: 数据
    /// - Returns: 结果
   static func makeCRC8(data: Data) -> UInt8 {
        let dataArray = [UInt8](data)
        var crc8:UInt8 = 0x00
        for i in 0..<dataArray.count {
            crc8 = table[Int(crc8 ^ dataArray[i])]
        }
        return crc8
    }
    
    /// crc8加密
    /// - Parameter u8Data: 数据
    /// - Returns: 结果
   static func makeCRC8(u8Data: [UInt8]) -> UInt8 {
        var crc8:UInt8 = 0x00
        for i in 0..<u8Data.count {
            crc8 = table[Int(crc8 ^ u8Data[i])]
        }
        return crc8
    }
}
