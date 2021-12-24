//
//  TestHighlightVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class TestHighlightVC: WPBaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        var a: [Any] = ["", ""]
        assert(a.count >= 2,"断言")
        print(a)
    }
}

extension WPArraySpace {
    func obj() -> Any {
        base = ["", "", ""] as! Base
        return base
    }
}

public class WPArraySpace<Base> {
    /// 命名空间类
    public var base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

extension Array {
    public var test: WPArraySpace<Array<Element>> {
        get {
            return WPArraySpace(self)
        }
        set {}
    }

    public static var test: WPArraySpace<Array<Element>>.Type {
        get {
            return WPArraySpace<Self>.self
        }

        set {
        }
    }
}
