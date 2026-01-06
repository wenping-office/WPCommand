//
//  ApiConst.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand
import Alamofire

enum ApiError<T:Codable>:Error{
    /// 未知错误
    case unkown(error: any Error)
    /// http错误
    case http(code:Int,describe:String)
    /// 业务错误
    case bussiness(model:ApiVo<T>)
    /// 转模型错误
    case mapModel(data:Data)
    
    case emptyData
    
    var localizedDescription:String{
        switch self {
        case .unkown(let error):
            return error.localizedDescription
        case .http(_,let describe):
            return describe
        case .mapModel(_):
            return "Model conversion error"
        case .bussiness(let model):
            return model.message ?? ""
        case .emptyData:
            return "empty data"
        }
    }
}

enum ApiResult<T:Codable> {
    /// 业务成功
    case success(model:ApiVo<T>)
    /// 错误
    case error(error:ApiError<T>)
}

enum ApiCode:Int,Codable{
  /// 业务成功
  case success = 0
  /// token过期
  case tokenExpire = 10005
  /// 服务器开小差
  case other = 100011
}

struct ApiVo<T:Codable>:Codable,WPSpaceProtocol{
    var data:T?
    var code:ApiCode?
    var message:String?
    var serverTime:String?
    var action:String?
}


struct ApiEmpty:Codable{}
