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
import WPCommand

enum Section {
  case header
  case list
}

class Item<T>:Hashable,Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }

    let id = UUID()
    var data:T

    init(data: T) {
        self.data = data
    }
}

class VideoVC: BaseVC,UICollectionViewDelegate {
    
    lazy var layout = UICollectionViewCompositionalLayout.init { section, env in
        return .init(group: .vertical(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                        heightDimension: .fractionalHeight(1)), subitems: [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))]))
    }
    
    lazy var listView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    lazy var source = UICollectionViewDiffableDataSource<Section,Item<VideoVo>>.init(collectionView: listView) { collectionView, indexPath, itemIdentifier in
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
        cell.wp.cancellables.set.removeAll()
        cell.videoVo = itemIdentifier.data
        return cell
    }

    let listStore:ListStore<[VideoVo]>
    let detail:Bool
    var index:Int
    var defaultOpen = true


    init(listStore: ListStore<[VideoVo]>,
         detail: Bool,
         index: Int) {
        self.listStore = listStore
        self.detail = detail
        self.index = index
        super.init()
        
        var snapshot = self.source.snapshot()
        snapshot.appendSections([.list])
        snapshot.appendItems(listStore.datas.map({ .init(data: $0)}), toSection: .list)
        self.source.apply(snapshot)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
    
    
    deinit {
        print("销毁")
        VideoPlayerManager.shared.releaseLayer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VideoPlayerManager.shared.play()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VideoPlayerManager.shared.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        VideoPlayerManager.shared.pause()
    }

    override func observeSubViewEvent() {
        if !detail{
            listView.footerPublisher().withWeak(self).flatMap { $0.0.listStore.load(.footer) }.sink(receiveValue: { _ in}).store(in: &wp.cancellables.set)
        }

        listStore.$state.sink(receiveValue: {[weak self] state in
            guard let self else { return }
            if case .endRefresh(_,let res,let hasMoreData,let direction,_) = state {
                self.listView.endRefresh(direction.toLoadDirection(), isNoMoreData: hasMoreData)
                if case .success(let model) = res {
                    var snapshot = self.source.snapshot()
                    snapshot.appendItems(model.data?.pageList().map({ Item<VideoVo>(data: $0) }) ?? [], toSection: .list)
                    self.source.apply(snapshot)
                }
            }
        }).store(in: &wp.cancellables.set)
    }

    override func initSubView() {
        listView.isPagingEnabled = true
        listView.register(VideoCell.self, forCellWithReuseIdentifier: "VideoCell")
        listView.backgroundColor = .clear
        listView.translatesAutoresizingMaskIntoConstraints = false
        listView.contentInsetAdjustmentBehavior = .never
        listView.delegate = self

        view.insertSubview(listView, at: 0)
    }

    override func initSubViewLayout() {
        listView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playFistOpenVideo()
    }
    
    func playFistOpenVideo(){
        guard defaultOpen else {
            return
        }

        scrollToVideoCell(index,complete: { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.playVideo(self.index)
                self.defaultOpen = false
            }
        })
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(listView.contentOffset.y / listView.bounds.height)
        playVideo(index)
    }
    
    func scrollToVideoCell(_ index:Int,complete:(()->Void)? = nil){
        listView.scrollToItem(at: .init(item: index, section: 0), at: .centeredVertically, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            complete?()
        })
    }
    
    func playVideo(_ index: Int) {
        self.index = index
        
        guard let cell = listView.cellForItem(at: IndexPath(item: index, section: 0)) as? VideoCell else {
            print("没有找到这个cell")
            return
        }

        VideoPlayerManager.shared.play(to: cell)
    }
}

