//
//  CircularProgressView.swift
//  WPCommand_Example
//
//  Created by 1234 on 2024/12/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WPCommand

class CircularProgressToastView: BaseView {
    
    let progressView = CircularProgressView(maxWidth: 24)

    override func initSubView() {
        super.initSubView()
        addSubview(progressView)
        wp.backgroundColor(.black.withAlphaComponent(0.6)).cornerRadius(8).clipsToBounds(true)
    }
    
    override func initSubViewLayout() {
        super.initSubViewLayout()
        
        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.top.equalTo(10)
            make.right.bottom.equalTo(-10)
        }
    }
}

class CircularProgressView: BaseView {
    
    let maxWidth:CGFloat
    
    var progress: CGFloat = 0.0{
        didSet{
            shapeLayer.strokeEnd = progress
        }
    }
    
    var isLoop = false
    
    private var shapeLayer: CAShapeLayer!
    private var backLayer: CAShapeLayer!
    private var timeBag = DisposeBag()
    
    init(maxWidth: CGFloat,isShowBack:Bool = true) {
        self.maxWidth = maxWidth
        super.init(frame: .zero)
        
        snp.makeConstraints { make in
            make.size.equalTo(maxWidth)
        }
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: maxWidth * 0.5, y: maxWidth * 0.5),
                                      radius: maxWidth * 0.5,
                                      startAngle: -CGFloat.pi / 2,
                                      endAngle: CGFloat.pi * 3 / 2,
                                      clockwise: true)
        if isShowBack {
            backLayer = CAShapeLayer()
            backLayer.path = circlePath.cgPath
            backLayer.strokeColor = UIColor.white.withAlphaComponent(0.4).cgColor
            backLayer.cornerRadius = 2.5
            backLayer.fillColor = nil
            backLayer.lineWidth = 2.5
            backLayer.strokeEnd = 1
            layer.addSublayer(backLayer)
        }
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.cornerRadius = 2.5
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 2.5
        shapeLayer.strokeEnd = 0
        
        layer.addSublayer(shapeLayer)
    }

    func startAnimation(_ loop:Bool) {
        self.isLoop = loop

        start()
    }
    
    private func start(){
        shapeLayer.isHidden = false
        Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.instance).bind(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.progress += 0.1
            if self.isLoop {
                if self.progress >= 1{
                    self.shapeLayer.isHidden = true
                    progress = 0.0
                    self.timeBag = DisposeBag()
                    
                    WPGCD.main_asyncAfter(.now() + 0.2, task: {[weak self] in
                        self?.start()
                    })
                }
            }else{
                if self.progress >= 1{
                    self.timeBag = DisposeBag()
                }
            }
        }).disposed(by: timeBag)
    }
    
    func stopAnimation(){
        isLoop = false
        timeBag = DisposeBag()
    }
}
