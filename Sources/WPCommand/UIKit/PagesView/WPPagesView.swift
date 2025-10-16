//
//  WPPagesView.swift
//  Alamofire
//
//  Created by Wen on 2024/1/11.
//

import UIKit

/// 分页标签
open class WPPagesView<pageView:UIView>: WPBaseView {

    public let stackView = UIStackView()
    
    /// 总page
    public var totalPage:Int = 0{
        didSet{
            stackView.arrangedSubviews.forEach { view in
                view.removeFromSuperview()
            }
            var index = 0
            while index < totalPage {
                let view = pageView()
                view.snp.makeConstraints { make in
                    make.size.equalTo(viewSize)
                }
                view.layer.cornerRadius = itemRadius
                view.clipsToBounds = true
                stackView.addArrangedSubview(view)
                index += 1
            }
                
        }
    }
    
    /// 当前选中索引
    public var indexPage:Int?{
        var viewIndex = 0
        var index : Int?
        stackView.arrangedSubviews.forEach { view in
            if view.tag == 1{
                index = viewIndex
            }
            viewIndex += 1
        }
        
        return index
    }
    
    /// page大小
    let viewSize:CGSize
    /// page默认颜色
    let normalColor:UIColor
    /// page选中颜色
    let selectedColor:UIColor
    /// page圆角
    let itemRadius:CGFloat
    
    
    /// 初始化一个page试图
    /// - Parameters:
    ///   - normalColor: 默认颜色
    ///   - selectedColor: 选中颜色
    ///   - viewSize: page大小
    ///   - spacing: 间距
    ///   - itemRadius: 圆角
   public init(normalColor:UIColor,
               selectedColor:UIColor,
               viewSize:CGSize,
               spacing:CGFloat = 5,
               itemRadius:CGFloat = 0) {
        self.viewSize = viewSize
        self.normalColor = normalColor
        self.selectedColor = selectedColor
        self.itemRadius = itemRadius
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.spacing = spacing
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 选中一个page
    /// - Parameter pageIndex: 索引
   public func set(_ pageIndex:Int){
        stackView.arrangedSubviews.forEach { view in
            view.tag = 0
            view.backgroundColor = normalColor
        }

       stackView.arrangedSubviews.wp.get(pageIndex)?.tag = 1
       stackView.arrangedSubviews.wp.get(pageIndex)?.backgroundColor = selectedColor
    }
}

