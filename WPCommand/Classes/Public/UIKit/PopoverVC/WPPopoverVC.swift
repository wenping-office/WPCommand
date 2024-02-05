//
//  WPWPPopoverVC.swift
//  Alamofire
//
//  Created by Wen on 2024/1/11.
//

import UIKit
import RxSwift

/// 弹出选择框
public class WPPopoverVC: UIViewController, UIPopoverPresentationControllerDelegate {

    static func checkPadding(arrowDirections:UIPopoverArrowDirection,sorceRect:CGRect,popoSize:CGSize,margin:UIEdgeInsets)->Bool{
        
        let safePadding:CGFloat = 20
        let maxSize = UIScreen.main.bounds.size

        switch arrowDirections {
        case .up:
            if maxSize.height - sorceRect.maxY < popoSize.height + margin.bottom + safePadding{
                return true
            }
        case .down:
            if sorceRect.minY < popoSize.height + margin.top + safePadding{
                return true
            }
        case .right:
            if maxSize.width - sorceRect.maxX < popoSize.width + margin.right + safePadding{
                return true
            }
        case .left:
            if sorceRect.minX < popoSize.width + margin.left + safePadding{
                return true
            }
        default:
            break
        }
        return false
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    var contentEdge:UIEdgeInsets = .zero{
        didSet{
            contentView.snp.makeConstraints { make in
                make.top.equalTo(finalEdge.top)
                make.left.equalTo(finalEdge.left)
                make.right.equalTo(-finalEdge.right)
                make.bottom.equalTo(-finalEdge.bottom)
            }
        }
    }
    
    var finalEdge:UIEdgeInsets{
        return UIEdgeInsets.init(top: contentEdge.top + arrowEdge.top, left: contentEdge.left + arrowEdge.left, bottom: contentEdge.bottom + arrowEdge.bottom, right: contentEdge.right + arrowEdge.right)
    }
    
    
    var arrowEdge:UIEdgeInsets {
        switch popoverPresentationController?.permittedArrowDirections ?? .any {
        case .up:
            return .init(12, 0, 0, 0)
        case .left:
            return .init(0, 12, 0, 0)
        case .down:
            return .init(0, 0, 12, 0)
        case .right:
            return .init(0, 0, 0, 12)
        default:
            return .init(12)
        }
    }
    
    /// 显示一个弹出选择框
    /// - Parameters:
    ///   - view: 目标view
    ///   - items: 选项
    ///   - custom: 自定义
    ///   - arrowDirections: 箭头方向
    ///   - margin: 边距
    ///   - exceedingly: 如果弹不出来的异常
    ///   - passthroughViews: 支持交互的视图
    public class func show(in view:UIView,
                           items:[Item],
                           arrowDirections:UIPopoverArrowDirection = .up,
                           margin:UIEdgeInsets = .init(5),
                           passthroughViews:[UIView] = [],
                           exceedingly:(()->Void)? = nil,
                           custom:((WPPopoverVC)->Void)?=nil) {
        let vc = WPPopoverVC()
        vc.popoverPresentationController?.sourceView = view
        vc.popoverPresentationController?.delegate = vc
        vc.popoverPresentationController?.permittedArrowDirections = arrowDirections
        vc.popoverPresentationController?.popoverLayoutMargins = margin
        
        vc.contentEdge = .init(0, 10, 0, 10)
        
        let popoSize:CGSize = .init(width: 128, height: items.count * 45 + Int(vc.arrowEdge.top))
        vc.preferredContentSize = popoSize

        if WPPopoverVC.checkPadding(arrowDirections: arrowDirections,sorceRect: view.wp.frameInMainWidow, popoSize: popoSize,margin: margin){
            exceedingly?()
        }
        custom?(vc)
        
        UIViewController.wp.current?.present(vc, animated: true)
        
        items.forEach { item in
            let view = WPBlockView()
            view.item.titleImage = item.img
            view.item.title = item.text?.wp.attributed.foregroundColor(.white).value()
            view.topStackView.alignment = .center
            view.backgroundColor = .wp.initWith(76, 76, 76, 1)
            view.reset()
            view.wp.tapGesture.throttle(.milliseconds(500), scheduler: MainScheduler.instance).bind(onNext: { _ in
                vc.dismiss(animated: true,completion: {
                    item.action?()
                })
            }).disposed(by: view.wp.disposeBag)
            vc.contentView.addArrangedSubview(view)
        }
    }
    
    /// 显示一个toast
    /// - Parameters:
    ///   - view: 目标视图
    ///   - text: 文本
    ///   - maxWidth: 最大宽度
    ///   - arrowDirections: 箭头方向
    ///   - custom: 自定义
    ///   - margin: 边距
    ///   - passthroughViews: 支持交互的视图
    ///   - exceedingly: rack小于弹窗执行
    public class func show(in view:UIView,
                           text:NSAttributedString?,
                           maxWidth:CGFloat = 200,
                           arrowDirections:UIPopoverArrowDirection = .up,
                           margin:UIEdgeInsets = .init(5),
                           passthroughViews:[UIView] = [],
                           exceedingly:(()->Void)? = nil,
                           custom:((WPPopoverVC)->Void)?=nil) {
        let vc = WPPopoverVC()
        vc.popoverPresentationController?.sourceView = view
        vc.popoverPresentationController?.delegate = vc
        vc.popoverPresentationController?.permittedArrowDirections = arrowDirections
        vc.popoverPresentationController?.popoverLayoutMargins = margin
        vc.popoverPresentationController?.passthroughViews = passthroughViews
        if arrowDirections == .any {
            vc.contentEdge = .zero
        }else{
            vc.contentEdge = .init(10)
        }
        
        let height = (text?.wp.height(maxWidth: maxWidth - vc.contentEdge.left - vc.contentEdge.right) ?? 0) + 1
        let popoSize:CGSize = .init(width: maxWidth + vc.finalEdge.left + vc.finalEdge.right, height: height + vc.finalEdge.top + vc.finalEdge.bottom)
        vc.preferredContentSize = popoSize

        if WPPopoverVC.checkPadding(arrowDirections: arrowDirections,sorceRect: view.wp.frameInMainWidow, popoSize: popoSize,margin: margin){
            exceedingly?()
        }

        custom?(vc)
        
        UIViewController.wp.current?.present(vc, animated: true)
        
        let label = UILabel()
        label.attributedText = text
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        vc.contentView.backgroundColor = .clear
        vc.contentView.addArrangedSubview(label)
        label.snp.makeConstraints { make in
            make.width.equalTo(maxWidth)
        }
    }
    
    let contentView = UIStackView().wp.spacing(0.5).axis(.vertical).distribution(.fillEqually).backgroundColor(.wp.initWith("#F5F5F5")).value()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(contentView)
    }
    
    init(){
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .wp.initWith(76, 76, 76, 1)
        modalPresentationStyle = .popover
//        popoverPresentationController?.popoverBackgroundViewClass = PopoverBackgroundView.self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension WPPopoverVC{
    
    struct Item {
        var img:UIImage?
        var text:String?
        var action:(()->Void)?
       
       public init(img: UIImage? = nil,
                   text: String?,
                   action: ( () -> Void)? = nil) {
           self.img = img
           self.text = text
           self.action = action
       }
    }
}


extension WPPopoverVC{

    class PopoverBackgroundView: UIPopoverBackgroundView {
        override var arrowDirection: UIPopoverArrowDirection{
            set{
                super.arrowDirection = newValue
            }
            get{
                return super.arrowDirection
            }
        }
        
        override var arrowOffset: CGFloat{
            set{
                super.arrowOffset = newValue
            }
            get{
                return super.arrowOffset
            }
        }

        override class func arrowBase() -> CGFloat {
            return super.arrowBase()
        }
        
        override class func arrowHeight() -> CGFloat {
            return super.arrowHeight()
        }
        
        override class func contentViewInsets() -> UIEdgeInsets {
            
            return super.contentViewInsets()
        }

        override class var wantsDefaultContentAppearance: Bool{
            return false
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = .wp.random
            layer.masksToBounds = true
            layer.shadowColor = UIColor.clear.cgColor
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
