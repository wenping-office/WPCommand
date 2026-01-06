//
//  ListStore.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2026/1/6.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import Combine
import UIKit
import MJRefresh

struct PageVo{
    var page = 1
    var size = 10
}

protocol ListStoreSource:Codable{
    associatedtype Data:Codable & Equatable

    func lastIdString() -> String

    func pageList() -> [Data]
}

enum ListStoreApi{
    case test
    case uploadImages
    case workResults
    case templateLikes
}


extension ListStore{
    enum State<Source:Codable> {
        case normal

        case loading(isFirst:Bool)
        
        case endRefresh(isFirst:Bool,
                        res: ApiResult<Source>,
                        hasMoreData:Bool,
                        direction:Data.Direction,
                        isEmpty:Bool)
    }
    
    struct Data {
        enum Direction:Equatable {
          case header
          case footer
            
            func toLoadDirection()->LoadDirection{
                switch self {
                case .header:
                        .header
                case .footer:
                        .footer
                }
            }
        }
        let direction:Direction
        let data:[T.Data]
    }
}



class ListStore<T:ListStoreSource> {
    
    func copy() -> ListStore<T> {
        return ListStore.init(api: api,page: page, lastId: lastId, datas: datas)
    }
    
   @Published var datas:[T.Data]

    let api:ListStoreApi
    var page:PageVo
    var lastId:String
    
   @Published var state:State<T> = .normal
    
    private var currentDirection = Data.Direction.header
    private var loadCount = 0

    init(api: ListStoreApi,
         page: PageVo = .init(),
         lastId: String = "0",
         datas:[T.Data] = []) {
        self.api = api
        self.page = page
        self.lastId = lastId
        self.datas = datas
    }
    
    func load(_ direction:Data.Direction) -> AnyPublisher<Void,Never> {
        currentDirection = direction
        
        if direction == .header {
            page = .init()
            lastId = "0"
        }

        state = .loading(isFirst: loadCount == 0)

        var request:AnyPublisher<ApiVo<T>, ApiError<T>>!

//        switch api {
//        case .test:
//            request = Api.testHomeTemplates(page: page.page, pageSize: page.size).request(T.self)
//        case .uploadImages:
//            request = Api.historyUploadImages.request(T.self)
//        case .workResults:
//            request = Api.workResults(lastId: lastId, pageSize: page.size).request(T.self)
//        case .templateLikes:
//            request = Api.templateLikes(page: page.page, pageSize: page.size).request(T.self)
//        }

        return request.asApiResult().handleEvents(receiveOutput: {[weak self] res in
            guard let self else { return }
            
            switch res {
            case .success(let model):
                self.loadCount += 1
                
                if direction == .header{
                    datas = model.data?.pageList() ?? []
                }else{
                    var locDatas = datas
                    locDatas.append(contentsOf: model.data?.pageList() ?? [])
                    datas = locDatas
                }

                self.page = .init(page: self.page.page + 1)
                self.lastId = model.data?.lastIdString() ?? "0"
                
                self.state = .endRefresh(isFirst: self.loadCount == 1, res: .success(model: model), hasMoreData: model.data?.pageList().isEmpty ?? true, direction: direction, isEmpty: datas.isEmpty)
            case .error(let error):
                self.state = .endRefresh(isFirst: self.loadCount == 1, res: .error(error: error), hasMoreData: true, direction: direction, isEmpty: datas.isEmpty)
            }
      
        }).mapToVoid().eraseToAnyPublisher()
    }
    
    func loadAction(_ direction:Data.Direction){
        Task{
            try? await load(direction).asAwait()
        }
    }

    func retry(){
        Task{
            try? await load(currentDirection).asAwait()
        }
    }

    func delete(_ item:T.Data){
        var array = datas
        array.removeAll(where: { $0 == item})
        datas = array
    }
}


enum LoadDirection {
    case header
    case footer
}

extension UIScrollView{
    
    func beginRefresh(_ direction:LoadDirection){
        
        switch direction {
        case .header:
            self.mj_header?.beginRefreshing()
        default:
            self.mj_footer?.beginRefreshing()
        }
    }

    func endRefresh(_ direction:LoadDirection,isNoMoreData:Bool){
        switch direction {
        case .header:
            self.mj_header?.endRefreshing()
        case .footer:
            if isNoMoreData {
                self.mj_footer?.endRefreshingWithNoMoreData()
            }else{
                self.mj_footer?.endRefreshing()
            }
        }
    }

    func headerPublisher() -> AnyPublisher<Void,Never> {
        let ob = PassthroughSubject<Void,Never>()
        
//        bindHeadRefreshHandler({
//            ob.send(())
//        }, themeColor: #colorLiteral(red: 1, green: 0.7250000238, blue: 0.00800000038, alpha: 1), refreshStyle: .replicatorArc)

        return ob.eraseToAnyPublisher()
    }
    
    func footerPublisher() -> AnyPublisher<Void,Never> {
        let ob = PassthroughSubject<Void,Never>()
//        bindFootRefreshHandler({
//            ob.send(())
//        }, themeColor: #colorLiteral(red: 1, green: 0.7250000238, blue: 0.00800000038, alpha: 1), refreshStyle: .replicatorArc)

        return ob.eraseToAnyPublisher()
    }
}


//extension ListStore where T.Data == VideoVo {
//    
//    func reloadData(dto:TemplateDTO){
//        datas.replaceFirst(where: { $0.id_Photoverse == dto.id_Photoverse}, with: dto)
//    }
//}

extension Array {
    @discardableResult
    mutating func replaceFirst(where condition: (Element) -> Bool, with newElement: Element) -> Bool {
        guard let idx = firstIndex(where: condition) else { return false }
        replaceSubrange(idx...idx, with: [newElement])
        return true
    }
}

