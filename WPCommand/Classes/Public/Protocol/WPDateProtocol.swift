//
//  WPDateProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/27.
//

import UIKit

/// 日期协议
public protocol WPDateProtocol{
    /// 日
    var wp_day : TimeInterval{ get }
    
    /// 时
    var wp_hour : TimeInterval{ get }
    
    /// 分
    var wp_minute : TimeInterval{ get }
    
    /// 秒
    var wp_second : TimeInterval{ get }
}

extension Int:   WPDateProtocol {
    
    public var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
    public var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
    public var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
    public var wp_second: TimeInterval {
        return TimeInterval(self)
    }
}

extension Int32: WPDateProtocol {
    public var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
    public var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
    public var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
    public var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
extension Int64: WPDateProtocol {
    public var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
    public var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
    public var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
    public var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
extension UInt:  WPDateProtocol {
    public var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
    public var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
    public var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
    public var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}

extension UInt32: WPDateProtocol {
    public var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
    public var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
    public var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
    public var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
extension UInt64: WPDateProtocol {
    public var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
    public var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
    public var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
    public var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
extension Double: WPDateProtocol {
    public var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
    public var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
    public var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
    public var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
extension CGFloat: WPDateProtocol {
    public var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
    public var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
    public var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
    public var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
