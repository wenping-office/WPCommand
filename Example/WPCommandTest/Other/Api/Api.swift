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



import Alamofire
import UniformTypeIdentifiers
extension Api{

   static func download(from url: URL,
                        fileName: String = Date().timeIntervalSince1970.description,
                        progress: ((Double) -> Void)? = nil) -> AnyPublisher<URL,Error> {
       return .create { ob in
          let request = download(from: url, fileName: fileName,progress: progress ,completion: { res in
              switch res {
              case .success(let url):
                  ob.send(url)
              case .failure(let error):
                  ob.send(completion: .failure(error))
              }
           })
           return AnyCancellable{
               request.cancel()
           }
       }
    }

   fileprivate static func download(
        from url: URL,
        fileName: String,
        directory: FileManager.SearchPathDirectory = .cachesDirectory,
        progress: ((Double) -> Void)? = nil,
        completion: @escaping (Result<URL, Error>) -> Void) -> DownloadRequest {

        let destination: DownloadRequest.Destination = { _, response in

            let baseURL = FileManager.default
                .urls(for: directory, in: .userDomainMask)
                .first!

            // 1️⃣ 优先用服务器建议的文件名扩展
            let suggestedExt = response.suggestedFilename?
                .split(separator: ".")
                .last
                .map(String.init)

            // 2️⃣ 再用 MIME 推断
            let mimeExt: String? = {
                guard let mime = response.mimeType else { return nil }
                if #available(iOS 14.0, *) {
                    return UTType(mimeType: mime)?.preferredFilenameExtension
                }
                return nil
            }()

            let ext = suggestedExt ?? mimeExt ?? "dat"

            let fileURL = baseURL
                .appendingPathComponent(fileName)
                .appendingPathExtension(ext)

            return (
                fileURL,
                [.removePreviousFile, .createIntermediateDirectories]
            )
        }

        let request = AF.download(url, to: destination)

        request.downloadProgress { p in
            progress?(p.fractionCompleted)
        }

        request.response { response in
            if let error = response.error {
                completion(.failure(error))
                return
            }

            guard let fileURL = response.fileURL else {
                completion(.failure(NSError(
                    domain: "DownloadTool",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing file URL"]
                )))
                return
            }

            completion(.success(fileURL))
        }

        return request
    }
}

