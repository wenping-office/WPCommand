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
    let test2 = TestMenuVC1()
    let test3 = TestMenuVC2()
    let test4 = TestMenuVC2()
    let test5 = TestMenuVC2()
    let test6 = TestMenu3()
    let header = TestMenuHeaer()

    func menuBodyViewForIndex(index: Int) -> WPMenuBodyViewProtocol? {
        if index == 0 {
            return test1
        }else if index == 1{
            return test2
        }else if index == 2{
            return test3
        }else if index == 3{
            return test4
        }else if index == 4{
            return test5
        }else if index == 5{
            return test6
        }
        
        return nil
    }

    func menuHeaderViewForIndex(index: Int) -> WPMenuHeaderViewProtocol?{
        
        switch index{
        case 0:
            return TestMenuHeaer1()
        case 1:
            return TestMenuHeaer2()
        case 2:
            return TestMenuHeaer3()
        case 3:
            return nil
        case 4:
            return TestMenuHeaer3()
        case 5:
            return TestMenuHeaer3()
        default:
            return nil
        }
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
        menuView.multiGesture = true
//        menuView.autoAdaptationScroll = false

        let items = [style(str: "测试代码32323"),
                     style(str: "测试代码2"),
                     style(str: "测试代码3"),
                     style(str: "测试代码4"),
                     style(str: "测试代码5"),
                     style(str: "测试代码6")]
        menuView.setNavigation(items)
        menuView.selectedAnimation = true

        
        menuView.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {[weak self] in
                self?.menuView.tableView.mj_header?.endRefreshing()
            })
        })
    }
    
    func style(str:String) -> WPMenuView.DefaultNavigationItem{

        return WPMenuView.DefaultNavigationItem.default(.init(.text(str),
                                                              background: .background(),
                                                              line: .line(nil, 5, .init(left: 30, right: 30),
                                                                          color: .wp.random)))
    }

    override func initSubView() {
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

    deinit {

    }
}



class TestMenuVC2: WPBaseVC,WPMenuBodyViewProtocol,UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "索引\(indexPath.row)"

        return cell
    }
    
    func menuBodyView() -> UIView? {
        return view
    }
    
    let tableView = UITableView()
    
    override func initSubView(){
        view.backgroundColor = .blue
        
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.backgroundColor = .wp.random
        
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {[weak self] in
                self?.tableView.mj_header?.endRefreshing()
            })
        })
    }
    
    override func initSubViewLayout(){
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        targetViewDidScroll?(scrollView)
    }
    
    func menuBodyViewAdaptationScrollView() -> UIScrollView?{
        return tableView
    }

    deinit {
        print("vc 销毁")
    }
}

class TestMenu3: WPBaseVC,WPMenuBodyViewProtocol {
    func menuBodyView() -> UIView? {
        view.backgroundColor = .blue
       return view
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
    
    deinit {
        print("header 销毁")
    }
}

class TestMenuHeaer1 : TestMenuHeaer{
    override func menuHeaderViewAtHeight() -> WPMenuView.HeaderHeightOption {
        
        return .height(200)
    }
}


class TestMenuHeaer2 : TestMenuHeaer{
    override func menuHeaderViewAtHeight() -> WPMenuView.HeaderHeightOption {
        
        return .height(150)
    }
}

class TestMenuHeaer3 : TestMenuHeaer{
    override func menuHeaderViewAtHeight() -> WPMenuView.HeaderHeightOption {
        
        return .height(300)
    }
}

class TestMenuHeaer4 : TestMenuHeaer{
    override func menuHeaderViewAtHeight() -> WPMenuView.HeaderHeightOption {
        
        return .height(120)
    }
    
    deinit {
        print("header 销毁")
    }
}



class TestMenuVC1: WPBaseVC,WPMenuBodyViewProtocol,WPMenuViewDataSource,WPMenuViewDelegate{
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
    let test2 : TestMenuVC2 = .init()

    func menuBodyView() -> UIView? {
        return view
    }
    
    func menuBodyViewAdaptationScrollView() -> UIScrollView? {
        return menuView.tableView
    }
    
    func menuViewDidVerticalScroll(_ point: CGPoint) {
        targetViewDidScroll?(menuView.tableView)
    }

    override func initSubView(){
        
        addChild(test1)
        addChild(test2)
        
        let co = UICollectionView(frame: .zero, collectionViewLayout: .init())

        test2.view.backgroundColor = .orange
        test1.view.backgroundColor = .green

        menuView.dataSource = self
        menuView.delegate = self
        menuView.horizontalGestureAdaptation = true
        menuView.setNavigation([style(str: "蓝色"),style(str: "绿色")])
        
        view.backgroundColor = .red
        view.addSubview(menuView)
    }
    
    func style(str:String) -> WPMenuView.DefaultNavigationItem{

        return WPMenuView.DefaultNavigationItem.default(.init(.text(str), background: .background(), line: .line(nil, 5, .init(left: 30, right: 30), color: .wp.random)))
    }
    
    override func initSubViewLayout() {
        menuView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    class ContentVC: WPBaseVC,WPMenuBodyViewProtocol {
        let tableView = UITableView()
        
        func menuBodyView() -> UIView? {
            return view
        }
        
        override func initSubView(){
            view.addSubview(tableView)
        }
        
        override func initSubViewLayout() {
            tableView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}
