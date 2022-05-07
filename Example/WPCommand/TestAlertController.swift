//
//  TestAlertController.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/7/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

class TestAlertController: WPBaseVC {

    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = .init(title: "返回", style: .done, target: self, action: #selector(popVC))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let alert = TestAlert()
        alert.wp.show()
        
        WPGCD.main_asyncAfter(.now() + 3, task: {
            self.showAlert(alert: alert)
        })
    }
    
    @objc func popVC(){
        navigationController?.popViewController(animated: true)
    }

    func showAlert(alert: WPAlertProtocol){
        
        let vc = WPBaseVC()
        navigationController?.pushViewController(vc, animated: true)

    }
}

class TestAlert: WPBaseView,WPAlertProtocol {
    
    let contentView = UILabel()
    
    override func initSubView() {
        
        contentView.backgroundColor = .red
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(150)
        }
    }

    func alertInfo() -> WPAlertManager.Alert {
        return .init(.default, location: .bottomToFill(0), showDuration: 0.3, direction: .bottom, dismissDuration: 0.3)
    }
    
    func touchMask() {
        wp.dismiss()
    }
}



