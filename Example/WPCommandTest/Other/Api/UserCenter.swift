//
//  UserCenter.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/12/23.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Combine
import CombineExt
import WPCommand
import RxSwift

struct UserDTO:Codable,WPSpaceProtocol {
    var refreshToken:String?
}

class UserCenter {
    
    static var current:UserDTO? = nil
    
    static var isLogin:Bool{
        return false
    }
    
    static func login() ->  AnyPublisher<ApiVo<UserDTO>,ApiError<UserDTO>> {
        return APPProvider.requestPublisher(Api.login, model: UserDTO.self).handleEvents(receiveOutput: { res in
            self.current = res.data
        }).eraseToAnyPublisher()
    }


    static func initLogin(_ window: UIWindow) {
        if isLogin {
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
        }else{
            let loginVC = LoginPlaceholderVC()
            loginVC.resetBtn.isHidden = true
            window.rootViewController = loginVC
            window.makeKeyAndVisible()

            Task{ @MainActor in
                do{
                    let _ = try await login().asAwait()
                    window.rootViewController = UIViewController()
                }catch{
                    loginVC.label.text = "登录失败"
                    loginVC.resetBtn.isHidden = false
                    loginVC.resetAction = {
                        self.initLogin(window)
                    }
                }
            }
        }
    }

}

extension UserCenter{
   static func login() -> Single<ApiResult<UserDTO>> {
        return Api.login.rxRequest(UserDTO.self).do(onSuccess: { res in
            guard case .success(let model) = res else {
                return
            }
            current = model.data
        })
    }

   static func initLogin(_ window:UIWindow) -> Single<Void>{
        if UserCenter.isLogin{
            let loginVC = LoginPlaceholderVC()
//            loginVC.view.showLoading()
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
            return .just(())
        }else{
            let loginVC = LoginPlaceholderVC()
//            loginVC.view.showLoading()
            window.rootViewController = loginVC
            window.makeKeyAndVisible()

            return login().flatMap { res in
                switch res{
                case .success(_):
                    return .just(())
                case .error(let error):
                    return .error(error)
                }
            }.retry(when: { errors in
                return errors.enumerated().flatMap { attempt, error in
                    if attempt >= 4 {
                        return Observable<Void>.error(error)
                    }
                    return Observable<Void>.just(())
                        .delay(.seconds(2), scheduler: MainScheduler.instance)
                }
            }).delay(.milliseconds(500), scheduler: MainScheduler.instance).subscribe(on: MainScheduler.asyncInstance).do(onSuccess: {
//                window.rootViewController = UIViewController()
            },onError: { error in
//                loginVC.view.showEmpty(title: error.localizedDescription,tapAction: {
//                    Task{ @MainActor in
//                       try? await UserCenter.default.initLogin(window).value()
//                    }
//                })
            })
        }
    }
}

class LoginPlaceholderVC: UIViewController {
    let label = UILabel()
    let resetBtn = UIButton()
    
    var resetAction:(()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetBtn.setTitle("重试", for: .normal)
        resetBtn.setTitleColor(.black, for: .normal)

        label.text = "登录中"
        label.textColor = .black
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(resetBtn)
        resetBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom)
        }
        
        resetBtn.controlEventPublisher(for: .touchUpInside).sink(receiveValue: {[weak self] in
            self?.resetAction?()
        }).store(in: &wp.cancellables.set)
        view.backgroundColor = .white
    }
}
