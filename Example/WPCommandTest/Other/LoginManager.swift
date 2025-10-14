//
//  LoginManager.swift
//  WPCommand_Example
//
//  Created by 1234 on 2024/12/17.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

/*
import UIKit
import RxSwift
import RxCocoa
import AuthenticationServices
import WPCommand
import CryptoKit
import FirebaseCore
import GoogleSignIn
import FirebaseAuth

extension String: Error{
    
}

class UserManager: NSObject {

    static let shared = UserManager()

    let token = BehaviorRelay<String>.init(value: "")
    
    let crrent = BehaviorRelay<UserModel?>.init(value: nil)
    
    private var appleLoginSuccessBlock:((String)->Void)?
    private var appleLoginErrorBlock:((String)->Void)?

    private var currentNonce:String?

    
    func appleLogin() -> Observable<UserModel> {
        return Observable<String>.create {[weak self] ob in
            self?.startSignInWithAppleFlow()

            self?.appleLoginErrorBlock = { str in
                Toast.show(str)
            }
            self?.appleLoginSuccessBlock = { token in
                ob.onNext(token)
                ob.onCompleted()
            }

            return Disposables.create()
        }.flatMap { token in
            return BBApi.authLogin(idToken: token, loginType: 2).request(loading: true,isHud: true).resualt(UserModel.self).map({ $0.data ?? .init()}).do(onNext: {[weak self] user in
                self?.crrent.accept(user)
            })
        }
    }
    
    func gooleLogin() -> Observable<UserModel> {
        return UserManager.startGooleLogin().catch({ error in
            Toast.show(error.localizedDescription)
            return .empty()
        }).flatMap { idToken in
            return BBApi.authLogin(idToken: idToken, loginType: 1).request(loading: true,isHud: true).resualt(UserModel.self).map({ $0.data ?? .init()}).do(onNext: {[weak self] user in
                self?.crrent.accept(user)
            })
        }
    }
}


extension UserManager{
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
}

extension UserManager:ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding{


    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIViewController.wp.current!.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          
        guard let nonce = currentNonce else {
            appleLoginErrorBlock?("Invalid state: A login callback was received, but no login request was sent")
            return
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            appleLoginErrorBlock?("无法获取身份令牌")
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            appleLoginErrorBlock?("无法从数据中序列化令牌字符串")
          return
        }
        // 初始化Firebase凭据，包括用户的全名。
        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                          rawNonce: nonce,
                                                          fullName: appleIDCredential.fullName)
        // Sign in with Firebase.
          Toast.loding(isHud: true)
        Auth.auth().signIn(with: credential) {[weak self] (authResult, error) in

            if let error = error{
                Toast.hidden(isHud: true)
                self?.appleLoginErrorBlock?(error.localizedDescription)
            }else{
                let currentUser = Auth.auth().currentUser
                currentUser?.getIDTokenForcingRefresh(true, completion: {[weak self] idToken, error in
                    Toast.hidden(isHud: true)
                    if let error = error{
                        self?.appleLoginErrorBlock?(error.localizedDescription)
                    }else if let idToken = idToken{
                        self?.appleLoginSuccessBlock?(idToken)
                    }
                })
            }
        }
      }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 登录过程中出现错误，可以在这里处理错误情况
        print("Apple Login Error: \(error.localizedDescription)")
//        appleLoginErrorBlock?(error.localizedDescription)
    }
}


extension UserManager{
    private static func startGooleLogin() -> Observable<String>{
        return Observable.create { ob in
            Toast.loding(isHud: true)
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: FirebaseApp.app()?.options.clientID ?? "")
            GIDSignIn.sharedInstance.signIn(withPresenting: .wp.current!) {result, error in
                
                if let error = error{
                    Toast.hidden(isHud: true)
                }else{
                    if  let user = result?.user,let idTokenString = user.idToken?.tokenString {
                        
                        let credential = GoogleAuthProvider.credential(withIDToken: idTokenString,
                                                                     accessToken: user.accessToken.tokenString)
                        
                        Auth.auth().signIn(with: credential) { result, error in

                            let currentUser = Auth.auth().currentUser
                            currentUser?.getIDTokenForcingRefresh(true, completion: { idToken, error in
                                Toast.hidden(isHud: true)
                                if let error = error{
                                    ob.onError(error)
                                }else{
                                    ob.onNext(idToken ?? "")
                                }
                                ob.onCompleted()
                            })
                        }
                    
                    }else{
                        Toast.hidden(isHud: true)
                        ob.onError("idTokenString为空")
                        ob.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}
*/
