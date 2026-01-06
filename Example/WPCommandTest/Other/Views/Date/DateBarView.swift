//
//  DateBarView.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import Combine

class DateBarViewItemVo {
    /// 日期
    let date:Date
    /// 附件
    let info:Any?
    
    fileprivate var isSelected = false
    fileprivate var updateState:(()->Void)?
    
    init(date: Date,
         info: Any? = nil) {
        self.date = date
        self.info = info
    }
    
    func update(){
        updateState?()
    }
}

protocol DateBarViewCell:UICollectionViewCell {
    /// 被选中
    func set(data:DateBarViewItemVo)
}

/// 滚动的日期选择视图
class DateBarView<Cell:DateBarViewCell>: BaseView,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    private let layout = UICollectionViewFlowLayout()
    
    private lazy var limitView = UICollectionView(frame: .zero, collectionViewLayout: layout)


    private var intimacyVCSliderContentInset:CGFloat{
        return (maxWidth * 0.5) - itemWidth * 0.5
    }
    
    private var itemWidth:CGFloat{
        return (maxWidth - cellPadding * 5) / 7
    }
    
    
    private var lastSelectedItem:DateBarViewItemVo?
    
    private var currentOffsetConst:CGFloat = 0
    
    /// 震动反馈
    public var isTriggerHapticFeedback = false
    
    public let itemHeight:CGFloat
    public let cellPadding:CGFloat
    public let maxWidth:CGFloat
    /// 数据源
    public var datas = [DateBarViewItemVo]()
    
    /// 当前滑动的偏移量
    @Published public var progress:CGFloat = 0
    /// 当前选中date
    @Published public var date:Date?

    
    /// 初始化一个日期bar
    /// - Parameters:
    ///   - itemHeight: 日期cell高度
    ///   - cellPadding: padding
    ///   - maxWidth: 最大的宽
    init(itemHeight:CGFloat,
         cellPadding:CGFloat,
         maxWidth:CGFloat) {
        self.itemHeight = itemHeight
        self.cellPadding = cellPadding
        self.maxWidth = maxWidth
        super.init(frame: .zero)
        
        limitView.register(Cell.self, forCellWithReuseIdentifier: "cell")
    }
    
    /// 跳转到某个日期
    /// - Parameter date: 日期
    func jump(to date:Date){
        if let index = datas.firstIndex(where: { vo in
            return vo.date.wp.string("yyyy-MM-dd") == date.wp.string("yyyy-MM-dd")
        }){
           let currentDate = datas[index]
            self.date = currentDate.date
            
           limitView.layoutIfNeeded()
           limitView.scrollToItem(at: .init(row: index, section: 0), at: .right, animated: false)

            datas[index].isSelected = true
            datas[index].update()
            lastSelectedItem = datas[index]
       }
    }

    override func initSubView() {
        
        limitView.delegate = self
        limitView.dataSource = self
        layout.itemSize = .init(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        

        limitView.showsHorizontalScrollIndicator = false
        limitView.showsHorizontalScrollIndicator = false
        layout.scrollDirection = .horizontal
        limitView.backgroundColor = .clear
        limitView.contentInset = .init(top: 0, left: intimacyVCSliderContentInset, bottom: 0, right: intimacyVCSliderContentInset)
        
        addSubview(limitView)
    }
    
    override func initSubViewLayout() {
        limitView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastSelectedItem?.isSelected = false
        lastSelectedItem?.update()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        var maxLenght = scrollView.contentSize.width - 15
        if maxLenght < 0{
            maxLenght = 0
        }
        let currentOffent = scrollView.contentOffset.x + scrollView.contentInset.left + 7.5

        var index = 0
        if currentOffent != 0 && maxLenght != 0{
            index = Int(currentOffent / maxLenght * 100)
        }
        
        var progress = Double(index) / 100.0
        if progress > 1{
            progress = 1
        }
        if progress < 0{
            progress = 0
        }

        self.progress = progress
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToCell()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToCell()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        weak var cusCell = cell as? Cell
        cusCell?.set(data: datas[indexPath.row])
        let data = datas[indexPath.row]
        
        data.updateState = {
            cusCell?.set(data: data)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isTriggerHapticFeedback{
            triggerHapticFeedback()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lastSelectedItem?.isSelected = false
        lastSelectedItem?.update()

        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        date = datas[indexPath.row].date

        datas[indexPath.row].isSelected = true
        datas[indexPath.row].update()
        lastSelectedItem = datas[indexPath.row]
    }

    func scrollToCell(const:CGFloat = 0){
        if let indexPath = limitView.centerIndexPath(const: const){
            currentOffsetConst = 0
            limitView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            date = datas[indexPath.row].date
            
            lastSelectedItem?.isSelected = false
            lastSelectedItem?.update()

            datas[indexPath.row].isSelected = true
            datas[indexPath.row].update()
            lastSelectedItem = datas[indexPath.row]
        }else{
            if currentOffsetConst > 50 { // 重试5次找不到就不找了
                return
            }
            currentOffsetConst = currentOffsetConst + 10
            scrollToCell(const: currentOffsetConst)
        }
    }
    
    func triggerHapticFeedback(){
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}


extension UICollectionView {
    var centerCell: UICollectionViewCell? {
        let centerPoint = CGPoint(
            x: self.center.x + self.contentOffset.x,
            y: self.center.y + self.contentOffset.y
        )
        
        if let indexPath = self.indexPathForItem(at: centerPoint) {
            return self.cellForItem(at: indexPath)
        }
        return nil
    }
    
    func centerIndexPath(const:CGFloat = 0)-> IndexPath? {
        let centerPoint = CGPoint(
            x: self.center.x + self.contentOffset.x + const,
            y: self.center.y + self.contentOffset.y
        )
        return self.indexPathForItem(at: centerPoint)
    }
}




