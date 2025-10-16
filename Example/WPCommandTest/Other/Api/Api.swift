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

public protocol Api: TargetType {
    /// 发起请求
    func request(loading:Bool,
                 isHud:Bool,
                 isDebug:Bool,
                 networkingError:(()->Void)?) -> Observable<Result<Response, MoyaError>>
}

public extension Api {

    func request(loading:Bool = false,
                 isHud:Bool = false,
                 isDebug:Bool = false,
                 networkingError:(()->Void)? = nil) -> Observable<Result<Response, MoyaError>> {
        return Observable<Bool>.just(Self.isNetworking()).do(onNext: { value in
            if !value{
                UIApplication.wp.keyWindow?.wp.toast("没有网络".wp.attributed.value())
            }
            if !value{
                networkingError?()
            }
        }).filter({ $0}).flatMap { _ in
            if loading{
                UIApplication.wp.keyWindow?.wp.loading(is: true)
            }
            return Observable<Result<Response, MoyaError>>.create { ob in
                MoyaProvider<Self>().request(self, completion: { resualt in
                    if loading{
                        UIApplication.wp.keyWindow?.wp.loading(is: false)
                    }
                    ob.onNext(resualt)
                    ob.onCompleted()
                    
                    if isDebug{
                        switch resualt {
                        case .success(let resp):
                            let path = self.baseURL.absoluteString + self.path
                            let task = self.task
                            let header = self.headers
                            let method = self.method
                            let str = "-------------------------------\n\npath:    \(path)\n\n header:    \(String(describing: header))\n\n method:    \(method)\n\n task:   \(task)"
                            print(str)
                            let dict = try? resp.data.wp.toJson()
                            print("-------------------------------\n\n\n\n\(String(describing: dict))\n\n\n-------------------------------")
                            
                        default:
                            break
                        }
                    }
                })
                return Disposables.create()
            }
        }
    }
}


public extension ObservableType where Element == Result<Response, MoyaError> {
    /// 结果转模型
    /// - Parameter _: 模型
    /// - Returns: 结果
    func model<T: Codable & WPSpaceProtocol>(_: T.Type = ApiEmpty.self) -> Observable<ApiResualt<T>> {
        return flatMap { elmt in
            Observable.create { ob in
                switch elmt {
                case .success(let resp):
                    if resp.statusCode == 200{
                        do{
                            let model = try ApiResualt<T>.wp.map(jsonData: resp.data)
                            ob.onNext(model)
                            ob.onCompleted()
                        }catch{
                            ob.onError(error)
                        }
                    }else{ // 接口请求错误

                    }
                case .failure(let error):
                    ob.onError(error)
                }
                return Disposables.create()
            }
        }
    }
}

public extension Api{
    static func isNetworking()->Bool{
        var zeroAddress = sockaddr_storage()
        zeroAddress.ss_len = __uint8_t(MemoryLayout<sockaddr_storage>.size)
        zeroAddress.ss_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }else{
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
     
            if isReachable && !needsConnection{
                return true
            }else{
                return false
            }
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
