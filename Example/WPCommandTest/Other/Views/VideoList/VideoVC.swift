//
//  VideoVC.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import ComposableArchitecture
import CombineCocoa
import AVFoundation
import MJRefresh

class ExploreVideoListVC: BaseVC {

    lazy var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let listSotre = Store.init(initialState: RefreshFeature<[VideoVo]>.State(data: [
        .init(),.init(),.init(),.init()
    ])) {
        RefreshFeature<[VideoVo]>(loadType: .creationAll)
    }
    var currentItem:VideoVo?{
        return listSotre.data[currentIndex]
    }

    var currentIndex:Int
    
    let showRefresh:Bool
    
    var isFirstOpen = true

    
    private var dragStartY: CGFloat = 0
    

    /// 初始化列表
    /// - Parameters:
    ///   - index: 索引
    ///   - list: 列表列表集合
    ///   - loadType: 使用的接口
    ///   - lastId: 下一页的lastID
    ///   - page: 如果是分页传递到页码
    ///   - keyword: 搜索关键字
    ///   - showRefresh: 是否有上拉加载更多

    init(currentIndex: Int, showRefresh: Bool) {
        self.currentIndex = currentIndex
        self.showRefresh = showRefresh
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isFirstOpen{
            scrollTo(currentIndex)
        }else{
            VideoPlayerManager.shared.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VideoPlayerManager.shared.pause()
    }
    
    deinit{
        print("销毁VideoPlayerManager")
        VideoPlayerManager.shared.releaseCurrentPlayer()
    }
    
    override func bindViewModel() {

        // 加载完下一页 刷新cell
        listSotre.publisher.pageData.filter({ !$0.isEmpty})
            .delay(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink(receiveValue: {[weak self] value in
            guard let self else { return }
                let currentCount = collectionView.numberOfItems(inSection: 0)
                if currentCount == self.listSotre.data.count { return }
                
                let startIndex = self.listSotre.data.count - value.count
                let endIndex = self.listSotre.data.count - 1
                if startIndex != endIndex && startIndex != 0{
                    let indexPaths = (startIndex...endIndex).map { IndexPath(item: $0, section: 0) }
                    
                    collectionView.performBatchUpdates({
                        self.collectionView.insertItems(at: indexPaths)
                    })
                }
                
            }).store(in: &wp.cancellables.set)
    }
    
    override func observeSubViewEvent() {
        
        if showRefresh{
//            collectionView.footerAutoRefreshPublisher().sink(receiveValue: {[weak self] _ in
//                self?.listSotre.send(.refresh(isHeader: false))
//            }).store(in: &objCancellables.set)
        }

        listSotre.publisher.isNoMoreData.delay(for: .seconds(0.4), scheduler: DispatchQueue.main).sink(receiveValue: {[weak self] view in
            self?.collectionView.mj_footer?.endRefreshing()
        }).store(in: &wp.cancellables.set)
    }

    override func initSubView() {
        super.initSubView()
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: "VideoCell")
        
        view.insertSubview(collectionView, at: 0)
    }
    
    override func initSubViewLayout() {
        super.initSubViewLayout()
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstOpen {
            scrollTo(currentIndex)
            
            DispatchQueue.main.async {[weak self] in
                guard let self else { return }
                if playVideo(at: currentIndex){
                    isFirstOpen = false
                }else{
                    DispatchQueue.main.async {[weak self] in
                        guard let self else { return }
                        if playVideo(at: currentIndex){
                            isFirstOpen = false
                        }
                    }
                }
            }
        }
    }
}


extension ExploreVideoListVC: UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listSotre.data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath)
        let model = listSotre.data[indexPath.item]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? VideoCell)?.willDisplay()
    }
}

extension ExploreVideoListVC:UIScrollViewDelegate{
    
    func scrollTo(_ index:Int,animate:Bool = false,complete:(()->Void)? = nil){
        let section = 0
        let itemCount = collectionView.numberOfItems(inSection: section)
        // ------ 越界检查 ------
        guard index >= 0 else {
            print("❌ safeScrollTo: index < 0 (\(index))")
            return
        }
        
        guard index < itemCount else {
            print("❌ safeScrollTo: index (\(index)) >= itemCount (\(itemCount))")
            return
        }

        collectionView.scrollToItem(at: .init(item: index, section: 0), at: .centeredVertically, animated: animate)
        if animate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                complete?()
            })
        }else{
            complete?()
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragStartY = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let endY = scrollView.contentOffset.y
        
        if endY > dragStartY {
            print("👉 上滑")

        } else if endY < dragStartY {
            print("👈 下滑")
        } else {
            print("没有移动")
        }
        

        let index = Int(collectionView.contentOffset.y / collectionView.bounds.height)
        playVideo(at: index)
    }
    
    /// 返回是否播放成功
    @discardableResult
    private func playVideo(at index: Int)->Bool {
        // 播放新的视频
        currentIndex = index

        if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? VideoCell {
            let model = listSotre.data[index]
            VideoPlayerManager.shared.playVideo(for: cell, model: model)
            return true
        }else{
            return false
        }
    }
    
    func deleteWith(id:Int){
        if self.listSotre.data.count == 1{
            self.navigationController?.popViewController(animated: true)
        }else{
            if currentIndex == 0 && self.listSotre.data.count > 1{ // 播放的第一个cell
                let nexIndex = currentIndex + 1
                VideoPlayerManager.shared.pause()
                scrollTo(nexIndex,animate: true,complete: {
                    self.playVideo(at: nexIndex)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.deleteCell(index: 0)
                        self.currentIndex = 0
                    })
                })
            }else if currentIndex > 0 && currentIndex != listSotre.data.count - 1{ // 中间的删除
                let nexIndex = currentIndex + 1
                VideoPlayerManager.shared.pause()
                scrollTo(nexIndex,animate: true,complete: {
                    self.playVideo(at: nexIndex)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.deleteCell(index: nexIndex - 1)
                        self.currentIndex = nexIndex - 1
                    })
                })

            }else if currentIndex == listSotre.data.count - 1 { // 播放的时候最后一个
                let nexIndex = currentIndex - 1
                VideoPlayerManager.shared.pause()
                scrollTo(nexIndex,animate: true,complete: {
                    self.playVideo(at: nexIndex)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.deleteCell(index: nexIndex + 1)
                        self.currentIndex = self.listSotre.data.count - 1
                    })
                })
            }
        }
    }
    
    func deleteCell(index:Int){
        var data = listSotre.data
        data.remove(at: index)
        listSotre.send(.resetData(data))
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        })
    }
}

