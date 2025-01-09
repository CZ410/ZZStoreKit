//
//  ZZStoreKit_V2.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2024/12/31.
//
import StoreKit

@available(iOS 15.0, *)
class ZZStoreKit_V2: NSObject{
    
    static let share = ZZStoreKit_V2()
    
    enum PurchaseStatus{
        case success, canceled, pending, unowned
    }
    
    var complateTranscationCallbacks: ((_ transactions: [VerificationResult<Transaction>]) -> Void)?
    private var updateListenerTask: Task<Void, Error>? = nil // 支付事件监听
    override init() {
        super.init()
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    /// 获取商品信息
    /// - Parameters:
    ///   - ids: 商品ProductIdentifier
    ///   - block:  回调
    func getProducts(_ ids: [String]) async throws -> [Product]{
        let products = try await Product.products(for: Set(ids))
        return products
    }
    
    /// 购买一个商品
    /// - Parameters:
    ///   - product: 商品 product
    ///   - quantity: 数量
    ///   - applicationUsername: applicationUsername description
    ///   - isSandbox: 是否沙盒
    ///   - block: 回调
    func buyProduct(
        _ product: Product,
        quantity: Int = 1,
        applicationUsername: String? = nil,
        appAccountToken: UUID? = nil,
        isSandbox: Bool = false
    ) async throws -> (VerificationResult<Transaction>?, PurchaseStatus) {
        var options: Set<Product.PurchaseOption> = [.quantity(quantity), .simulatesAskToBuyInSandbox(isSandbox)]
        if let applicationUsername = applicationUsername{
            options.insert(.custom(key: "applicationUsername", value: applicationUsername))
        }
        if let appAccountToken = appAccountToken{
            options.insert(.appAccountToken(appAccountToken))
        }
        let result = try await product.purchase(options: options)
        
        switch result {
            case .success(let verification):
//                let transaction = try checkVerified(verification)
                
//                //Deliver content to the user.
//                await updatePurchasedIdentifiers(transaction)
//                
//                //Always finish a transaction.
//                await transaction.finish()
                
                return (verification, .success)
            case .userCancelled:
                return (nil, .canceled)
            case .pending:
                return (nil, .pending)
            default:
                return (nil, .unowned)
        }
    }
    
    /// 结束订单
    /// - Parameter transaction: 订单信息 buyProduct 回调中获取
    func finishedTransaction(_ transaction: Transaction) async {
        await transaction.finish()
    }
    
    /// 恢复购买
    /// - Parameters:
    ///   - applicationUsername: applicationUsername description
    ///   - block: 回调
    func restore() async throws{
       try await AppStore.sync()
    }
    
    /// 处理未完成订单
    /// - Parameter block: 回调
    func complateTransaction(complate block: ((_ verificationResults: [VerificationResult<Transaction>]) -> Void)? = nil){
        complateTranscationCallbacks = block
    }
    
    /// 未完成支付监听事件
    private func listenForTransactions() -> Task<Void, Error>{
        return Task.detached {
            //Iterate through any transactions which didn't come from a direct call to `purchase()`.
            var verifications: [VerificationResult<Transaction>] = []
            for await result in Transaction.updates {
//            for await result in Transaction.unfinished {
                verifications.append(result)
//                do {
//                    let transaction = try self.checkVerified(result)
//                    
//                    //Deliver content to the user.
////                    await self.updatePurchasedIdentifiers(transaction)
//                    
//                    //Always finish a transaction.
//                    await transaction.finish()
//                } catch {
//                    //StoreKit has a receipt it can read but it failed verification. Don't deliver content to the user.
//                    print("Transaction failed verification")
//                }
            }
            self.complateTranscationCallbacks?(verifications)
        }
    }
    
//    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
//        //Check if the transaction passes StoreKit verification.
//        switch result {
//            case .unverified:
//                //StoreKit has parsed the JWS but failed verification. Don't deliver content to the user.
//                throw StoreKitError.systemError(NSError(domain: "Failed Verification", code: -1))
//            case .verified(let safe):
//                //If the transaction is verified, unwrap and return it.
//                return safe
//        }
//    }
}