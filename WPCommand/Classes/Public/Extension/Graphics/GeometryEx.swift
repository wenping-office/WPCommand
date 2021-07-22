//
//  GeometryEx.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/21.
//

import CoreGraphics

fileprivate let auto = 10086

public extension CGSize{
   /// 自动高度 只能用于判断
   static var wp_custom : CGSize{
       return .init(width: auto, height: auto)
   }
    
    /// 是否是自定义
    var wp_isCustom : Bool{
        return self.width == CGFloat(auto) &&
               self.height == CGFloat(auto)
    }
}

public extension CGPoint{
    /// 自动高度 只能用于判断
    static var wp_custom : CGPoint{
        return .init(x: auto, y: auto)
    }
    
    /// 是否是自定义
    var wp_isCustom : Bool{
        return self.x == CGFloat(auto) &&
               self.y == CGFloat(auto)
    }
}

public extension CGRect{
    /// 自动高度 只能用于判断
    static var wp_custom : CGRect{
        return .init(x: auto, y: auto, width: auto, height: auto)
    }
    
    /// 是否是自定义
    var wp_isCustom : Bool{
        return self.origin.y == CGFloat(auto) &&
               self.origin.x == CGFloat(auto) &&
               self.size.width == CGFloat(auto) &&
               self.size.height == CGFloat(auto)
    }
}
