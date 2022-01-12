//
//  TestMenuVC.swift
//  WPCommand_Example
//
//  Created by WenPing on 2021/8/5.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand
import MJRefresh
import RxSwift

class TestMenuVC: WPBaseVC, WPMenuViewDataSource {
    
    let test1 = TestMenuVC2()
    let test2 = TestMenuVC2()
    let test3 = TestMenuVC2()
    let header = TestMenuHeaer()

    func menuBodyViewForIndex(index: Int) -> WPMenuBodyViewProtocol? {
        if index == 0 {
            return test1
        }else if index == 1{
            return test2
        }else if index == 2{
            return test3
        }
        return nil
    }

    func menuHeaderViewForIndex(index: Int) -> WPMenuHeaderViewProtocol?{
        return TestMenuHeaer()
    }

    let menuView = WPMenuView(navigationHeight: 44)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(test1)
        addChild(test2)
        addChild(test3)
        
        view.backgroundColor = .white
        menuView.dataSource = self
        menuView.tableView.bounces = false
        let items = [testMenuItem(index: 0),testMenuItem(index: 1),testMenuItem(index: 2)]
        menuView.setNavigation(items)
        menuView.selected(0)
    }
    
    override func initSubView() {
        
        menuView.bodyViewSelecteAnimate = true
        view.addSubview(menuView)
    }

    override func initSubViewLayout() {
        menuView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
    }

}

class testMenuItem: UILabel,WPMenuNavigationViewProtocol {

    init(index:Int) {
        super.init(frame: .zero)
        text = "测试代码\(index)"
        font = UIFont.boldSystemFont(ofSize: 10)
        textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func menuItemWidth() -> CGFloat {
        return CGFloat(150)
    }
    
    func menuViewChildViewUpdateStatus(menuView: WPMenuView, status: WPMenuView.MenuViewStatus) {
        if status == .normal {
            backgroundColor = .white
        }else{
            backgroundColor = .blue
        }
    }
    
    func willRolling(with percentage: CGFloat) {
        
        let size = 10 + (percentage * 5)
        
        self.font = UIFont.boldSystemFont(ofSize: size)

//        print(size,percentage)
    }
}


class TestMenuVC1: WPBaseVC,WPMenuBodyViewProtocol,WPMenuViewDataSource{
    func menuBodyViewForIndex(index: Int) -> WPMenuBodyViewProtocol? {
        switch index {
        case 0:
            return test1
        case 1:
            return test2
        default:
            return nil
        }
    }
    
    let menuView = WPMenuView(navigationHeight: 44)
    let test1 : ContentVC = .init()
    let test2 : ContentVC = .init()

    func menuBodyView() -> UIView? {
        return view
    }
    
    override func initSubView(){
        
        addChild(test1)
        addChild(test2)
        
        test2.view.backgroundColor = .orange
        test1.view.backgroundColor = .green

        menuView.dataSource = self
        menuView.horizontalGestureAdaptation = true
//        menuView.setNavigation([testMenuItem(),testMenuItem()])
        
        view.backgroundColor = .red
        view.addSubview(menuView)
    }
    
    override func initSubViewLayout() {
        menuView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    class ContentVC: WPBaseVC,WPMenuBodyViewProtocol {
        let tableView = testTableView()
        
        func menuBodyView() -> UIView? {
            return view
        }
        
        override func initSubView(){
            view.addSubview(tableView)
//            tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
//                WPGCD.main_asyncAfter(.now() + 3, task: {[weak self] in
//                    self?.tableView.mj_header?.endRefreshing()
//                })
//            })
        }
        
        override func initSubViewLayout() {
            tableView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

class TestMenuVC2: WPBaseVC,WPMenuBodyViewProtocol {
    func menuBodyView() -> UIView? {
        return view
    }
    
    let tableView = UITableView()
    
    override func initSubView(){
        view.backgroundColor = .blue
        
        view.addSubview(tableView)
        
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            WPGCD.main_asyncAfter(.now() + 3, task: {[weak self] in
                self?.tableView.mj_header?.endRefreshing()
            })
        })
    }
    
    override func initSubViewLayout(){
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


class TestMenuHeaer: WPBaseView,WPMenuHeaderViewProtocol {
    
    override func initSubView() {
        
        let label = UILabel()
        

        backgroundColor = .darkGray
    }

    func menuHeaderView() -> UIView? {
        backgroundColor = .green
        return self
    }
    
    func menuHeaderViewAtHeight() -> WPMenuView.HeaderHeightOption {
        
        return .height(200)
    }
}


class testTableView: UITableView {
    
    init(){
        super.init(frame: .zero, style: .plain)
//        horizontalAdaptation = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        return false
//    }
}
