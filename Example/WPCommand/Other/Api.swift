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
import HandyJSON
import WPCommand
import Alamofire
import SystemConfiguration


public class CommonDescribeString {
    public static var netErrorStr = "无网络连接"
    public static var netApiErrorStr = "接口错误"
}

fileprivate var isLoadNewToken = false

public protocol Api: TargetType {
    /// 默认添加的header参数
    var baseHeader: [String: String] { get }
    /// 可自定义header参数
    var newHeader: [String: String] { get }
    /// 网络请求结果
    func request(loading:Bool,isHud:Bool,interceptRefToken:Bool,isDebug:Bool,networkingError:(()->Void)?) -> Observable<Result<Response, MoyaError>>
}

public struct ApiErrorCode{
    /// token过期
    static var token = 100424
    /// reftoken过期
    static var refreshToken = 500432
}

public struct ApiError<T:Observable<Result<Response, MoyaError>>>:Error{
    let code:Int
    let desc:String
    let ob:T
}

public struct ApiResualt<T: HandyJSON>: HandyJSON, LocalizedError {
    public init() {}

    public init(message:String? = "") {
        self.message = message
    }
    public var code: Int = 2000 // 网络错误
    public var data:T?
    public var message: String?
    public var messageKey:String?
}


public extension ObservableType where Element == Result<Response, MoyaError> {
    /// 结果转模型
    /// - Parameter _: 模型
    /// - Returns: 结果
    func model<T: HandyJSON>(_: T.Type = ApiEmpty.self) -> Observable<ApiResualt<T>> {
        return flatMap { elmt in
            Observable.create { ob in
                switch elmt {
                case .success(let resp):
                    if resp.statusCode == 200{
                        let dict = try? JSONSerialization.jsonObject(with: resp.data)
                        if let model = JSONDeserializer<ApiResualt<T>>.deserializeFrom(dict: dict as? NSDictionary){
                            ob.onNext(model)
                            ob.onCompleted()
                        }else{
                            var model = ApiResualt<T>()
                            model.message = "解析模型失败"
                            ob.onNext(model)
                            ob.onCompleted()
                        }
                    }else{
                        let dict = try? JSONSerialization.jsonObject(with: resp.data)
                        var model = ApiResualt<T>()
                        model.message = "接口错误-\(resp.statusCode)"
                        ob.onNext(model)
                        ob.onCompleted()
                    }
                case .failure(let error):
                    var model = ApiResualt<T>()
                    model.message = error.errorDescription
                    ob.onNext(model)
                    ob.onCompleted()
                }
                return Disposables.create()
            }
        }
    }
    
    /// 请求结果
    /// - Parameters:
    ///   - model: 模型
    ///   - showErrorToast: 是否显示错误toast
    ///   - code: 小于code码的都会显示toast
    /// - Returns: 结果
    func resualt<T: HandyJSON>(_ model: T.Type = ApiEmpty.self,
                             showErrorToast: Bool = true,
                             code: ClosedRange<Int> = 200...200,
                             obErr:Bool = false) -> Observable<ApiResualt<T>>{
        
        return self.model(model).flatMap({ model in
            
            if showErrorToast && model.code != ApiErrorCode.token && model.code != ApiErrorCode.refreshToken && model.code != 200{
                let msg =  (model.messageKey?.count ?? 0 <= 0) ? CommonDescribeString.netApiErrorStr : model.message
                UIViewController.wp.current?.view.wp.toast(msg?.wp.attributed.value())
            }
            if model.code == ApiErrorCode.token{
                return Observable<ApiResualt<T>>.error(ApiError(code: ApiErrorCode.token, desc: "token过期", ob: self as! Observable<Result<Response, MoyaError>>))
            }else if(model.code == ApiErrorCode.refreshToken){
//                UserManager.shared.carshLogin()
                
                return Observable<ApiResualt<T>>.empty()
            }else{
                if model.code >= code.lowerBound && model.code <= code.upperBound{
                    return Observable<ApiResualt<T>>.just(model)
                }else{
                    if obErr{
                        return Observable<ApiResualt<T>>.error(model)
                    }else{
                        return Observable<ApiResualt<T>>.empty()
                    }
                }
            }
        }).catch({ error in
            
            if let err = error as? ApiError{
                if err.code == ApiErrorCode.token && !isLoadNewToken{
                    isLoadNewToken = true
//                    return UserManager.refreshToken(showErrorToast: showErrorToast).do(onNext: { _ in
//                        isLoadNewToken = false
//                    },onError: { _ in
//                        isLoadNewToken = false
//                    },onCompleted: {
//                        isLoadNewToken = false
//                    },onDispose: {
//                        isLoadNewToken = false
//                    }).flatMap { _ in
//                        return (err as! ApiError).ob.resualt(T.self,showErrorToast:showErrorToast)
//                    }
                    return .empty()
                }
            }
            return Observable.error(error)
        }).observe(on: MainScheduler.instance)
    }
}

public extension Api {

    func request(loading:Bool = false,
                 isHud:Bool = false,
                 interceptRefToken:Bool = false,
                 isDebug:Bool = false,
                 networkingError:(()->Void)? = nil) -> Observable<Result<Response, MoyaError>> {
        return Observable<Bool>.just(Self.isNetworking()).do(onNext: { value in
            if !value{
//                Toast.show(CommonDescribeString.netErrorStr)
            }
            if !value{
                networkingError?()
            }
        }).filter({ $0}).flatMap { _ in
            if loading{
//                Toast.loding()
//                Toast.loding(isHud: isHud)
            }
            return Observable<Result<Response, MoyaError>>.create { ob in
                MoyaProvider<Self>().request(self, completion: { resualt in
                    if loading{
//                        Toast.hidden(isHud: isHud)
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
                            let str = "hhhhhhhhhhhhhhhhhhhhhhhhhhhh\n\npath:    \(path)\n\n header:    \(header)\n\n method:    \(method)\n\n task:   \(task)"
                            print(str)
                            let dict = try? JSONSerialization.jsonObject(with: resp.data)
                            print("eeeeeeeeeeee\n\n\n\n\(dict)\n\n\neeeeeeeeeeee")
                            
                        default:
                            break
                        }
                    }
                })
                return Disposables.create()
            }
        }
    }

    var newHeader: [String: String] {
        return [:]
    }

    var baseHeader: [String: String] {
        return [:]
    }

    var baseURL: URL {
        return URL.init(string: "https://")!
    }

    var headers: [String: String]? {
        var dict: [String: String] = [:]

        newHeader.forEach { obj in
            dict[obj.key] = obj.value
        }

        baseHeader.forEach { obj in
            dict[obj.key] = obj.value
        }

        return dict
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

public extension [String: Any] {
    mutating func safeSet(_ key: String, value: Any?) {
        if let value = value {
            self[key] = value
        }
    }
    
    func get<T>(_ key:String) -> T? {
        return self[key] as? T
    }
}

public extension [String: String] {
    mutating func safeSet(_ key: String, value: String?) {
        if let value = value {
            self[key] = value
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

public extension HandyJSON{
    static func wp_deserialize(_ dict: [String:Any]?)-> Self?{
        return JSONDeserializer<Self>.deserializeFrom(dict: dict)
    }
}

extension Int: @retroactive _ExtendCustomModelType {}
extension Int:@retroactive HandyJSON{}
extension Array: @retroactive _ExtendCustomModelType {}
extension Array:@retroactive HandyJSON{}
extension Double: @retroactive _ExtendCustomModelType {}
extension Double:@retroactive HandyJSON{}
extension String: @retroactive _ExtendCustomModelType {}
extension String:@retroactive HandyJSON{}
extension Dictionary: @retroactive _ExtendCustomModelType {}
extension Dictionary:@retroactive HandyJSON{}
/// 默认空模型
public struct ApiEmpty: HandyJSON {
    public init() {}
}
