//
//  Combine+Api.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/12/23.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Moya
import Combine
import RxSwift

let APPProvider = MoyaProvider<Api>()

enum Api{
    case login
}

extension Api:TargetType{
    var baseURL: URL {
        return URL.init(string: "")!
    }
    
    var path: String {
        switch self {
        case .login:
            return "/user/login"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Moya.Task {
        var parms = [String:Any]()
        return .requestParameters(parameters: parms, encoding: JSONEncoding.default)
    }
    
    var headers: [String : String]? {
        var parms = [String:String]()
        return parms
    }
}

extension MoyaProvider {
    func requestPublisher<T: Codable>(_ target: Target,model:T.Type) -> AnyPublisher<ApiVo<T>, ApiError<T>> {
        Future<ApiVo<T>, ApiError<T>> { promise in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    guard response.statusCode == 200 else {
                        return promise(.failure(.http(code: response.statusCode, describe: response.description)))
                    }
                    do {
                        let model = try ApiVo<T>.wp.map(jsonData: response.data)
                        if model.code == .success {
                            promise(.success(model))
                        }else{
                            promise(.failure(.bussiness(model: model)))
                        }
                    } catch {
                        promise(.failure(.mapModel(data: response.data)))
                    }
                case .failure(let error):
                    promise(.failure(.unkown(error: error)))
                }
            }
        }.eraseToAnyPublisher()
    }
}


extension Api{
    func request<T: Codable>(_ model: T.Type = ApiEmpty.self) -> AnyPublisher<ApiVo<T>, ApiError<T>> {
        APPProvider.requestPublisher(self, model: model)
            .catch { error -> AnyPublisher<ApiVo<T>, ApiError<T>> in
                if case .bussiness(let model) = error, model.code == .tokenExpire {
                    return UserCenter.login().mapError({ loginErr in
                        return error
                    }).flatMap { _ in
                        return APPProvider.requestPublisher(self, model: T.self)
                    }.catch { loginError in
                        Fail(error: error).eraseToAnyPublisher()
                    }.eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}



extension Publisher {
    
    func asApiResult<T>() -> AnyPublisher<ApiResult<T>, Never>
    where Output == ApiVo<T>, Failure == ApiError<T> {
        return map { vo in
                ApiResult.success(model: vo)
            }
            .catch { error in
                Just(ApiResult.error(error: error))
            }
            .eraseToAnyPublisher()
    }
    
    func unwrapApiResult<T>() -> AnyPublisher<T, ApiError<T>>
    where Output == ApiResult<T>, Failure == Never {
        return flatMap { result -> AnyPublisher<T, ApiError<T>> in
                switch result {
                case .success(let model):
                    guard let data = model.data else {
                        return Fail(error: ApiError<T>.emptyData)
                            .eraseToAnyPublisher()
                    }

                    return Just(data)
                        .setFailureType(to: ApiError<T>.self)
                        .eraseToAnyPublisher()
                    
                case .error(let error):
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

}

extension Api{
    func rxRequest<T:Decodable>(_ model:T.Type) -> Single<ApiResult<T>> {
        let observe = Single<ApiResult<T>>.create { ob in
            APPProvider.request(self) { result in
                switch result{
                case .success(let resp):
                    guard resp.statusCode == 200 else {
                        print("Http错误---\(resp.statusCode)")
                        return ob(.success(.error(error: .http(code: resp.statusCode, describe: resp.description))))
                    }
                    guard let model = try? ApiVo<T>.wp.map(jsonData: resp.data) else {
                        print("转模型错误")
                       return ob(.success(.error(error: .mapModel(data: resp.data))))
                    }
                    guard model.code == .success else {
                        print("业务错误\(model)")
                        return ob(.success(.error(error: .bussiness(model: model))))
                    }
                    ob(.success(.success(model: model)))
                case .failure(let error):
                    ob(.success(.error(error: .unkown(error: error))))
                }
            }
            return Disposables.create()
        }
        return observe.flatMap { res in
            guard case .error(let error) = res else {
                return .just(res)
            }

            guard case .bussiness(let model) = error else {
                return .just(res)
            }

            guard model.code == .tokenExpire else {
                return .just(res)
            }
            
            return UserCenter.login()
                .flatMap { loginRes in
                    guard case .success = loginRes else {
                        return .just(res)
                    }
                    return observe
            }
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    func value() async throws -> Element {
        try await withCheckedThrowingContinuation { continuation in
            _ = self.subscribe(
                onSuccess: { continuation.resume(returning: $0) },
                onFailure: { continuation.resume(throwing: $0) }
            )
        }
    }
}
