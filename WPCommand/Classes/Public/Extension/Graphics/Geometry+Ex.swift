//
//  GeometryEx.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/21.
//

import CoreGraphics

fileprivate let auto = 10086

public extension WPSpace where Base == CGSize{
   /// 自动高度 只能用于判断
   static var custom : CGSize{
       return .init(width: auto, height: auto)
   }
    
    /// 是否是自定义
    var isCustom : Bool{
        return base.width == CGFloat(auto) &&
               base.height == CGFloat(auto)
    }
}

public extension WPSpace where Base == CGPoint{
    /// 自动高度 只能用于判断
    static var custom : CGPoint{
        return .init(x: auto, y: auto)
    }
    
    /// 是否是自定义
    var isCustom : Bool{
        return base.x == CGFloat(auto) &&
               base.y == CGFloat(auto)
    }
}

public extension WPSpace where Base == CGRect{
    /// 自动高度 只能用于判断
    static var custom : CGRect{
        return .init(x: auto, y: auto, width: auto, height: auto)
    }
    
    /// 是否是自定义
    var isCustom : Bool{
        return base.origin.y == CGFloat(auto) &&
               base.origin.x == CGFloat(auto) &&
               base.size.width == CGFloat(auto) &&
               base.size.height == CGFloat(auto)
    }
}
