//
//  UITapGestureRecognizer+Ex.swift
//  WPCommand
//
//  Created by tmb on 2026/8/5.
//

import UIKit
import ObjectiveC

private final class GestureActionTarget {

    let action: (UITapGestureRecognizer) -> Void

    init(action: @escaping (UITapGestureRecognizer) -> Void) {
        self.action = action
    }

    @objc func invoke(_ gesture: UITapGestureRecognizer) {
        action(gesture)
    }
}


private var tapActionTargetKey: UInt8 = 0


extension UITapGestureRecognizer {

    convenience init(action: @escaping (UITapGestureRecognizer) -> Void) {

        let target = GestureActionTarget(action: action)

        self.init(
            target: target,
            action: #selector(GestureActionTarget.invoke(_:))
        )

        // 保证 target 生命周期和手势一致
        objc_setAssociatedObject(
            self,
            &tapActionTargetKey,
            target,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}

