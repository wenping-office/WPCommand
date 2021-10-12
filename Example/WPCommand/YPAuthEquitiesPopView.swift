//
//  YPAuthEquitiesPopView.swift
//  yupao
//
//  Created by superLee on 2021/10/7.
//  Copyright © 2021 payne. All rights reserved.
//  认证权益弹框视图

import UIKit
import WPCommand

class YPAuthEquitiesPopView: UIView,WPAlertProtocol {
    
    /// 数据源
    var dataSource: [String?] = ["快速发布 优先审核",
                                 "曝光推荐 极速找活",
                                 "高亮标识 发布无忧",
                                 "专属客服 优先服务"]

    /// 顶部背景图
    lazy var iv: UIImageView = {
        let iv = UIImageView()

        iv.clipsToBounds = true
        iv.image = UIImage(named: "icon_AuthEquities_bg")
        return iv
    }()
    
    /// 提示语
    lazy var lbTitle: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textAlignment = .center
        view.text = "完成实名认证将获得以下权益"
        view.textColor = .wp_random
        return view
    }()
    
    /// tab
    lazy var tableView: UITableView = {
        let tab = UITableView()
        tab.delegate = self
        tab.dataSource = self
        tab.separatorStyle = .none
        tab.isScrollEnabled = false
        tab.backgroundColor = .white
        tab.register(UITableViewCell.self, forCellReuseIdentifier: "YPAuthEquitiesPopCellID")
        return tab
    }()
    
    /// 提示语
    lazy var moreTitle: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1

        view.textColor = .wp_random
        view.textAlignment = .center
        view.text = "-更多权益，即将开放，敬请期待-"
        return view
    }()
    
    /// 去认证 / 我知道了[按钮]
    lazy var btnAuth: UIButton = {
        let view = UIButton.init(type: .custom)
        view.layer.cornerRadius = 4
        view.isUserInteractionEnabled = true

        view.setTitleColor(UIColor.white, for: .normal)
        view.setTitle("去认证", for: .normal)
        return view
    }()
    
    var btnTitle: String = "" {
        didSet{
            btnAuth.setTitle(btnTitle, for: .normal)
        }
    }
    
    func makeUI() {
        addSubview(lbTitle)
        addSubview(moreTitle)
        addSubview(tableView)
        addSubview(btnAuth)
        
        let h: CGFloat = 35
        let count: CGFloat = CGFloat(dataSource.count)
        let tableHeight = count * h
        let maxWidth = wp_Screen.width * 0.7
        
        lbTitle.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.width.equalTo(maxWidth)
            make.height.equalTo(26)
        }

        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(lbTitle.snp.bottom)
            make.height.equalTo(tableHeight)
        }

        moreTitle.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom).offset(16)
        }

        btnAuth.snp.makeConstraints { make in
            make.top.equalTo(moreTitle.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        
        wp_subViewRandomColor()
    }
    
    /// 初始化
    /// - Parameter dataSource: 传字符串数组
    init(dataSource: [String?]) {
        super.init(frame: .zero)
        self.dataSource = dataSource
        layer.cornerRadius = CGFloat(8)
        clipsToBounds = true
        backgroundColor = .white
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchMask() {
        dissmiss()
    }
}

// MARK: - UITableViewDelegate
extension YPAuthEquitiesPopView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "YPAuthEquitiesPopCellID", for: indexPath) as? UITableViewCell {
            cell.textLabel?.text = dataSource[indexPath.row]
            return cell
        }else {
            return UITableViewCell()
        }
    }
}

