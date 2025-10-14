//
//  WPHighlightViewProtocol.swift
//  WPCommand
//
//  Created by WenPing on 2021/10/21.
//

import UIKit
import RxCocoa
import RxSwift

private var wp_highlightMaskProtocolPointer = "wp_highlightMaskProtocolPointer"

public enum TCHighlightMaskFillStyle{
    case topBottomToFull
    
    case leftRightToFull
}

public enum WPHighlightViewType{
    case center
    case top
    case bottom
    case left
    case right
}

/// 高亮蒙层协议、实现协议后拥有高亮显示方法
public protocol WPHighlightMaskProtocol: UIView {
    
    /// 是否正在显示高亮
    var isShowHighlight:Bool{ get set}
    /// 高亮顶部视图
    func highlightTopView() -> WPHighlightViewProtocol
    /// 高亮底部视图
    func highlightBottomView() -> WPHighlightViewProtocol
    /// 高亮左边视图
    func highlightLeftView() -> WPHighlightViewProtocol
    /// 高亮右边视图
    func highlightRightView() -> WPHighlightViewProtocol
    /// 高亮中心视图
    func highlightCenterView() -> WPHighlightViewProtocol
}

public extension WPHighlightMaskProtocol {
    
    var isShowHighlight: Bool {
        get {
            let state : Bool = WPRunTime.get(self, withUnsafePointer(to: &wp_highlightMaskProtocolPointer, {$0})) ?? false
            return state
        }
        set {
            return WPRunTime.set(self, newValue, withUnsafePointer(to: &wp_highlightMaskProtocolPointer, {$0}), .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// 高亮顶部视图
    func highlightTopView() -> WPHighlightViewProtocol {
        return WPHighlighMaskView()
    }

    /// 高亮底部视图
    func highlightBottomView() -> WPHighlightViewProtocol {
        return WPHighlighMaskView()
    }

    /// 高亮左边视图
    func highlightLeftView() -> WPHighlightViewProtocol {
        return WPHighlighMaskView()
    }

    /// 高亮右边视图
    func highlightRightView() -> WPHighlightViewProtocol {
        return WPHighlighMaskView()
    }

    /// 高亮中心视图
    func highlightCenterView() -> WPHighlightViewProtocol {
        return WPHighlighMaskCenterView()
    }

    /// 显示高亮到某个视图
    /// - Parameter view: 高亮添加到的视图 注：view的frame必须稳定以后才可以调用、否则有可能显示位置不准,并且view必须是self的底层，看起来要比view一般是widow或者view的superView
    /// - Parameter mode: 填充模式
    /// - Parameter contentInset: 内容边距
    /// - Parameter cornerRadius: 圆角
    /// - Parameter touch: 点击事件
    /// - Parameter color: 蒙层颜色
    /// - Parameter viewSort: 视图的排序规则，如果有重复的类型会重复添加、如果缺少一个类型将不会添加对应视图
    func showHighlight(to view: UIView,
                       mode:TCHighlightMaskFillStyle = .topBottomToFull,
                       contentInset:UIEdgeInsets = .zero,
                       cornerRadius:CGFloat = 0,
                       touch: ((WPHighlightViewProtocol) -> Void)? = nil,
                       color: UIColor = .wp.initWith(0, 0, 0, 0.4),
                       viewSort:[WPHighlightViewType] = [.bottom,.top,.center,.left,.right]){
        removeHighlight(of: view)

        let keyView = view
        let keyViewFrame: CGRect = convert(bounds, to: keyView)

        let topView = highlightTopView()
        let bottomView = highlightBottomView()
        let leftView = highlightLeftView()
        let rightView = highlightRightView()
        let centerView = highlightCenterView()

        let centerTapGesture = UITapGestureRecognizer()
        let topTapGesture = UITapGestureRecognizer()
        let bottomTapGesture = UITapGestureRecognizer()
        let leftTapGesture = UITapGestureRecognizer()
        let rightTapGesture = UITapGestureRecognizer()
        topView.addGestureRecognizer(topTapGesture)
        bottomView.addGestureRecognizer(bottomTapGesture)
        leftView.addGestureRecognizer(leftTapGesture)
        rightView.addGestureRecognizer(rightTapGesture)
        centerView.addGestureRecognizer(centerTapGesture)
        topTapGesture.rx.event.bind(onNext: { gesture in
            topView.highlighMaskTouch(tapGesture: gesture, targetView: topView)
            touch?(topView)
        }).disposed(by: (topView as UIView).wp.disposeBag)
        bottomTapGesture.rx.event.bind(onNext: { gesture in
            bottomView.highlighMaskTouch(tapGesture: gesture, targetView: bottomView)
            touch?(bottomView)
        }).disposed(by: (topView as UIView).wp.disposeBag)
        leftTapGesture.rx.event.bind(onNext: { gesture in
            leftView.highlighMaskTouch(tapGesture: gesture, targetView: leftView)
            touch?(leftView)
        }).disposed(by: (topView as UIView).wp.disposeBag)
        rightTapGesture.rx.event.bind(onNext: { gesture in
            rightView.highlighMaskTouch(tapGesture: gesture, targetView: rightView)
            touch?(rightView)
        }).disposed(by: (topView as UIView).wp.disposeBag)

        topView.backgroundColor = color
        bottomView.backgroundColor = color
        leftView.backgroundColor = color
        rightView.backgroundColor = color
        topView.highlighMaskDidSet(color: color, targetView: topView)
        bottomView.highlighMaskDidSet(color: color, targetView: bottomView)
        leftView.highlighMaskDidSet(color: color, targetView: leftView)
        rightView.highlighMaskDidSet(color: color, targetView: rightView)
        centerView.highlighMaskDidSet(color: color, targetView: centerView)

        keyView.addSubview(topView)
        keyView.addSubview(bottomView)
        keyView.addSubview(leftView)
        keyView.addSubview(rightView)
        superview?.insertSubview(centerView, aboveSubview: self)

        if mode == .topBottomToFull{
            topView.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(keyViewFrame.minY + contentInset.top)
            }

            bottomView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(keyViewFrame.maxY - contentInset.bottom)
            }

            leftView.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.top.equalTo(topView.snp.bottom)
                make.width.equalTo(keyViewFrame.minX + contentInset.left)
                make.bottom.equalTo(bottomView.snp.top)
            }

            rightView.snp.makeConstraints { make in
                make.top.bottom.equalTo(leftView)
                make.right.equalToSuperview()
                make.left.equalTo(keyViewFrame.maxX - contentInset.right)
            }
        }else{
            leftView.snp.makeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.width.equalTo(keyViewFrame.minX + contentInset.left)
            }

            rightView.snp.makeConstraints { make in
                make.right.top.bottom.equalToSuperview()
                make.left.equalTo(keyViewFrame.maxX - contentInset.right)
            }
            
            topView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalTo(leftView.snp.right)
                make.right.equalTo(rightView.snp.left)
                make.height.equalTo(keyViewFrame.minY + contentInset.top)
            }

            bottomView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(keyViewFrame.maxY - contentInset.bottom)
                make.left.equalTo(leftView.snp.right)
                make.right.equalTo(rightView.snp.left)
            }
        }

        centerView.frame = .init(x: frame.origin.x + contentInset.left,
                                 y: frame.origin.y + contentInset.top,
                                 width: frame.size.width - contentInset.left - contentInset.right,
                                 height: frame.size.height - contentInset.top - contentInset.bottom)
        
        if layer.cornerRadius != 0 || cornerRadius != 0 {
            let layer = CAShapeLayer.wp.shapefillet([.allCorners], radius: cornerRadius != 0 ? cornerRadius : layer.cornerRadius, in: centerView.bounds)
            layer.fillColor = color.cgColor
            centerView.layer.addSublayer(layer)
        }
        
        isShowHighlight = true
    }

    /// 从某个视图移除高亮视图
    func removeHighlight(of view: UIView,
                         completion: ((WPHighlightMaskProtocol) -> Void)? = nil)
    {
        isShowHighlight = false
        let keyView = view
        keyView.subviews.forEach { elmt in
            let highView = elmt as? WPHighlightViewProtocol
            highView?.removeFromSuperview()
        }

        superview?.subviews.forEach { elmt in
            let highView = elmt as? WPHighlightViewProtocol
            highView?.removeFromSuperview()
        }

        completion?(self)
    }
}

/// 高亮视图协议 实现协议后会返回高亮时创建的视图
public protocol WPHighlightViewProtocol: UIView {
    /// 蒙层被点击了
    func highlighMaskTouch(tapGesture: UITapGestureRecognizer, targetView: WPHighlightViewProtocol)
    /// 设置高亮时的颜色
    func highlighMaskDidSet(color: UIColor, targetView: WPHighlightViewProtocol)
}

public extension WPHighlightViewProtocol {
    /// 蒙层被点击了
    func highlighMaskTouch(tapGesture: UITapGestureRecognizer, targetView: WPHighlightViewProtocol) {}
    /// 设置高亮时的颜色
    func highlighMaskDidSet(color: UIColor, targetView: WPHighlightViewProtocol) {}
}

/// 高亮蒙层视图内部使用
class WPHighlighMaskView: UIView, WPHighlightViewProtocol {}
/// 高亮蒙层视图内部使用
class WPHighlighMaskCenterView: UIView, WPHighlightViewProtocol {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
}

public extension WPSpace where Base:UIView{
    /// 移除所有蒙层视图
    func removeAllWPHighlightView() {
        for subview in base.subviews.reversed() {
            if subview is WPHighlightViewProtocol {
                subview.removeFromSuperview()
            } else {
                subview.wp.removeAllWPHighlightView()
            }
        }
    }
}



//
//public extension WPSpace where Base:WPHighlightMaskProtocol{
//    
//    /// 显示高亮到某个视图 自动绑定frame
//    /// - Parameter view: 高亮添加到的视图
//    /// - Parameter mode: 填充模式
//    /// - Parameter contentInset: 内容边距
//    /// - Parameter cornerRadius: 圆角
//    /// - Parameter touch: 点击事件
//    /// - Parameter color: 蒙层颜色
//    func showHighlight(to view: UIView,
//                       mode:TCHighlightMaskFillStyle = .topBottomToFull,
//                       contentInset:UIEdgeInsets = .zero,
//                       cornerRadius:CGFloat = 0,
//                       touch: ((WPHighlightViewProtocol) -> Void)? = nil,
//                       color: UIColor = .wp.initWith(0, 0, 0, 0.4)){
//
//        weak var v = base
//        v?.showHighlight(to: view,mode: mode,contentInset: contentInset,cornerRadius: cornerRadius,touch: touch,color: color)
//
//        view.wp.layoutSubViewsMethod.map({
//            return base.frame
//        }).bind(onNext: { value in
//            print(value,"---11")
//            v?.showHighlight(to: view,mode: mode,contentInset: contentInset,cornerRadius: cornerRadius,touch: touch,color: color)
//        }).disposed(by: base.wp_isRemoveAutoHighlightMaskBag)
////
////
////        base.rx.observe(CGRect.self, "frame")
////            .map { $0 ?? .zero }.bind(onNext: { value in
////                
////                
////                print(value,"---")
////
////                v?.showHighlight(to: view,mode: mode,contentInset: contentInset,cornerRadius: cornerRadius,touch: touch,color: color)
////            }).disposed(by: base.wp_isRemoveAutoHighlightMaskBag)
//
//        
//
//         Observable.merge(
//                    view.rx.observe(CGRect.self, "frame").map { $0 ?? .zero },
//                    view.rx.observe(CGRect.self, "bounds").map { $0 ?? .zero },
//                    view.rx.observe(CGPoint.self, "center").map { _ in base.frame }
//        )
//         .distinctUntilChanged().bind(onNext: { frame in
//             print("最新frame",frame)
//             v?.showHighlight(to: view,mode: mode,contentInset: contentInset,cornerRadius: cornerRadius,touch: touch,color: color)
//         }).disposed(by: base.wp_isRemoveAutoHighlightMaskBag)
//    }
//    
//    /// 从某个视图移除高亮
//    /// - Parameters:
//    ///   - view: 视图
//    ///   - completion: 结果
//    func removeHighlight(of view: UIView,
//                         completion: ((WPHighlightMaskProtocol) -> Void)? = nil){
//        base.wp_isRemoveAutoHighlightMaskBag = DisposeBag()
//        base.removeHighlight(of: view,completion: completion)
//    }
//}
//
//private var wp_isRemoveAutoHighlightMaskPointer = "wp_isRemoveAutoHighlightMaskPointer"
//
//
//fileprivate extension UIView {
//
//    /// 是否删除高亮bag
//    var wp_isRemoveAutoHighlightMaskBag: DisposeBag {
//        set {
//            WPRunTime.set(self, newValue, withUnsafePointer(to: &wp_isRemoveAutoHighlightMaskPointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        get {
//            guard let disposeBag: DisposeBag = WPRunTime.get(self, withUnsafePointer(to: &wp_isRemoveAutoHighlightMaskPointer, {$0})) else {
//                let bag = DisposeBag()
//                return bag
//            }
//            return disposeBag
//        }
//    }
//}
