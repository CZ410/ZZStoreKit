//
//  ZZStoreKit_V1.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2024/12/31.
//
import StoreKit

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
public class ZZStoreKit_V1: NSObject{
    
    static let share = ZZStoreKit_V1()
    
    private let paymentControl = ZZPaymentControl()
    private let requsetControl = ZZProductsRequestControl()
    private let receiptControl = ZZReceiptRefreshRequestControl()
    private let restoreControl = ZZRestoreControl()
    private let complateControl = ZZComplateControl()
    
    public var paymentQueue: SKPaymentQueue{
        return SKPaymentQueue.default()
    }
    
    public override init() {
        super.init()
        paymentQueue.add(self)
    }
    
    deinit {
        paymentQueue.remove(self)
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Method

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
public extension ZZStoreKit_V1{
    
    /// 处理未完成订单
    /// - Parameter block: 回调
    func complateTransaction(complate block: ((_ transactions: [SKPaymentTransaction]) -> Void)? = nil){
        complateControl.add(ZZComplate(callback: block), queue: paymentQueue)
    }
    
    /// 获取商品信息
    /// - Parameters:
    ///   - ids: 商品ProductIdentifier
    ///   - block:  回调
    func getProducts(
        _ ids: [String],
        complate block:((Result<SKProductsResponse, SKError>) -> Void)? = nil
    ){
        requsetControl.add(ZZProductsRequest(ids: ids, callback: block))
    }
    
    /// 购买一个商品
    /// - Parameters:
    ///   - product: 商品 product
    ///   - quantity: 数量
    ///   - applicationUsername: applicationUsername description
    ///   - isSandbox: 是否沙盒
    ///   - block: 回调
    func buyProduct(
        _ product: SKProduct,
        quantity: Int = 1,
        applicationUsername: String? = nil,
        isSandbox: Bool = false,
        complate block: ((Result<SKPaymentTransaction, SKError>) -> Void)? = nil
    ){
        paymentControl.add(ZZPayment(product: product, applicationUsername: applicationUsername, quantity: quantity, isSandbox: isSandbox, callback: block), queue: paymentQueue)
    }
    
    /// 通过商品 ID购买一个商品
    /// - Parameters:
    ///   - productId:  商品 ID
    ///   - quantity: 数量
    ///   - applicationUsername: applicationUsername description
    ///   - isSandbox: 是否沙盒
    ///   - block: 回调
    func buyProduct(id productId: String,
                    quantity: Int = 1,
                    applicationUsername: String? = nil,
                    isSandbox: Bool = false,
                    complate block: ((Result<SKPaymentTransaction, SKError>) -> Void)? = nil){
        getProducts([productId]) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
                case .success(let req):
                    if let product = req.products.first {
                        self.buyProduct(product, quantity: quantity, applicationUsername: applicationUsername, isSandbox: isSandbox, complate: block)
                    }else {
                        block?(.failure(SKError(.storeProductNotAvailable)))
                    }
                case .failure(let err):
                    block?(.failure(err))
            }
        }
    }
    
    /// 获取票据信息
    /// - Parameter block: 回调
    func receiptRefresh(complate block:((Result<Data, SKError>) -> Void)? = nil){
        receiptControl.add(ZZReceiptRefreshRequest(block: block))
    }
    
    /// 结束订单
    /// - Parameter transaction: 订单信息 buyProduct 回调中获取
    func finishedTransaction(_ transaction: SKPaymentTransaction){
        transaction.finished()
    }
    
    /// 恢复购买
    /// - Parameters:
    ///   - applicationUsername: applicationUsername description
    ///   - block: 回调
    func restore(
        applicationUsername: String? = nil,
        complate block: ((Result<[SKPaymentTransaction], SKError>) -> Void)? = nil
    ){
        restoreControl.add(ZZRestore(applicationUsername: applicationUsername, callback: block), queue: paymentQueue)
    }
}

// MARK: -  SKPaymentTransactionObserver

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
extension ZZStoreKit_V1: SKPaymentTransactionObserver{
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction")
        let transactions = transactions.filter({ $0.transactionState != .purchasing })
        var unupdateTransactions = [SKPaymentTransaction]()
        unupdateTransactions = self.paymentControl.updatedTransactions(transactions)
        unupdateTransactions = self.restoreControl.updatedTransactions(unupdateTransactions)
        unupdateTransactions = self.complateControl.updatedTransactions(unupdateTransactions)
        
        if unupdateTransactions.count > 0 {
            let strings = unupdateTransactions.map { $0.debugDescription }.joined(separator: "\n")
            print("unhandledTransactions:\n\(strings)")
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
    
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: any Error) {
        self.restoreControl.restoreCompletedTransactionsFailed(withError: error)
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.restoreControl.restoreCompletedTransactionsFinished()
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        
    }
    
//    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
//        return false
//    }
}
