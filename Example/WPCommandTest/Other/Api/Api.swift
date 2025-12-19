//
//  Api.swift
//  WPCommand_Example
//
//  Created by 1234 on 2024/12/7.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Moya
import RxCocoa
import RxSwift
import WPCommand
import Alamofire
import SystemConfiguration

private let APIProvider = MoyaProvider<API>()

enum API{
    case login
}

extension API:TargetType{
    var baseURL: URL {
        return URL.init(string: "")!
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Moya.Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
}


extension API{
    func request<T:Decodable>(_ model:T.Type) -> Single<APIResult<T>> {
        let observe = Single<APIResult<T>>.create { ob in
            APIProvider.request(self) { result in
                switch result{
                case .success(let resp):
                    guard resp.statusCode == 200 else {
                        print("Http错误---\(resp.statusCode)")
                        return ob(.success(.error(error: .http(code: resp.statusCode, describe: resp.description))))
                    }
                    guard let model = try? APIVo<T>.wp.map(jsonData: resp.data) else {
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
        return observe
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

struct JSONArrayEncoding: ParameterEncoding {
    static let `default` = JSONArrayEncoding()
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        guard let json = parameters?["jsonArray"] else {
            return request
        }
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.httpBody = data
        return request
    }
}

struct JSONArrayGetEncoding: ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try URLEncoding().encode(urlRequest, with: parameters)
        request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))
        return request
    }
}
