//
//  ApiConst.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

enum APIError<T:Codable>:Error{
    /// 未知错误
    case unkown(error: any Error)
    /// http错误
    case http(code:Int,describe:String)
    /// 业务错误
    case bussiness(model:APIVo<T>)
    /// 转模型错误
    case mapModel(data:Data)
    
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
        }
    }
}

enum APIResult<T:Codable> {
    /// 业务成功
    case success(model:APIVo<T>)
    /// 错误
    case error(error:APIError<T>)
}

enum APICode:Int,Codable{
  /// 业务成功
  case success = 0
  /// token过期
  case accessTokenExpire = 10005
  /// 服务器开小差
  case other = 100011
}

struct APIVo<T:Codable>:Codable,WPSpaceProtocol{
    var data:T?
    var code:APICode?
    var message:String?
    var serverTime:String?
    var action:String?
}


struct APIEmpty:Codable{}
