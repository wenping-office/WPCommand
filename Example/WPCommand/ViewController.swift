//
//  ViewController.swift
//  WPCommand
//
//  Created by Developer on 07/16/2021.
//  Copyright (c) 2021 Developer. All rights reserved.
//

import UIKit
import WPCommand

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let subview = UIView(frame: .init(x: 0, y: 50, width: 50, height: 50))
        let lView = UIView(frame: .init(x: 0, y: 20, width: 20, height: 20))
        subview.addSubview(lView)
        
        view.addSubview(subview)
        lView.backgroundColor = .wp_random
        subview.backgroundColor = .wp_random
        
       let ob = lView.convert(lView.frame, to: self.view)

        print(lView.wp_frameInWidow)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

class item: WPTableItem {
    
}
