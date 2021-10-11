//
//  WPDateProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/27.
//

import UIKit

/// 日期协议
 protocol WPDateProtocol{
    /// 日
    var wp_day : TimeInterval{ get }
    
    /// 时
    var wp_hour : TimeInterval{ get }
    
    /// 分
    var wp_minute : TimeInterval{ get }
    
    /// 秒
    var wp_second : TimeInterval{ get }
}

public extension Int:   WPDateProtocol {
    
     var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
     var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
     var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
     var wp_second: TimeInterval {
        return TimeInterval(self)
    }
}

public extension Int32: WPDateProtocol {
     var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
     var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
     var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
     var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
public extension Int64: WPDateProtocol {
     var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
     var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
     var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
     var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
public extension UInt:  WPDateProtocol {
     var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
     var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
     var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
     var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}

public extension UInt32: WPDateProtocol {
     var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
     var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
     var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
     var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
public extension UInt64: WPDateProtocol {
     var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
     var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
     var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
     var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
public extension Double: WPDateProtocol {
     var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
     var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
     var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
     var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
public extension CGFloat: WPDateProtocol {
     var wp_day: TimeInterval {
        return TimeInterval(60 * 60 * 24 * self)
    }
    
     var wp_hour: TimeInterval {
        return TimeInterval(60 * 60 * self)
    }
    
     var wp_minute: TimeInterval {
        return TimeInterval(60 * self)
    }
    
     var wp_second: TimeInterval {
        return TimeInterval(self)
    }
    
}
