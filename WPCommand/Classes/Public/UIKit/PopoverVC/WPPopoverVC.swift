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

    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    /// 显示一个弹出选择框
    /// - Parameters:
    ///   - view: 目标view
    ///   - items: 选项
    ///   - custom: 自定义
    public class func show(in view:UIView,
                           items:[Item],
                           custom:((WPPopoverVC)->Void)?=nil) {
        let vc = WPPopoverVC()
        vc.view.backgroundColor = .wp.initWith(76, 76, 76, 1)
        vc.preferredContentSize = .init(width: 128, height: items.count * 45)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = view
        vc.popoverPresentationController?.delegate = vc
        custom?(vc)
        
        UIViewController.wp.current?.present(vc, animated: true)
        
        items.forEach { item in
            let view = WPBlockView()
            view.item.titleImage = item.img
            view.item.title = item.text?.wp.attributed.foregroundColor(.white).complete()
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
    
    let contentView = UIStackView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        contentView.spacing = 0.5
        contentView.axis = .vertical
        contentView.distribution = .fillEqually
        contentView.backgroundColor = .wp.initWith("#F5F5F5")
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.bottom.equalToSuperview()
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
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
