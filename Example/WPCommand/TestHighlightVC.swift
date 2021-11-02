//
//  TestHighlightVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class TestHighlightVC: WPBaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
       
        let view = UIView()
        view.frame = .init(x: 110, y: 200, width: 100, height: 100)
        view.backgroundColor = .red
        self.view.addSubview(view)
        
        let yayer = CAShapeLayer.wp.shapefillet([.bottomLeft], radius: 30, in: view.bounds)
        yayer.fillColor = UIColor.init(0, 0, 0, 0.4).cgColor
        view.layer.addSublayer(yayer)
    }

    func layout(in bounds:CGRect)->CAShapeLayer{
        let path = UIBezierPath(rect: bounds)
        let x : CGFloat = bounds.size.width/2.0;
        let y : CGFloat = bounds.size.height/2.0
        let _ : CGFloat = CGFloat.minimum(x, y) * 0.8

        let cycle = UIBezierPath.wp.corner([.bottomLeft], radius: 20, in: bounds)
        path.append(cycle)
        let maskLayer = CAShapeLayer()

        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        maskLayer.fillColor = UIColor.init(0, 0, 0, 0.4).cgColor

        return maskLayer
    }
    
}
