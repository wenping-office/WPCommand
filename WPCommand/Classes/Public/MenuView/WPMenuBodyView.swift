//
//  WPMenuChildView.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/15.
//

import UIKit

class WPMenuBodyViewItem {
    /// 当前item索引
    let index : Int
    /// 展示的视图
    var view : UIView?{
        didSet{
            isAddToSuperView = false
        }
    }
    /// 是否加入到视图
    var isAddToSuperView = false
    /// 重用标识符
    var reuseIdentifier : String{
        return NSStringFromClass(WPMenuBodyCell.self) + index.description
    }
    
    init(index:Int,view:UIView?) {
        
        self.index = index
        self.view = view
    }
}

/// 菜单视图
class WPMenuBodyView: UITableViewCell{

    let layout = UICollectionViewFlowLayout()
    /// 内容视图
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    /// 当前数据源
    var data : [WPMenuBodyViewItem] = []
    /// 内容滚动回调
    var contentOffSet : ((CGFloat)->Void)?
    /// 当前滚动到的索引
    var selectedIndexBlock : ((Int)->Void)?

    init(){
        super.init(style: .default, reuseIdentifier: nil)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        selectionStyle = .none
        backgroundColor = .white
        contentView.addSubview(collectionView)
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
    
    func selected(_ index:Int){
        collectionView.contentOffset = .init(x: CGFloat(index) * collectionView.wp_width, y: 0)
    }
}

extension WPMenuBodyView:UICollectionViewDelegate{

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        let cell = cell as? WPMenuBodyCell
        
        if !item.isAddToSuperView {
            cell?.setBodyView(item.view)
            item.isAddToSuperView = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x / scrollView.wp_width
        contentOffSet?(offSet)
        let index = Int(scrollView.contentOffset.x / scrollView.wp_width + 0.5)
        selectedIndexBlock?(index)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let index = Int(scrollView.contentOffset.x / scrollView.wp_width + 0.5)
        selectedIndexBlock?(index)
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
        if let view = view {
            contentView.wp_removeAllSubViewFromSuperview()
            contentView.addSubview(view)
            contentView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }else{
            contentView.wp_removeAllSubViewFromSuperview()
        }

    }
}
