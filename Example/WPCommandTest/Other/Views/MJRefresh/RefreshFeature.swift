//
//  PageViewModel.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/24.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

 
import UIKit
import ComposableArchitecture
import Alamofire

struct PageModel:Equatable {
    var page = 1
    var limit = 10
}

protocol RefreshFeatureDataSource:Decodable{
    associatedtype Data:Decodable & Equatable
    /// 是否是page分页
    func isPage() -> Bool
    /// 最大数据量
    func maxCount() -> Int
    /// lastID
    func lastIdString() -> String
    /// 当前页加载的list
    func pageList() -> [Data]
}

@Reducer  /// 加载列表store逻辑 包含了上拉下拉刷新
struct RefreshFeature<T:RefreshFeatureDataSource> {
    /// 当前页加载的数据
    struct PageData:Equatable {
        enum Direction:Equatable {
          case header
          case footer
        }
        let direction:Direction
        let data:[T.Data]
        
    }

    /// 加载的接口
    enum LoadType {
      case creationAll // 我的创作
    }

    /// 加载的接口类型
    let loadType:LoadType
    
    enum LoadState:Equatable {
        static func == (lhs: RefreshFeature<T>.LoadState, rhs: RefreshFeature<T>.LoadState) -> Bool {
            return false
        }
        case idle        // 初始或已经加载完成
        case loading     // 正在加载
        case success     // 加载成功
        case failure(Error) // 加载失败，携带错误信息
    }
    
    @ObservableState
    struct State:Equatable {
        /// 下次要加载的页码
        var page = PageModel()
        /// 搜索关键字
        var keyword:String = ""
        /// 是否是加载的推荐
        var isRecommend = false
        /// 是否还有更多数据 可用这个属性监听是否还有下一页做出状态变更
        var isNoMoreData = true
        /// last ID
        var lastId:String = "0"
        /// header是否正在刷新
        var isRefreshingHeader:Bool = false
        /// 是否显示loading
        var isShowLoading = false
        /// 是否是第一次加载
        var isFirstLoad = false
        /// 加载状态
        var loadState = LoadState.idle
        /// 所有的数据
        var data:[T.Data]
        /// 当前加载的一页数据
        var pageData:PageData = .init(direction: .header, data: [])
        /// 加载次数
        var loadCount:UInt = 0
        /// 初始化
        init(data: [T.Data] = []) {
            self.data = data
        }
    }
    
    enum Action {
        /// 开始加载 是首页还是下一页
        case refresh(PageData.Direction)
        /// 结束刷新
        case endRefresh(PageData.Direction)
        /// 加载成功
        case loadSuccess
        /// 加载失败
        case loadFailure(Error)
        /// 重试
        case retry
        /// 重置last ID
        case resetLastId(String)
        /// 重置data
        case resetData([T.Data])
        /// 重置是否有更多数据
        case setNoMoreData(Bool)
        /// 重置关键字
        case resetKeyword(String)
        /// 重置所有状态加载第一页数据
        case loadNormalData
        /// 重置分页
        case resetPage(PageModel)
        /// 重置加载次数
        case resetLoadCount(UInt)
        /// 设置当前页加载的数据
        case setPageData(PageData)
        /// 加载推荐
        case loadRecommand
    }
    
    var body: some ReducerOf<Self>{
        
        Reduce { state, action in
            switch action{
            case .refresh(let direction):
                if direction == .header {
                    state.isRefreshingHeader = true
                }
                state.isShowLoading = true

                if direction == .header { // 如果是加载首页 每次重置last ID 和page
                    state.lastId = "0"
                    state.page = .init()
                }
                
                if state.loadCount == 0{
                    state.isFirstLoad = true
                }

                let letState = state
                
                return .run { send in
                    var resualt:Result<T, AFError>
                    
                    if letState.isRecommend { // 是推荐加载推荐接口
//                        resualt = await APIClient.awaitRequest(.searchRecommend(pageNumber: letState.page.page, pageSize: letState.page.limit, type: ""), model: T.self)
                    }else{
//                        switch loadType {
//                        case .creationAll:
//                            resualt = await APIClient.awaitRequest(.worksListV2(type: "",
//                                                                                tag: "",
//                                                                                status: "",
//                                                                                lastId: letState.lastId,
//                                                                                limit: letState.page.limit,
//                                                                                orderBy: "desc",
//                                                                                workId: nil), model: T.self)
//                        }
                    }
                    
                    await send(.endRefresh(direction))
                    await send(.resetLoadCount(letState.loadCount + 1))
                    
                    // 解析结果
                    switch resualt {
                    case .success(let model):
//                        // 如果是首页直接替换data
//                        if direction == .header {
//                            await send(.resetData(model.pageList()))
//                            
//                            if model.isPage(){
//                                let isNormalData = model.pageList().count < model.maxCount()
//                                await send(.setNoMoreData(isNormalData))
//                                if isNormalData { // 如果还有更多数据修改分页准备加载第二页
//                                    var page = letState.page
//                                    page.page = page.page + 1
//                                    await send(.resetPage(page))
//                                }
//                            }else{
//                                await send(.setNoMoreData(true))
//                            }
//                        }else{// 如果是下一页拼接Data
//                            if model.isPage(){ // 如果是page 分页
//                                let totalCount = model.pageList().count + letState.data.count
//                                let isNormalData = totalCount < model.maxCount()
//                                
//                                await send(.setNoMoreData(isNormalData))
//                                
//                                if isNormalData { // 如果还有更多数据修改分页准备加载第二页
//                                    var page = letState.page
//                                    page.page = page.page + 1
//                                    await send(.resetPage(page))
//                                }
//                                if letState.data.count < model.maxCount(){
//                                    var data = letState.data
//                                    data.append(contentsOf: model.pageList())
//                                    await send(.resetData(data))
//                                }
//                            }else{
//                                var data = letState.data
//                                data.append(contentsOf: model.pageList())
//                                await send(.resetData(data))
//                                await send(.setNoMoreData(model.pageList().count > 0))
//                            }
//                        }
//                        // 设置当前页数据
//                        await send(.setPageData(.init(direction: direction, data: model.pageList())))
//                        await send(.resetLastId(model.lastIdString()))
//                        await send(.loadSuccess)
                        
                        // 走推荐接口
//                        if loadType == .searchExplore && model.pageList().isEmpty && (letState.page.page == 1 || letState.lastId == "0"){
//                            await send(.loadRecommand)
//                        }
                    case .failure(let error):
                        await send(.loadFailure(error))
                    }
                }
            case .endRefresh(let direction):
                state.isShowLoading = false
                if direction == .header {
                    state.isRefreshingHeader = false
                }
                state.isNoMoreData = !state.isNoMoreData // 强制外部刷新
                return .none
            case .loadSuccess:
                state.loadState = .success
                return .none
            case .loadFailure(let error):
                state.loadState = .failure(error)
                return .none
            case .retry:
                return .run { send in
                    await send(.refresh(.header))
                }
            case .resetData(let data):
                state.data = data
                return .none
            case .resetLastId(let lastId):
                state.lastId = lastId
                return .none
            case .setNoMoreData(let value):
                state.isNoMoreData = value
                return .none
            case .resetKeyword(let text):
                state.keyword = text
                return .none
            case .loadNormalData:
                state.loadCount = 0
                state.isRecommend = false
                return .run { send in
                    await send(.refresh(.header))
                }
            case .resetLoadCount(let value):
                state.loadCount = value
                if state.loadCount == 0 {
                    state.isFirstLoad = true
                }else{
                    if state.isFirstLoad {
                        state.isFirstLoad = false
                    }
                }
                return .none
            case .resetPage(let page):
                state.page = page
                return .none
            case .setPageData(let data):
                state.pageData = data
                return .none
            case .loadRecommand:
                state.page = .init()
                state.lastId = "0"
                state.isRecommend = true
                return .run { send in
                    await send(.refresh(.header))
                }
            }
        }
    }
    
}
