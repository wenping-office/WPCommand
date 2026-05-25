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
            
            if let customView = customView{
                customView.snp.makeConstraints { make in
                    make.top.equalTo(finalEdge.top)
                    make.left.equalTo(finalEdge.left)
                    make.right.equalTo(-finalEdge.right)
                    make.bottom.equalTo(-finalEdge.bottom)
                }
            }else{
                contentView.snp.makeConstraints { make in
                    make.top.equalTo(finalEdge.top)
                    make.left.equalTo(finalEdge.left)
                    make.right.equalTo(-finalEdge.right)
                    make.bottom.equalTo(-finalEdge.bottom)
                }
            }
        }
    }
    
    var finalEdge:UIEdgeInsets{
        return UIEdgeInsets.init(top: contentEdge.top + arrowEdge.top, left: contentEdge.left + arrowEdge.left, bottom: contentEdge.bottom + arrowEdge.bottom, right: contentEdge.right + arrowEdge.right)
    }
    
    var arrowEdge:UIEdgeInsets {
        switch popoverPresentationController?.permittedArrowDirections ?? .any {
        case .up:
            return .init(top: 12, left: 0, bottom: 0, right: 0)
        case .left:
            return .init(top: 0, left: 12, bottom: 0, right: 0)
        case .down:
            return .init(top: 0, left: 0, bottom: 12, right: 0)
        case .right:
            return .init(top: 0, left: 0, bottom: 0, right: 12)
        default:
            return .init(top: 12, left: 12, bottom: 12, right: 12)
        }
    }
    
    /// 显示一个弹出选择框
    /// - Parameters:
    ///   - targetView: 目标view
    ///   - items: 选项
    ///   - custom: 自定义
    ///   - arrowDirections: 箭头方向
    ///   - margin: 边距
    ///   - exceedingly: 如果弹不出来的异常
    ///   - passthroughViews: 支持交互的视图
    public class func show(in targetView:UIView,
                           items:[Item],
                           arrowDirections:UIPopoverArrowDirection = .up,
                           margin:UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5),
                           passthroughViews:[UIView] = [],
                           exceedingly:(()->Void)? = nil,
                           custom:((WPPopoverVC)->Void)?=nil) {
        let vc = WPPopoverVC(customView: nil)
        vc.popoverPresentationController?.sourceView = targetView
        vc.popoverPresentationController?.delegate = vc
        vc.popoverPresentationController?.permittedArrowDirections = arrowDirections
        vc.popoverPresentationController?.popoverLayoutMargins = margin
        
        vc.contentEdge = .init(top: 0, left: 10, bottom: 0, right: 10)
        
        let popoSize:CGSize = .init(width: 128, height: items.count * 45 + Int(vc.arrowEdge.top))
        vc.preferredContentSize = popoSize

        if WPPopoverVC.checkPadding(arrowDirections: arrowDirections,sorceRect: targetView.wp.frameInMainWidow, popoSize: popoSize,margin: margin){
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
    ///   - targetView: 目标视图
    ///   - text: 文本
    ///   - maxWidth: 最大宽度
    ///   - arrowDirections: 箭头方向
    ///   - custom: 自定义
    ///   - margin: 边距
    ///   - passthroughViews: 支持交互的视图
    ///   - exceedingly: rack小于弹窗执行
    public class func show(in targetView:UIView,
                           text:NSAttributedString?,
                           maxWidth:CGFloat = 200,
                           arrowDirections:UIPopoverArrowDirection = .up,
                           margin:UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5),
                           passthroughViews:[UIView] = [],
                           exceedingly:(()->Void)? = nil,
                           custom:((WPPopoverVC)->Void)?=nil) {
        let vc = WPPopoverVC(customView: nil)
        vc.popoverPresentationController?.sourceView = targetView
        vc.popoverPresentationController?.delegate = vc
        vc.popoverPresentationController?.permittedArrowDirections = arrowDirections
        vc.popoverPresentationController?.popoverLayoutMargins = margin
        vc.popoverPresentationController?.passthroughViews = passthroughViews
        if arrowDirections == .any {
            vc.contentEdge = .zero
        }else{
            vc.contentEdge = .init(top: 10, left: 10, bottom: 10, right: 10)
        }
        
        let height = (text?.wp.height(maxWidth: maxWidth - vc.contentEdge.left - vc.contentEdge.right) ?? 0) + 1
        let popoSize:CGSize = .init(width: maxWidth + vc.finalEdge.left + vc.finalEdge.right, height: height + vc.finalEdge.top + vc.finalEdge.bottom)
        vc.preferredContentSize = popoSize

        if WPPopoverVC.checkPadding(arrowDirections: arrowDirections,sorceRect: targetView.wp.frameInMainWidow, popoSize: popoSize,margin: margin){
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
    
    /// 显示一个toast
    /// - Parameters:
    ///   - targetView: 目标视图
    ///   - arrowDirections: 箭头方向
    ///   - custom: 自定义
    ///   - margin: 边距
    ///   - passthroughViews: 支持交互的视图
    ///   - exceedingly: rack小于弹窗执行
    ///   - mainView: 自定义视图
    ///   - mainSize: 自定义视图大小
    public class func show(in targetView:UIView,
                           mainView:UIView,
                           mainSize:CGSize,
                           arrowDirections:UIPopoverArrowDirection = .up,
                           margin:UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5),
                           passthroughViews:[UIView] = [],
                           exceedingly:(()->Void)? = nil,
                           custom:((WPPopoverVC)->Void)?=nil) {
        let vc = WPPopoverVC(customView: mainView)
        vc.popoverPresentationController?.sourceView = targetView
        vc.popoverPresentationController?.delegate = vc
        vc.popoverPresentationController?.permittedArrowDirections = arrowDirections
        vc.popoverPresentationController?.popoverLayoutMargins = margin
        vc.popoverPresentationController?.passthroughViews = passthroughViews
        if arrowDirections == .any {
            vc.contentEdge = .zero
        }else{
            vc.contentEdge = .init(top: 10, left: 10, bottom: 10, right: 10)
        }

        let popoSize:CGSize = .init(width: mainSize.width + vc.finalEdge.left + vc.finalEdge.right, height: mainSize.height + vc.finalEdge.top + vc.finalEdge.bottom)
        vc.preferredContentSize = popoSize

        if WPPopoverVC.checkPadding(arrowDirections: arrowDirections,sorceRect: targetView.wp.frameInMainWidow, popoSize: popoSize,margin: margin){
            exceedingly?()
        }
        custom?(vc)
        
        UIViewController.wp.current?.present(vc, animated: true)
    }
    
    let contentView = UIStackView().wp.spacing(0.5).axis(.vertical).distribution(.fillEqually).backgroundColor(.wp.initWith("#F5F5F5")).value()
    
    let customView:UIView?

    public init(customView:UIView?) {
        self.customView = customView
        super.init(nibName: nil, bundle: nil)
        
        if let customView = customView{
            view.addSubview(customView)
        }else{
            view.addSubview(contentView)
        }
        
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


public extension WPBlockView {
    struct Item {
        public init() {}
        /// 标题
        public var title: NSAttributedString?
        /// 标题图片
        public var titleImage: UIImage?
        /// 描述
        public var describe: NSAttributedString?
        /// 描述图片
        public var describeImage: UIImage?
        /// 子描述
        public var subDescribe: NSAttributedString?
        /// 底部描述
        public var bottomDescribe: NSAttributedString?
    }
}

/// 静态视图 常用布局label封装
open class WPBlockView: WPBaseView {
    /// 标题
    public let titleLabel = UILabel().wp.textColor(.black).value()
    
    /// 标题图片
    public let titleImageView = UIImageView()
    
    /// 左边视图
    public lazy var leftStackView = UIStackView.wp
        .views([titleImageView, titleLabel])
        .alignment(.center)
        .spacing(6)
        .value()

    /// 描述
    public let desribeLabel = UILabel().wp
        .font(.systemFont(ofSize: 14))
        .textColor(.black)
        .numberOfLines(0)
        .textAlignment(.right)
        .value()

    /// 子描述
    public let subDesribeLabel = UILabel().wp
        .font(.systemFont(ofSize: 12))
        .textColor(.black)
        .numberOfLines(0)
        .textAlignment(.right)
        .value()
    
    /// 描述图片
    public let desribeImageView = UIImageView()
    
    /// 右边视图
    public lazy var rightTopView = UIStackView.wp
        .views([desribeLabel, desribeImageView])
        .spacing(4)
        .alignment(.center)
        .value()

    /// 占位图
    public let placeholderDesribeImageView = UIImageView().wp
        .isHidden(true)
        .padding(.zero, priority: .required)
    
    /// 右边子描述视图
    public lazy var rightBottomView = UIStackView.wp
        .views([subDesribeLabel, placeholderDesribeImageView])
        .spacing(4)
        .alignment(.center)
        .value()
    
    /// 右边视图
    public lazy var rightStackView = UIStackView.wp
        .views([rightTopView, rightBottomView])
        .spacing(4)
        .axis(.vertical)
        .alignment(.trailing)
        .value()
    
    /// 顶部视图
    public lazy var topStackView = UIStackView.wp
        .views([leftStackView, rightStackView])
        .spacing(10)
        .alignment(.top)
        .value()
    
    /// 底部视图
    public let bottomLabel = UILabel().wp
        .font(.systemFont(ofSize: 12))
        .textColor(.black)
        .numberOfLines(0)
        .value()

    /// 内容视图
    public lazy var contentStackView = UIStackView.wp
        .views([topStackView, bottomLabel])
        .axis(.vertical)
        .spacing(4).value()
    
    /// 数据模型
    public var item: Item = .init() {
        didSet {
            reset()
        }
    }
    
    /// 重置数据源
    public func reset() {
        titleLabel.attributedText = item.title
        desribeLabel.attributedText = item.describe
        subDesribeLabel.attributedText = item.subDescribe
        desribeImageView.image = item.describeImage
        placeholderDesribeImageView.target.image = item.describeImage
        titleImageView.image = item.titleImage
        titleImageView.isHidden = item.titleImage == nil
        subDesribeLabel.isHidden = (item.subDescribe?.length ?? 0) <= 0
        desribeLabel.isHidden = (item.describe?.length ?? 0) <= 0
        desribeImageView.isHidden = item.describeImage == nil
        placeholderDesribeImageView.isHidden = item.describeImage == nil || item.subDescribe?.length ?? 0 <= 0
        rightBottomView.isHidden = subDesribeLabel.isHidden
        titleLabel.isHidden = item.title?.length ?? 0 <= 0
        bottomLabel.attributedText = item.bottomDescribe
        bottomLabel.isHidden = item.bottomDescribe?.length ?? 0 <= 0

        leftStackView.isHidden = leftStackView.wp.subViewsAllHidden
        rightTopView.isHidden = rightTopView.wp.subViewsAllHidden
        rightBottomView.isHidden = rightBottomView.wp.subViewsAllHidden
        rightStackView.isHidden = rightStackView.wp.subViewsAllHidden
        topStackView.isHidden = topStackView.wp.subViewsAllHidden
         
        if desribeLabel.isHidden {
            titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        } else {
            titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
    }

    override open func initSubView() {
        super.initSubView()
        
        addSubview(contentStackView)
        
        subDesribeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        desribeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        desribeImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        desribeImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        placeholderDesribeImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        placeholderDesribeImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        titleImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
                
        bottomLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        bottomLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    override open func initSubViewLayout() {
        super.initSubViewLayout()
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

