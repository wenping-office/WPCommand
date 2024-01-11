//
//  WPGestureAdaptationProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/12/15.
//

import UIKit

private var WPGestureAdaptationHorizontalPointer = "WPGestureAdaptationHorizontalPointer"
private var WPGestureAdaptationVerticalPointer = "WPGestureAdaptationVerticalPointer"

public protocol WPGestureAdaptationProtocol: UIScrollView {
    /// 是否开启水平手势适配
    var horizontalAdaptation : Bool{ get set }
    
//    /// 是否开启垂直手势适配
//    var verticalAdaptation : Bool{ get set }
}

public extension WPGestureAdaptationProtocol{
    var horizontalAdaptation : Bool{
        get {
            var resualt : Bool? = WPRunTime.get(self, withUnsafePointer(to: &WPGestureAdaptationHorizontalPointer, {$0}))
            if resualt == nil {
                resualt = false
                horizontalAdaptation = false
            }
            return resualt!
        }
        set {
            return WPRunTime.set(self, newValue, withUnsafePointer(to: &WPGestureAdaptationHorizontalPointer, {$0}), .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
//    var verticalAdaptation : Bool{
//        get {
//            var resualt : Bool? = WPRunTime.get(self, &WPGestureAdaptationVerticalPointer)
//            if resualt == nil {
//                resualt = false
//                verticalAdaptation = false
//            }
//            return resualt!
//        }
//        set {
//            return WPRunTime.set(self, newValue, &WPGestureAdaptationVerticalPointer, .OBJC_ASSOCIATION_ASSIGN)
//        }
//    }
    
    
    func gestureBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGestureClass = NSClassFromString("UIScrollViewPanGestureRecognizer"), gestureRecognizer.isMember(of: panGestureClass) {
            let panGesture = gestureRecognizer as! UIPanGestureRecognizer

            if panGesture.wp.direction == .left && horizontalAdaptation {
                return contentOffset.x + bounds.size.width != contentSize.width
            }else if panGesture.wp.direction == .right && horizontalAdaptation{
                return contentOffset.x != 0
            }
        }

        return superview?.gestureRecognizerShouldBegin(gestureRecognizer) ?? false
    }
}
