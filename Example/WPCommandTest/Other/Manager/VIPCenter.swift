//
//  VIPCenter.swift
//  WPCommand
//
//  Created by tmb on 2026/4/3.
//

import UIKit
import Combine
import WPCommand
import StoreKit

extension Bool: @retroactive WPSpaceProtocol{}

fileprivate var skuIds:[String] = [
    "vip_lifetime_xxxxxxx", // 永久vip
    "vip_weekly_anisamp4", // 周订阅
    "vip_month_anisamp4",
    "vip_year_anisamp4",
]

class VIPCenter:NSObject{
    static var `default` = VIPCenter()
    
    @WPRxPreference(wrappedValue: false, key: "isVIP")
    static var isVip:Bool

    /// 当前选中的商品
    @Published var selecteProduct:Product?
    
    /// 启动监听和验证（历史 + 新交易）
    func startVIPListener() {
        // 合并历史交易和新交易
        Publishers.Merge(
            VIPCenter.currentEntitlementsPublisher(),
            VIPCenter.transactionUpdatesPublisher()
        )
        .flatMap { transaction -> AnyPublisher<Void, Never> in
            return VIPCenter.verifyTransactionPublisher(transaction)
        }.sink { _ in
            print("所有交易验证完成")
        }.store(in: &wp.cancellables.set)
    }

    /// 恢复购买
   static func restorePurchases() -> AnyPublisher<RestorableState, Never> {
       return hasRestorableEntitlements().flatMap { isNot in
           if isNot {
               return AnyPublisher<VIPCenter.RestorableState, Never>.just(RestorableState.nothing)
           }else{
               return currentEntitlementsPublisher()
                   .flatMap { transaction in
                       verifyTransactionPublisher(transaction)
                   }.map({_ in RestorableState.success}).eraseToAnyPublisher()
           }
       }.prepend(.processing).eraseToAnyPublisher()
    }
    
    /// 判断是否有可恢复订单
   static func hasRestorableEntitlements() -> AnyPublisher<Bool, Never> {
       Future<Bool, Never> { promise in
           Task {
               let first = await Transaction.currentEntitlements.first { _ in true }
               // 如果有元素 → true，没有 → false
               promise(.success(first == nil))
           }
       }
       .eraseToAnyPublisher()
    }

    /// 加载商品
   static func loadProducts() -> AnyPublisher<LoadState<[Product]>, Never> {

      return AnyPublisher<[Product], Error>.create({ ob in
           Task {
               do {
                   let products = try await Product.products(for: skuIds)
                   ob(.success(products))
               } catch {
                   ob(.failure(error))
               }
           }
       }).map { .loaded($0) }
        .catch { error -> Just<LoadState<[Product]>> in
            Just(.failed(error))
        }
        .prepend(.loading)
        .eraseToAnyPublisher()
    }
    
    /// 购买商品
   static func purchase(product: Product) -> AnyPublisher<PurchaseState, Never> {
        print("🛒 开始购买商品: \(product.id)")

       return AnyPublisher<Transaction, Error>.create { promise in
               Task {
                   do {
                       let result = try await product.purchase()
                       
                       switch result {
                       case .success(let verification):
                           switch verification {
                           case .verified(let transaction):
                               print("✅ 购买成功，交易ID: \(transaction.id)")
                               await transaction.finish()
                               promise(.success(transaction))
                               
                           case .unverified(_, let error):
                               print("❌ 交易验证失败: \(error)")
                               promise(.failure(StoreError.verificationFailed(error)))
                           }
                           
                       case .userCancelled:
                           print("❌ 用户取消购买")
                           promise(.failure(StoreError.userCancelled))
                           
                       case .pending:
                           print("⏳ 等待用户确认")
                           promise(.failure(StoreError.pending))
                           
                       @unknown default:
                           print("❌ 未知错误")
                           promise(.failure(StoreError.unknown))
                       }
                   } catch {
                       print("❌ 购买失败: \(error)")
                       promise(.failure(error))
                   }
               }
        }
        .map { .success(productId: $0.productID, transaction: $0) }
        .catch { error -> Just<PurchaseState> in
            if let storeError = error as? StoreError, storeError == .userCancelled {
                return Just(.cancelled)
            }
            return Just(.failed(error))
        }
        .prepend(.processing)
        .eraseToAnyPublisher()
    }
    
    ///根据商品ID购买（便捷方法）
   static func purchase(productID: String) -> AnyPublisher<PurchaseState, Never> {
        return loadProducts()
            .flatMap { state -> AnyPublisher<PurchaseState, Never> in
                switch state {
                case .loaded(let products):
                    if let product = products.first(where: { $0.id == productID }) {
                        return self.purchase(product: product)
                    } else {
                        return Just(PurchaseState.failed(StoreError.productNotFound))
                            .eraseToAnyPublisher()
                    }
                case .failed(let error):
                    return Just(PurchaseState.failed(error))
                        .eraseToAnyPublisher()
                case .loading:
                    return Just(PurchaseState.failed(StoreError.stillLoading))
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    /// 获取验签参数（Combine 版本）
   static func getVerificationParams(from transaction: Transaction) -> AnyPublisher<[String: Any], Error> {
        // 获取收据
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "收据不存在"]))
                .eraseToAnyPublisher()
        }
        
        // 构建参数
        let params: [String: Any] = [
            "receipt_data": receiptData.base64EncodedString(),
            "transaction_id": String(transaction.id),
            "original_transaction_id": String(transaction.originalID),
            "product_id": transaction.productID,
            "purchase_date": Int(transaction.purchaseDate.timeIntervalSince1970),
            "expiration_date": transaction.expirationDate.map { Int($0.timeIntervalSince1970) } as Any,
            "environment": receiptURL.path.contains("sandbox") ? "sandbox" : "production"
        ]
        
        return Just(params)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    /// MARK: - Publisher: 新交易监听
    private static func transactionUpdatesPublisher() -> AnyPublisher<Transaction, Never> {
        let subject = PassthroughSubject<Transaction, Never>()
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await checkVerified(result)
                    subject.send(transaction)
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
        return subject.eraseToAnyPublisher()
    }

    /// MARK: - Publisher: 历史交易（恢复购买）
    private static func currentEntitlementsPublisher() -> AnyPublisher<Transaction, Never> {
        let subject = PassthroughSubject<Transaction, Never>()
        Task.detached {
            for await result in Transaction.currentEntitlements {
                do {
                    let transaction = try await checkVerified(result)
                    subject.send(transaction)
                } catch {
                    print("Current entitlement verification failed: \(error)")
                }
            }
        }
        return subject.eraseToAnyPublisher()
    }

    /// MARK: - 本地验证
    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let signed):
            return signed
        case .unverified:
            throw NSError(domain: "StoreKit2", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Transaction unverified"])
        }
    }
    
    /// MARK: - Publisher: 服务器验证 + finish
    private static func verifyTransactionPublisher(_ transaction: Transaction) -> AnyPublisher<Void, Never> {
        print("验证订单")
          return  Api.verificationVIP(
                original_transaction_id: transaction.originalID.description,
                bundleID: Bundle.main.bundleIdentifier ?? ""
            )
          .request(ADCenter.VerificationVo.self)
            .asResult()
            .handleEvents(receiveOutput: { result in
                switch result {
                case .success(let model):
                    if model.status {
                        isVip = true
                        print("验单成功: \(transaction.id) finish掉了交易")
                        Task { await transaction.finish() }
                    }else{
                        print("验单失败: \(transaction.id) 下次继续 finish")
                    }
                case .failure(_):
                    print("交易验证失败 没有finish")
                    break
                }
            }).mapToVoid()
        }
}

extension ADCenter {
   nonisolated struct VerificationVo:Codable,WPSpaceProtocol {
        var status:Bool = false
        /// 过期时间
        var expiresDate:TimeInterval?
        var msg:String?
        var productId:String?
    }
}

extension VIPCenter{
    enum RestorableState {
      case processing
      case nothing
      case success
    }
    
    enum PurchaseState {
        case processing
        case success(productId: String, transaction: Transaction)
        case cancelled
        case failed(Error)
    }

    enum StoreError: LocalizedError,Equatable {
        case productNotFound
        case stillLoading
        case verificationFailed(Error)
        case userCancelled
        case pending
        case unknown
        
        static func == (lhs: StoreError, rhs: StoreError) -> Bool {
            switch (lhs, rhs) {
            case (.productNotFound, .productNotFound):
                return true
            case (.stillLoading, .stillLoading):
                return true
            case (.userCancelled, .userCancelled):
                return true
            case (.pending, .pending):
                return true
            case (.unknown, .unknown):
                return true
            case (.verificationFailed, .verificationFailed):
                // 简化处理，不比较关联的 Error
                return true
            default:
                return false
            }
        }
        
        var errorDescription: String? {
            switch self {
            case .productNotFound:
                return "未找到该商品"
            case .stillLoading:
                return "商品正在加载中，请稍后再试"
            case .verificationFailed(let error):
                return "验证失败: \(error.localizedDescription)"
            case .userCancelled:
                return "用户取消购买"
            case .pending:
                return "等待用户确认"
            case .unknown:
                return "未知错误"
            }
        }
    }
    
    enum LoadState<T> {
        case loading
        case loaded(T)
        case failed(Error)
    }
}

extension Decimal{
    func doubleValue() -> Double {
       return (self as NSDecimalNumber).doubleValue
    }
}

extension Product{
    func weekMoney(in weekProduct:Product) -> Double {
        if self.id.contains("week"){
            return price.doubleValue()
        }else if self.id.contains("month"){
            return price.doubleValue() / 4.0
        } else if self.id.contains("year"){
            return price.doubleValue() / 52.0
        }else{
            return 0
        }
    }
    
    func getCurrencySymbol() -> String? {
        // 获取地区和货币
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceFormatStyle.locale // 商品本地化信息
        return formatter.currencySymbol
    }
}

