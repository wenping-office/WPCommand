//
//  WPMenuChildView.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/15.
//

import UIKit

struct WPMenuNavigationViewItem {
    /// 当前item索引
    let index : Int
    /// 即将显示
    let willDisplay : (Int)->Void
    /// 重用标识符
    var reuseIdentifier : String{
        return NSStringFromClass(WPMenuBodyCell.self) + index.description
    }
}

/// 菜单视图
class WPMenuBodyView: UITableViewCell{

    let layout = UICollectionViewFlowLayout()
    /// 内容视图
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    /// 当前数据源
    let data : [WPMenuNavigationViewItem] = []

    init(){
        super.init(style: .default, reuseIdentifier: nil)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        backgroundColor = .white
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 注册视图
    func registerCell() {
        data.forEach {[weak self] elmt in
            self?.collectionView.register(WPMenuBodyCell.self, forCellWithReuseIdentifier: elmt.reuseIdentifier)
        }
    }
    
    func setCollectionSize(_ size:CGSize){
        layout.itemSize = size
        collectionView.reloadData()
    }
}

extension WPMenuBodyView:UICollectionViewDelegate{

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}

extension WPMenuBodyView:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = data[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath)
        return cell
    }
    
    
}


class WPMenuBodyCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .wp_random
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 添加一个视图
    func setBodyView(_ view:UIView?){
        print(self)
    }
}
