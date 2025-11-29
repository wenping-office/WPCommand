//
//  PictureEditImageView.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

extension PictureEditImageView{
    enum Location:Int {
     case top = 10
     case left = 11
     case bottom = 12
     case right = 13
    }
}

extension PictureEditImageView{
    enum State {
       case normal
       case edit
    }
}

class PictureEditImageView: BaseView {

    let iconV = UIImageView()
    let label = UILabel().wp.padding { label in
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(28)
            make.top.bottom.equalToSuperview()
        }
    }
    lazy var stack = UIStackView(arrangedSubviews: [iconV,label])
    
    let borderView = UIView()

    /// 当前状态
    @Published var state = State.normal{
        didSet{
            updateState()
        }
    }
    
    var image:UIImage?{
        didSet{
            imageView.setImage(image)
            stack.isHidden = image != nil
            imageView.isHidden = image == nil
        }
    }

    let imageView = ZoomingImageViewTwo()

    private func updateState(){
        switch state {
        case .edit:
            borderView.isHidden = false
            sliderViews().forEach { view in
                view.isHidden = false
            }
            
        case .normal:
            borderView.isHidden = true
            
            sliderViews().forEach { view in
                view.isHidden = true
            }
        }
    }
    
    func sliderViews() -> [UIView] {
        return subviews.map({ $0.tag >= 10 ? $0 : nil}).compactMap({ $0 })
    }

    /// 隐藏某些滑块
    func hidenSliderViews(in locations:[Location]){
        sliderViews().forEach { view in
            let loc = Location.init(rawValue: view.tag)
            view.isHidden =  locations.contains(where: { $0 == loc})
        }
    }

    override func initSubView() {
        
        backgroundColor = .wp.random

        iconV.image = "edit_image_add".image()
        label.target.text = "addImage".localized()
        label.target.textColor = .white
        label.target.font = 14.font(.AmericanTypewriter)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.cornerRadius = 14
        
        stack.alignment = .center
        stack.spacing = 6
        stack.axis = .vertical
        
        let leftBtn = UIImageView()
        leftBtn.tag = Location.left.rawValue
        leftBtn.image = "edit_image_bar1".image()
        let rigthBtn = UIImageView()
        rigthBtn.tag = Location.right.rawValue
        rigthBtn.image = "edit_image_bar1".image()
        let topBtn = UIImageView()
        topBtn.tag = Location.top.rawValue
        topBtn.image = "edit_image_bar2".image()
        let bottomBtn = UIImageView()
        bottomBtn.tag = Location.bottom.rawValue
        bottomBtn.image = "edit_image_bar2".image()

        borderView.layer.borderWidth = 2
        borderView.layer.borderColor = UIColor.red.cgColor
        borderView.isUserInteractionEnabled = false
        borderView.isHidden = true

        addSubview(stack)
        addSubview(imageView)
        addSubview(borderView)
        addSubview(leftBtn)
        addSubview(topBtn)
        addSubview(bottomBtn)
        addSubview(rigthBtn)
        
        sliderViews().forEach { view in
            view.isHidden = true
        }
        
        leftBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(snp.left)
        }
        rigthBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(snp.right)
        }
        
        topBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(snp.top)
        }
        
        bottomBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(snp.bottom)
        }
    }
    
    override func initSubViewLayout() {

        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        borderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    
    }
}


extension String{
    func image() -> UIImage? {
        return UIImage(named: self)
    }
}
