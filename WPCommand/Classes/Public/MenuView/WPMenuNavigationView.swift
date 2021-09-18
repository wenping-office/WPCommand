//
//  WPMenuNavigationView.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/15.
//

import UIKit

class WPMenuNavigationItem {
    /// 每一个item的size
    let size : CGSize
    /// 当前item索引
    let index : Int
    /// 是否被选中
    var isSelected = false
    /// item
    let navigationItem : WPMenuViewNavigationProtocol

    init(size:CGSize,
         index:Int,
         item:WPMenuViewNavigationProtocol) {
        self.index = index
        self.size = size
        self.navigationItem = item
    }
}

class WPMenuNavigationView: UITableViewHeaderFooterView {
    
    let layout = UICollectionViewFlowLayout()
    /// 内容视图
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    /// 当前数据源
    var data : [WPMenuNavigationItem] = []{
        didSet{
            collectionView.reloadData()
        }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        backgroundColor = .white
        contentView.addSubview(collectionView)
        collectionView.backgroundColor = .blue
        
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.top.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 注册视图
    func registerCell() {
        for index in 0..<data.count {
            let reuseIdentifier = NSStringFromClass(WPMenuNavigationCell.self) + index.description
            collectionView.register(WPMenuNavigationCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        }
    }
}

extension WPMenuNavigationView:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return data[indexPath.row].size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension WPMenuNavigationView:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseIdentifier = NSStringFromClass(WPMenuNavigationCell.self) + indexPath.row.description
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WPMenuNavigationCell
        
        cell.navItem = data[indexPath.row]
        return cell
    }
    
}

/// 菜单视图
class WPMenuNavigationCell: UICollectionViewCell{
    
    /// 导航栏item
    var navItem : WPMenuNavigationItem?{
        didSet{
            if let item = navItem {
                item.navigationItem.upledeStatus(status: .normal)
                wp_removeAllSubViewFromSuperview()
                addSubview(item.navigationItem)
                item.navigationItem.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        }
    }
}
