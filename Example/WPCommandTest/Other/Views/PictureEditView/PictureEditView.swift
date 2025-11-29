//
//  PictureEditView.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand
import CombineCocoa
import Combine

extension PictureEditView{
    enum EditState {
      case normal
      case left
      case right
    }
}

class PictureEditView: BaseView {

    let leftView = PictureEditImageView()
    let rightView = PictureEditImageView()

    var direction = PictureEditOptionView.Direction.vertical
    
    var otherFrame:CGRect = .zero
    var targetFrame:CGRect = .zero
    
    /// 编辑状态
    @Published var editState = EditState.normal

    /// 当前编辑的视图
    weak var editView:PictureEditImageView?

    override func initSubView() {
        addSubview(leftView)
        addSubview(rightView)
    }
    
    override func observeSubViewEvent() {

        $editState.sink(receiveValue: {[weak self] state in
            self?.leftView.state = .normal
            self?.rightView.state = .normal
            switch state {
            case .left:
                self?.leftView.state = .edit
            case .right:
                self?.rightView.state = .edit
            default:
                break
            }
        }).store(in: &wp.cancellables.set)
        
        leftView.tapGesture().tapPublisher.filter({[weak self] _ in self?.leftView.image != nil}).sink(receiveValue: {[weak self] _ in
            guard let self else { return }
            
            if self.editState == .normal{
                self.bringSubviewToFront(self.leftView)
                self.editState = .left
                self.hienItems()
            }else{
                self.editState = .normal
            }

        }).store(in: &wp.cancellables.set)
        
        rightView.tapGesture().tapPublisher.filter({[weak self] _ in self?.rightView.image != nil}).sink(receiveValue: {[weak self] _ in
            guard let self else { return }
            
            if self.editState == .normal{
                self.bringSubviewToFront(self.rightView)
                self.editState = .right
                self.hienItems()
            }else{
                self.editState = .normal
            }
        }).store(in: &wp.cancellables.set)
        
        var leftPanSources:[AnyPublisher<UIPanGestureRecognizer,Never>] = []
        leftView.sliderViews().forEach { view in
            leftPanSources.append(view.panGesture().panPublisher)
        }
        
        Publishers.MergeMany(leftPanSources).sink(receiveValue: {[weak self] pan in
            guard let self else { return }
            // 获取手势相对于 superview 的偏移量
            let translation = pan.translation(in: superview)

            switch pan.state {
            case .began:
                self.otherFrame = self.rightView.frame
                self.targetFrame = self.leftView.frame
            case .changed:
                reset(translation: translation, location: .init(rawValue: pan.view!.tag)!,isLeft: true)
            default:
                break
            }

            // 重置偏移量，否则下一次计算会叠加
            pan.setTranslation(.zero, in: superview)
        }).store(in: &wp.cancellables.set)

        var rightPanSources:[AnyPublisher<UIPanGestureRecognizer,Never>] = []
        rightView.sliderViews().forEach { view in
            rightPanSources.append(view.panGesture().panPublisher)
        }
        
        Publishers.MergeMany(rightPanSources).sink(receiveValue: {[weak self] pan in
            guard let self else { return }
            // 获取手势相对于 superview 的偏移量
            let translation = pan.translation(in: superview)
            switch pan.state {
            case .began:
                self.otherFrame = self.leftView.frame
                self.targetFrame = self.rightView.frame
            default:
                break
            }
            reset(translation: translation, location: .init(rawValue: pan.view!.tag)!, isLeft: false)

            // 重置偏移量，否则下一次计算会叠加
            pan.setTranslation(.zero, in: superview)
        }).store(in: &wp.cancellables.set)
    }
    
    /// 设置拖拽偏移量
    /// - Parameters:
    ///   - translation: 拖拽距离
    ///   - location: 位置
    ///   - isLeft: 是否是左边视图
    func reset(translation:CGPoint,
               location:PictureEditImageView.Location,
               isLeft:Bool){
        
        let targetView = isLeft ? leftView : rightView
        let otherView = isLeft ? rightView : leftView
        
        let min:CGFloat = 100.0
        var targetValue:CGFloat = 0
        
        switch location {
        case .left:
            targetValue = targetView.wp_width - translation.x
        case .right:
            targetValue = targetView.wp_width + translation.x
        case .top:
            targetValue = targetView.wp_height - translation.y
        case .bottom:
            targetValue = targetView.wp_height + translation.y
        }

        if targetValue <= min{
            targetValue = min
        }

        switch location {
        case .left:
            if direction == .vertical{
                if isLeft{
                    let maxWidth = otherFrame.minX
                    
                    if targetValue > maxWidth{
                        targetValue = maxWidth
                    }
                    targetView.wp_width = targetValue
                    targetView.wp_x = otherView.wp_x - targetValue
                }else{ // 处理中间线
                    let maxWidth = wp_width - ( wp_width - targetFrame.maxX) - otherFrame.minX - min

                    if targetValue > maxWidth{
                        targetValue = maxWidth
                    }
                    targetView.wp_width = targetValue
                    targetView.wp_maxX = targetFrame.maxX
                    otherView.wp_width = targetView.wp_x - otherView.wp_x
                }
            }else{
                if targetValue > wp_width{
                    targetValue = wp_width
                }
                targetView.wp_width = targetValue
                targetView.wp_maxX = targetFrame.maxX
            }
        case .right:
           
            if direction == .vertical{
                if !isLeft{
                    let maxWidth = wp_width - otherView.wp_maxX
                    
                    if targetValue > maxWidth{
                        targetValue = maxWidth
                    }
                    targetView.wp_width = targetValue
                }else{
                    let maxWidth = wp_width - targetView.wp_x - (wp_width - otherView.wp_maxX) - min
                    if targetValue > maxWidth{
                        targetValue = maxWidth
                    }
                    targetView.wp_width = targetValue
                    otherView.wp_width = otherFrame.maxX - targetView.wp_maxX
                    otherView.wp_maxX = otherFrame.maxX
                }
            }else{
                if targetValue > wp_width{
                    targetValue = wp_width
                }
                targetView.wp_width = targetValue
            }
        case .top:
            if direction == .vertical{
                let maxHeight = wp_height
                
                if targetValue > maxHeight{
                    targetValue = maxHeight
                }
                
                targetView.wp_height = targetValue
                targetView.wp_maxY = targetFrame.maxY
            }else{
                if isLeft{
                    let maxHeight = otherView.wp_y
                    
                    if targetValue > maxHeight{
                        targetValue = maxHeight
                    }
                    targetView.wp_height = targetValue
                    targetView.wp_maxY = targetFrame.maxY
                }else{ // 处理中间线
                    let maxHeight = wp_height - otherView.wp_y - (wp_height - targetFrame.maxY) - min
                    if targetValue > maxHeight{
                        targetValue = maxHeight
                    }
                    targetView.wp_height = targetValue
                    targetView.wp_maxY = targetFrame.maxY
                    otherView.wp_height = wp_height - otherView.wp_y - (wp_height - targetFrame.maxY) - targetValue
                }
            }
        case .bottom:
            
            if direction == .vertical{
                let maxHeight = wp_height
                
                if targetValue > maxHeight{
                    targetValue = maxHeight
                }
                targetView.wp_height = targetValue
                targetView.wp_y = targetFrame.minY
            }else{
                if !isLeft{
                    let maxHeight = wp_height - otherView.wp_maxY
                    
                    if targetValue > maxHeight{
                        targetValue = maxHeight
                    }
                    targetView.wp_height = targetValue
                    targetView.wp_y = targetFrame.minY
                    
                }else{ // 处理中间线
                    let maxHeight = wp_height - targetView.wp_y - (wp_height - otherView.wp_maxY) - min
                    if targetValue > maxHeight{
                        targetValue = maxHeight
                    }
                    targetView.wp_height = targetValue
                    otherView.wp_height = wp_height - targetView.wp_y - (wp_height - otherView.wp_maxY) - targetValue
                    otherView.wp_maxY = otherFrame.maxY
                }
            }
        }
    }
    
    func setDirection(_ direction: PictureEditOptionView.Direction){
        self.direction = direction
        switch direction {
        case .vertical:
            leftView.wp_x = 0
            leftView.wp_y = 0
            leftView.wp_height = wp_height
            leftView.wp_width = wp_width * 0.5
            
            rightView.wp_x = leftView.wp_maxX
            rightView.wp_y = 0
            rightView.wp_width = wp_width * 0.5
            rightView.wp_height = wp_height

        case .horizontal:
            leftView.wp_x = 0
            leftView.wp_y = 0
            leftView.wp_height = wp_height * 0.5
            leftView.wp_width = wp_width
            
            rightView.wp_x = 0
            rightView.wp_y = leftView.wp_maxY
            rightView.wp_width = wp_width
            rightView.wp_height = wp_height * 0.5
        }
        
        self.hienItems()
    }
    
    func hienItems(){
        if editState == .left{
            if direction == .vertical{
                self.leftView.hidenSliderViews(in: [.left,.top,.bottom])
            }else{
                self.leftView.hidenSliderViews(in: [.left,.top,.right])
            }
        }
        
        if editState == .right {
            if direction == .vertical{
                self.rightView.hidenSliderViews(in: [.right,.top,.bottom])
            }else{
                self.rightView.hidenSliderViews(in: [.left,.bottom,.right])
            }
        }
    }
    
}

extension UIView{
    func tapGesture()->UITapGestureRecognizer{
        let tap = UITapGestureRecognizer()
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
        return tap
    }
    
    func doubleTapGesture() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer()
        addGestureRecognizer(tap)
        tap.numberOfTapsRequired = 2
        isUserInteractionEnabled = true
        return tap
    }
    
    func panGesture()-> UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer()
        isUserInteractionEnabled = true
        addGestureRecognizer(pan)
        return pan
    }

}
