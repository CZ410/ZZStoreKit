//
//  ZZStoreKit_V2.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2024/12/31.
//
import StoreKit

@available(iOS 15.0, *)
public class ZZStoreKit_V2: NSObject{
    
    public static let share = ZZStoreKit_V2()
    
    public enum PurchaseStatus{
        case success, canceled, pending, unowned
    }
    
    public var complateTranscationCallbacks: ((_ transactions: [VerificationResult<Transaction>]) -> Void)?
    private var updateListenerTask: Task<Void, Error>? = nil // 支付事件监听
    public override init() {
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
    public func getProducts(_ ids: [String]) async throws -> [Product]{
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
    public func buyProduct(
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
                return (verification, .success)
            case .userCancelled:
                return (nil, .canceled)
            case .pending:
                return (nil, .pending)
            default:
                return (nil, .unowned)
        }
    }
    
    /// 通过商品 ID购买一个商品
    /// - Parameters:
    ///   - productId: 商品 ID
    ///   - quantity: 数量
    ///   - applicationUsername: applicationUsername description
    ///   - appAccountToken: 用户 token
    ///   - isSandbox: 是否沙盒
    /// - Returns: 回调
    public func buyProduct(
        id productId: String,
        quantity: Int = 1,
        applicationUsername: String? = nil,
        appAccountToken: UUID? = nil,
        isSandbox: Bool = false
    ) async throws -> (VerificationResult<Transaction>?, PurchaseStatus) {
        let products = try await getProducts([productId])
        guard let product = products.first else {
            return (nil, .unowned)
        }
        return try await buyProduct(product, quantity: quantity, applicationUsername: applicationUsername, appAccountToken: appAccountToken, isSandbox: isSandbox)
    }
    
    /// 结束订单
    /// - Parameter transaction: 订单信息 buyProduct 回调中获取
    public func finishedTransaction(_ transaction: Transaction) async {
        await transaction.finish()
    }
    
    /// 恢复购买
    /// - Parameters:
    ///   - applicationUsername: applicationUsername description
    ///   - block: 回调
    public func restore() async throws{
       try await AppStore.sync()
    }
    
    /// 处理未完成订单
    /// - Parameter block: 回调
    public func complateTransaction(complate block: ((_ verificationResults: [VerificationResult<Transaction>]) -> Void)? = nil){
        complateTranscationCallbacks = block
    }

    /// 未完成支付监听事件
    private func listenForTransactions() -> Task<Void, Error>{
        return Task.detached {
            for await result in Transaction.updates {
                await MainActor.run {
                    self.complateTranscationCallbacks?([result])
                }
            }
        }
    }
}
