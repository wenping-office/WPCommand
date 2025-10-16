//
//  Const.swift
//  Alamofire
//
//  Created by Wen on 2024/1/16.
//

import UIKit

public extension UIEdgeInsets {
    init(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }

    init(_ value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    init(_ top: CGFloat, _ bottom: CGFloat) {
        self.init(top: top, left: 0, bottom: bottom, right: 0)
    }
    
    var horizontal: CGFloat {
        return self.left + self.right
    }
    
    var vertical: CGFloat {
        return self.top + self.bottom
    }
}
