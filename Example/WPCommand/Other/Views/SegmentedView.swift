//
//  SegmentedView.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/14.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import WPCommand

@available(iOS 13.0, *)
class SegmentedView: BaseView {
    
    let maxWidth:CGFloat
    let itemSpacing:CGFloat
    let animateBlockViewHeight:CGFloat
    let contentPadding:CGFloat

    let backImageView = UIImageView()

    let animateBlockView = UIView()
    
    private lazy var stackView = UIStackView()

    /// 当前选中索引
    @Published var currentIndex = 0

    let items:[Item]
    
    var viewItemTotalWidth:CGFloat{
        return maxWidth - (contentPadding * 2) - CGFloat(((CGFloat(items.count - 1)) * itemSpacing))
    }
    var viewItemWidth:CGFloat{
        return viewItemTotalWidth / CGFloat(items.count)
    }
    
   var willChangeIndex:((Int)->Void)?

    init(items:[Item],maxWidth:CGFloat,
         animateBlockViewHeight:CGFloat = 20,
         contentPadding:CGFloat = 5,
         itemSpacing:CGFloat = 8,
         willChangeIndex:((Int)->Void)? = nil ) {
        self.itemSpacing = itemSpacing
        self.items = items
        self.maxWidth = maxWidth
        self.animateBlockViewHeight = animateBlockViewHeight
        self.contentPadding = contentPadding
        super.init(frame: .zero)
        self.willChangeIndex = willChangeIndex
        animateBlockView.backgroundColor = .green

        for index in 0..<items.count {
            let btn = UIButton()
            btn.setTitle(items[index].title, for: .normal)
            btn.setTitleColor(items[index].normalColor, for: .normal)
            btn.titleLabel?.font = items[index].normalFont
            btn.tag = index

            btn.rx.controlEvent(.touchUpInside).bind(onNext: {[weak self] in
                self?.currentIndex = index
                self?.willChangeIndex?(index)
            }).disposed(by: btn.wp.disposeBag)

            stackView.addArrangedSubview(btn)
        }
        
        let btn = stackView.arrangedSubviews[0] as? UIButton
        btn?.setTitleColor(items[0].selectedColor, for: .normal)
        btn?.titleLabel?.font = items[0].selectedFont
    }

    func selecteItem(with index:Int){
        for index in 0..<self.stackView.arrangedSubviews.count{
            let btn = self.stackView.arrangedSubviews[index] as? UIButton
            btn?.setTitleColor(self.items[index].normalColor, for: .normal)
            btn?.titleLabel?.font = self.items[index].normalFont
        }
        let btn = self.stackView.arrangedSubviews[index] as? UIButton
        btn?.setTitleColor(self.items[index].selectedColor, for: .normal)
        btn?.titleLabel?.font = self.items[index].selectedFont
    }

    override func observeSubViewEvent() {

        $currentIndex.dropFirst().removeDuplicates().sink(receiveValue: {[weak self] value in

            guard let self else { return }

            let x = contentPadding + self.viewItemWidth * CGFloat(value) + CGFloat(CGFloat(value) * itemSpacing )

            self.animateBlockView.snp.updateConstraints { make in
                make.left.equalTo(x)
            }
            
            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                self?.layoutIfNeeded()
            },completion: { _ in
                for index in 0..<self.stackView.arrangedSubviews.count{
                    let btn = self.stackView.arrangedSubviews[index] as? UIButton
                    btn?.setTitleColor(self.items[index].normalColor, for: .normal)
                    btn?.titleLabel?.font = self.items[index].normalFont
                }
                let btn = self.stackView.arrangedSubviews[value] as? UIButton
                btn?.setTitleColor(self.items[value].selectedColor, for: .normal)
                btn?.titleLabel?.font = self.items[value].selectedFont
            })
        }).store(in: &wp.cancellables.set)
        
    }

    override func initSubView() {
        super.initSubView()

        stackView.spacing = itemSpacing
        stackView.distribution = .fillEqually

        addSubview(backImageView)
        addSubview(animateBlockView)
        addSubview(stackView)
        
    }
    
    override func initSubViewLayout() {
        super.initSubViewLayout()
        
        backImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.left.top.equalTo(contentPadding)
            make.bottom.right.equalTo(-contentPadding)
        }

        animateBlockView.snp.makeConstraints { make in
            make.height.equalTo(animateBlockViewHeight)
            make.left.equalTo(contentPadding)
            make.width.equalTo(viewItemWidth)
            make.centerY.equalToSuperview()
        }
    }
}

@available(iOS 13.0, *)
extension SegmentedView{
    struct Item {
        let title:String
        let normalColor:UIColor
        let selectedColor:UIColor
        let normalFont:UIFont
        let selectedFont:UIFont
    }
}

