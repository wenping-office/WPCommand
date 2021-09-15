//
//  WPMenuNavigationView.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/15.
//

import UIKit

class WPMenuNavigationView: WPBaseView {
    
    let layout = UICollectionViewFlowLayout()
    /// 内容视图
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    /// 当前数据源
    let data : [WPMenuViewNavigationProtocol] = []

    override func initSubView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WPMenuNavigationCell.self, forCellWithReuseIdentifier: NSStringFromClass(WPMenuNavigationCell.self))
        backgroundColor = .white
        addSubview(collectionView)
        
    }
    
    override func initSubViewLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setCollectionSize(_ size:CGSize){
        layout.itemSize = size
        collectionView.reloadData()
    }
}

extension WPMenuNavigationView:UICollectionViewDelegate{

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}

extension WPMenuNavigationView:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(WPMenuNavigationCell.self), for: indexPath)
        return cell
    }
    
    
}

/// 菜单视图
class WPMenuNavigationCell: UICollectionViewCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .wp_random
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
