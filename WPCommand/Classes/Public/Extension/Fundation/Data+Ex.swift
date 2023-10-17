//
//  Data+Ex.swift
//  WPCommand
//
//  Created by Wen on 2023/10/16.
//
import Foundation

public extension WPSpace where Base == Data {

    
    /// 16进制转字节
    /// - Parameter hexStr: 字符串
    /// - Returns: 字节数组
    static func bytes(from hexStr: String) -> [UInt8] {
          var bytes = [UInt8]()
          var sum = 0
          // 整形的 utf8 编码范围
          let intRange = 48...57
          // 小写 a~f 的 utf8 的编码范围
          let lowercaseRange = 97...102
          // 大写 A~F 的 utf8 的编码范围
          let uppercasedRange = 65...70
          for (index, c) in hexStr.utf8CString.enumerated() {
              var intC = Int(c.byteSwapped)
              if intC == 0 {
                  break
              } else if intRange.contains(intC) {
                  intC -= 48
              } else if lowercaseRange.contains(intC) {
                  intC -= 87
              } else if uppercasedRange.contains(intC) {
                  intC -= 55
              } else {
                  assertionFailure("输入字符串格式不对，每个字符都需要在0~9，a~f，A~F内")
              }
              sum = sum * 16 + intC
              // 每两个十六进制字母代表8位，即一个字节
              if index % 2 != 0 {
                  bytes.append(UInt8(sum))
                  sum = 0
              }
          }
          return bytes
      }
}

public extension WPSpace where Base == Data{
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
    
    /// crc8加密
    /// - Parameter string: 字符串
    /// - Returns: 结果
   static func makeCRC8(_ string: String) -> UInt8 {
        guard let data = string.data(using: String.Encoding.utf8) else { return 0 }
        return makeCRC8(data)
    }
    
    /// crc8加密
    /// - Parameter data: 数据
    /// - Returns: 结果
   static func makeCRC8(_ data: Data) -> UInt8 {
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
   static func makeCRC8(_ u8Data: [UInt8]) -> UInt8 {
        var crc8:UInt8 = 0x00
        for i in 0..<u8Data.count {
            crc8 = table[Int(crc8 ^ u8Data[i])]
        }
        return crc8
    }
}
