////
////  InAppPurchase.swift
////  Movie
////
////  Created by tmb on 2026/8/11.
////
//
//import UIKit
//import Combine
//import WPCommand
//import StoreKit
//
//
// struct LastPurchaseVo:Codable,WPSpaceProtocol {
//    let isSubscribe:Bool
//    let transaction_origin_id:String
//    
//    init(isSubscribe: Bool, transaction_origin_id: String) {
//        self.isSubscribe = isSubscribe
//        self.transaction_origin_id = transaction_origin_id
//    }
//}
//
// class InAppPurchase:NSObject{
//    static var shared = InAppPurchase()
//
//    /// 上次购买商品
//    @WPPreference(wrappedValue: nil, key: "LastPurchaseProduct")
//    static var lastPurchaseVo:LastPurchaseVo?
//
//     /// 启动监听和验证（历史 + 新交易）
//    func startVIPListener() {
//        // 合并历史交易和新交易
//        Publishers.Merge(
//            InAppPurchase.currentEntitlementsPublisher(),
//            InAppPurchase.transactionUpdatesPublisher()
//        )
//        .flatMap { transaction -> AnyPublisher<Void, Never> in
//            print(transaction.originalID.description,"开始恢复订单")
//            return InAppPurchase.userVerifyTransactionPublisher(transaction)
//        }.sink { _ in
//            print("所有交易验证完成")
//        }.store(in: &wp.cancellables.set)
//    }
//
//    /// 恢复购买
//    static func restore() -> AnyPublisher<RestorableState, Never> {
//       return hasRestorableEntitlements().flatMap { isNot in
//           if isNot {
//               return AnyPublisher<InAppPurchase.RestorableState, Never>.wp.just(RestorableState.nothing)
//           }else{
//               return currentEntitlementsPublisher()
//                   .flatMap { transaction in
//                       print("恢复的商品ID---\(transaction.originalID.description)\(transaction.productType)")
//                      return userVerifyTransactionPublisher(transaction)
//                   }.map({_ in RestorableState.success}).eraseToAnyPublisher()
//           }
//       }.prepend(.processing).receive(on: DispatchQueue.main).eraseToAnyPublisher()
//    }
//    
//    /// 判断是否有可恢复订单
//     static func hasRestorableEntitlements() -> AnyPublisher<Bool, Never> {
//       Future<Bool, Never> { promise in
//           Task {
//               let first = await Transaction.currentEntitlements.first { _ in true }
//               // 如果有元素 → true，没有 → false
//               promise(.success(first == nil))
//           }
//       }
//       .eraseToAnyPublisher()
//    }
//
//    /// 加载商品
//     static func loadProducts(ids:[String]) -> AnyPublisher<[Product], Error> {
//
//       return AnyPublisher<[Product], Error>.wp.future({ ob in
//           Task {
//               do {
//                   let products = try await Product.products(for: ids)
//                   ob(.success(products))
//               } catch {
//                   ob(.failure(error))
//               }
//           }
//       })
//    }
//    
//    /// 购买商品
//     static func purchase(product: Product) -> AnyPublisher<PurchaseState, Never> {
//        print("🛒 开始购买商品: \(product.id)")
//
//       return AnyPublisher<Transaction, Error>.wp.future { promise in
//               Task {
//                   do {
//                       let result = try await product.purchase()
//                       switch result {
//                       case .success(let verification):
//                           switch verification {
//                           case .verified(let transaction):
//                               print("✅ 购买成功，交易ID: \(transaction.id)")
//                               // 测试代码
////                               Event.app_purchase(product, transaction).track()
////                               await transaction.finish()
//                               promise(.success(transaction))
//                               
//                           case .unverified(_, let error):
//                               print("❌ 交易验证失败: \(error)")
//                               promise(.failure(StoreError.verificationFailed(error)))
//                           }
//                           
//                       case .userCancelled:
//                           print("❌ 用户取消购买")
//                           promise(.failure(StoreError.userCancelled))
//                           
//                       case .pending:
//                           print("⏳ 等待用户确认")
//                           promise(.failure(StoreError.pending))
//                           
//                       @unknown default:
//                           print("❌ 未知错误")
//                           promise(.failure(StoreError.unknown))
//                       }
//                   } catch {
//                       print("❌ 购买失败: \(error)")
//                       promise(.failure(error))
//                   }
//               }
//        }
//        .map { .success(productId: $0.productID, transaction: $0) }
//        .catch { error -> Just<PurchaseState> in
//            if let storeError = error as? StoreError, storeError == .userCancelled {
//                return Just(.cancelled)
//            }
//            return Just(.failed(error))
//        }
//        .prepend(.processing)
//        .receive(on: DispatchQueue.main)
//        .eraseToAnyPublisher()
//    }
//    
//    ///根据商品ID购买（便捷方法）
//     static func purchase(productID: String) -> AnyPublisher<PurchaseState, Never> {
//        return loadProducts(ids: [productID])
//             .asRequest()
//            .flatMap { state -> AnyPublisher<PurchaseState, Never> in
//                switch state {
//                case .success(let products):
//                    if let product = products.first(where: { $0.id == productID }) {
//                        return self.purchase(product: product)
//                    } else {
//                        return Just(PurchaseState.failed(StoreError.productNotFound))
//                            .eraseToAnyPublisher()
//                    }
//                case .failure(let error):
//                    return Just(PurchaseState.failed(error))
//                        .eraseToAnyPublisher()
//                case .loading:
//                    return Just(PurchaseState.failed(StoreError.loading))
//                        .eraseToAnyPublisher()
//                }
//            }.receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//
//    /// MARK: - Publisher: 新交易监听
//    private static func transactionUpdatesPublisher() -> AnyPublisher<Transaction, Never> {
//        let subject = PassthroughSubject<Transaction, Never>()
//        Task.detached {
//            for await result in Transaction.updates {
//                do {
//                    let transaction = try await checkVerified(result)
//                    subject.send(transaction)
//                } catch {
//                    print("Transaction verification failed: \(error)")
//                }
//            }
//        }
//        return subject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
//    }
//
//    /// MARK: - Publisher: 历史交易（恢复购买）
//    private static func currentEntitlementsPublisher() -> AnyPublisher<Transaction, Never> {
//        let subject = PassthroughSubject<Transaction, Never>()
//        Task.detached {
//            for await result in Transaction.currentEntitlements {
//                do {
//                    let transaction = try await checkVerified(result)
//                    subject.send(transaction)
//                } catch {
//                    print("Current entitlement verification failed: \(error)")
//                }
//            }
//        }
//        return subject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
//    }
//
//    /// MARK: - 本地验证
//    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
//        switch result {
//        case .verified(let signed):
//            return signed
//        case .unverified:
//            throw NSError(domain: "StoreKit2", code: 1,
//                          userInfo: [NSLocalizedDescriptionKey: "Transaction unverified"])
//        }
//    }
//    
//
//}
//
// extension InAppPurchase{
//    enum RestorableState {
//      case processing
//      case nothing
//      case success
//    }
//    
//    enum PurchaseState {
//        case processing
//        case success(productId: String, transaction: Transaction)
//        case cancelled
//        case failed(Error)
//    }
//
//    enum StoreError: LocalizedError{
//        case productNotFound
//        case loading
//        case verificationFailed(Error)
//        case userCancelled
//        case pending
//        case unknown
//        
//        static func == (lhs: StoreError, rhs: StoreError) -> Bool {
//            switch (lhs, rhs) {
//            case (.productNotFound, .productNotFound):
//                return true
//            case (.loading, .loading):
//                return true
//            case (.userCancelled, .userCancelled):
//                return true
//            case (.pending, .pending):
//                return true
//            case (.unknown, .unknown):
//                return true
//            case (.verificationFailed, .verificationFailed):
//                // 简化处理，不比较关联的 Error
//                return true
//            default:
//                return false
//            }
//        }
//        
//         var errorDescription: String? {
//            switch self {
//            case .productNotFound:
//                return "未找到该商品"
//            case .loading:
//                return "商品正在加载中，请稍后再试"
//            case .verificationFailed(let error):
//                return "验证失败: \(error.localizedDescription)"
//            case .userCancelled:
//                return "用户取消购买"
//            case .pending:
//                return "等待用户确认"
//            case .unknown:
//                return "未知错误"
//            }
//        }
//    }
// }
//
//extension InAppPurchase {
//    
////    /// 验证vip是否有效
////   static func checkVip() -> AnyPublisher<Void,Never> {
////      if let locProduct = InAppPurchase.lastPurchaseProduct{
////          return ConfigApi.verification(original_transaction_id: locProduct.transaction_origin_id,
////              is_subscriptions: locProduct.isSubscribe)
////          .request()
////          .mapTo(APPVerificationModel.self)
////          .asResult()
////          .handleEvents(receiveOutput: { value in
////                  switch value {
////                  case .success(let model):
////                      print("Vip状态-\(model.status)")
////                      InAppPurchase.isVip = model.status
////                  default:
////                      break
////                  }
////          }).mapToVoid().eraseToAnyPublisher()
////      }else{
////          return Just(()).eraseToAnyPublisher()
////      }
////    }
//    
//    /// MARK: - Publisher: 服务器验证 + finish
//    private static func userVerifyTransactionPublisher(_ transaction: Transaction) -> AnyPublisher<Void, Never> {
//        print("验证订单")
//        
//        guard UserCenter.shared.userToken != nil else {
//            print("未登录---验单失败-")
//            return .wp.empty()
//        }
//        
//        /// 购买单片
//        if transaction.productType == .consumable{
//            if let locMediaVo = UserAPI.purchaseMedias.first(where: { $0.transactionId == transaction.id.description}){ // 本地要购买的订单
//                return UserAPI.verifyPurchase(vo: locMediaVo).request().handleEvents(receiveOutput: { _ in
//                    print("单片购买验证成功")
//                    
//                    Task{
//                        await transaction.finish()
//                        
//                        UserAPI.purchaseMedias.wp_filter(exclude: { $0.transactionId == transaction.id.description})
//                    }
//                    
//                }).asResult().toVoid()
//            }else{
//                return .wp.empty()
//            }
//        }else{ /// 持续订阅
//            return UserAPI.verifyPurchase(vo: .subscribe(transactionId: transaction.originalID.description,
//                                                         productId: transaction.productID)).request().handleEvents(receiveOutput: { _ in
//                print("订阅验证成功")
//                Task{
//                    await transaction.finish()
//                }
//                
//            }).asResult().toVoid()
//        }
//    }
//    
////    /// MARK: - Publisher: 服务器验证 + finish
////    private static func verifyTransactionPublisher(_ transaction: Transaction) -> AnyPublisher<Void, Never> {
////        print("验证订单")
////          return  ConfigApi.verification(
////                original_transaction_id: transaction.originalID.description,
////                is_subscriptions: transaction.productType != .nonConsumable
////            )
////          .request()
////          .mapTo(APPVerificationModel.self)
////            .asResult()
////            .receive(on: DispatchQueue.main)
////            .handleEvents(receiveOutput: { result in
////                switch result {
////                case .success(let model):
////                    if model.status {
////                        isVip = true
////                        InAppPurchase.lastPurchaseProduct = .init(isSubscribe: transaction.productType != .nonConsumable,
////                                                     transaction_origin_id: transaction.originalID.description)
////                        print("验单成功: \(transaction.id) finish掉了交易")
////                        Task { await transaction.finish() }
////                    }else{
////                        print("验单失败: \(transaction.id) 下次继续 finish")
////                    }
////                case .failure(_):
////                    print("交易验证失败 没有finish")
////                    break
////                }
////            }).mapToVoid().eraseToAnyPublisher()
////        }
//}
//
//extension InAppPurchase {
//   nonisolated struct APPVerificationModel:Codable,WPSpaceProtocol {
//        var status:Bool = false
//        /// 过期时间
//        var expiresDate:TimeInterval?
//        var msg:String?
//        var productId:String?
//    }
//}
//
//extension Decimal {
//    
//    /// 转换为保留两位小数的字符串（默认四舍五入）
//    /// - Returns: 格式化后的字符串，如 "123.46"
//    func toStringWithTwoDecimals() -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.minimumFractionDigits = 2
//        formatter.maximumFractionDigits = 2
//        formatter.roundingMode = .halfUp
//        return formatter.string(for: self) ?? "\(self)"
//    }
//    
//    /// 转换为保留指定位数小数的字符串
//    /// - Parameters:
//    ///   - fractionDigits: 小数位数
//    ///   - roundingMode: 舍入模式，默认四舍五入
//    /// - Returns: 格式化后的字符串
//    func toString(fractionDigits: Int, roundingMode: NumberFormatter.RoundingMode = .halfUp) -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.minimumFractionDigits = fractionDigits
//        formatter.maximumFractionDigits = fractionDigits
//        formatter.roundingMode = roundingMode
//        return formatter.string(for: self) ?? "\(self)"
//    }
//    
//    /// 转换为货币格式字符串（保留两位小数）
//    /// - Parameter currencyCode: 货币代码，默认 "CNY"
//    /// - Returns: 格式化后的货币字符串，如 "¥123.46"
//    func toCurrencyString(currencyCode: String = "$") -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencyCode = currencyCode
//        formatter.minimumFractionDigits = 2
//        formatter.maximumFractionDigits = 2
//        formatter.roundingMode = .halfUp
//        return formatter.string(for: self) ?? "\(self)"
//    }
//    
//    /// 四舍五入保留指定小数位数，返回新的 Decimal
//    /// - Parameter scale: 小数位数
//    /// - Returns: 四舍五入后的 Decimal
//    func rounded(scale: Int = 2) -> Decimal {
//        var value = self
//        var result = Decimal()
//        NSDecimalRound(&result, &value, scale, .plain)
//        return result
//    }
//    
//    /// 转换为字符串，不包含千位分隔符，保留两位小数
//    /// - Returns: 如 "123.46"
//    func toSimpleString() -> String {
//        let rounded = self.rounded(scale: 2)
//        return "\(rounded)"
//    }
//}
//
//extension Product {
//
//    func discountProportion() -> String {
//        let originalPrice = price
//        let discountPrice = subscription?.introductoryOffer?.price ?? .zero
//
//        guard originalPrice > 0 else {
//            return "0"
//        }
//
//        let savePrice = originalPrice - discountPrice
//
//        return savePrice
//            .divided(by: originalPrice)
//            .multiplied(by: 100)
//            .stringValue
//    }
//
//    /// 原始价格
//    var originalPrice: String {
//        return "\(getCurrencySymbol() ?? "$")\(price.stringValue)"
//    }
//
//    /// 是否有订阅优惠
//    var hasDiscount: Bool {
//        subscription?.introductoryOffer != nil
//    }
//
//    /// 优惠价格
//    var discountPrice: String? {
//        return "\(getCurrencySymbol() ?? "$")\(subscription?.introductoryOffer?.price.stringValue ?? "0")"
//    }
//
//    /// 优惠类型
//    var discountType: Product.SubscriptionOffer.PaymentMode? {
//        subscription?
//            .introductoryOffer?
//            .paymentMode
//    }
//    
//    func getCurrencySymbol() -> String? {
//        // 获取地区和货币
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.locale = self.priceFormatStyle.locale// 商品本地化信息
//        return formatter.currencySymbol
//    }
//
//}
//
//extension Decimal {
//    
//    func divided(by value: Decimal, scale: Int = 2) -> Decimal {
//        let result = NSDecimalNumber(decimal: self)
//            .dividing(by: NSDecimalNumber(decimal: value))
//        
//        return result.rounding(
//            accordingToBehavior: NSDecimalNumberHandler(
//                roundingMode: .plain,
//                scale: Int16(scale),
//                raiseOnExactness: false,
//                raiseOnOverflow: false,
//                raiseOnUnderflow: false,
//                raiseOnDivideByZero: true
//            )
//        ).decimalValue
//    }
//    
//    /// 转 String
//    var stringValue: String {
//        NSDecimalNumber(decimal: self).stringValue
//    }
//    
//    /// 乘法
//       func multiplied(by value: Decimal) -> Decimal {
//           NSDecimalNumber(decimal: self)
//               .multiplying(by: NSDecimalNumber(decimal: value))
//               .decimalValue
//       }
//}
//
//extension InAppPurchase {
//    struct Model {
//        let isDefaultSelected:Bool
//        let appProduct:AppProduct
//        let product:Product?
//        let isPlan:Bool
//        
//        func weekPrice() -> Decimal {
//            switch appProduct.type {
//            case .year:
//                return product?.price.advanced(by: .init(52)) ?? .init(0)
//            case .week:
//                return product?.price ?? .init(0)
//            }
//        }
//        
//        func title() -> String {
//            switch appProduct.type {
//            case .week:
//                return "Weekly".local()
//            case .year:
//                return "Yearly".local()
//            }
//        }
//        
//        func priceUnit() -> String {
//            switch appProduct.type {
//            case .week:
//                return "week".local()
//            case .year:
//                return "Year".local().lowercased()
//            }
//        }
//
//        func saveStr() -> String? {
//            if product?.hasDiscount == true{
//                return product?.discountProportion()
//            }else{
//                return nil
//            }
//        }
//
//    }
//}
//
//extension Publisher where Output == [Product] {
//    func toModels() -> AnyPublisher<[InAppPurchase.Model],Failure> {
//        
//        return flatMap { output in
//            return AnyPublisher<[InAppPurchase.Model],Failure>.wp.future { ob in
//                var models:[InAppPurchase.Model] = []
//                output.forEach { pro in
//                    if let appProduct = BaseConfig.config.inAppPurchases.first(where: { $0.id == pro.id}) {
//                        let model = InAppPurchase.Model.init(isDefaultSelected: appProduct.type == .week,
//                                                             appProduct: appProduct,
//                                                             product: pro,
//                                                             isPlan: appProduct.type == .year)
//
//                        models.append(model)
//                    }
//                }
//
//                let resualtModel = models.sorted { m1, m2 in
//                    return m1.weekPrice() < m2.weekPrice()
//                }
//                ob(.success(resualtModel))
//            }
//        }.eraseToAnyPublisher()
//    }
//}
