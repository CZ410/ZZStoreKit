//
//  ZZPayment.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2024/12/31.
//

import StoreKit

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
public class ZZPaymentControl{
    
    public var payments = [ZZPayment]()
    
    public func add(_ payment: ZZPayment, queue: SKPaymentQueue){
        payments.append(payment)
        let paymentV = SKMutablePayment(product: payment.product)
        paymentV.applicationUsername = payment.applicationUsername
        paymentV.quantity = payment.quantity
        paymentV.simulatesAskToBuyInSandbox = payment.isSandbox
        queue.add(paymentV)
    }
    
    public func updatedTransactions(_ transactions: [SKPaymentTransaction]) -> [SKPaymentTransaction]{
        var unupdateTransactions = transactions
        print("Payments \(self.payments)")
        transactions.forEach { transaction in
            let payments = self.payments.filter({ $0.product.productIdentifier == transaction.payment.productIdentifier})
            switch transaction.transactionState{
                case .purchased, .restored:
                    payments.forEach( { $0.callback?(.success(transaction))} )
                    unupdateTransactions.removeAll(where: { $0 == transaction})
                case .failed:
                    let err = (transaction.error as? SKError) ?? SKError(_nsError: NSError(domain: "Unknow Payment Error", code: -1))
                    payments.forEach( { $0.callback?(.failure(err))} )
                    unupdateTransactions.removeAll(where: { $0 == transaction})
                default:
                    break
            }
            
            self.payments.removeAll { p in
                payments.contains(where: { $0.product.productIdentifier == p.product.productIdentifier })
            }
        }
        print("updatedTransactions \(self.payments)")
        return unupdateTransactions
    }
    
    
}

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
public class ZZPayment{
    public var product: SKProduct
    public var applicationUsername: String?
    public var quantity: Int
    public var isSandbox: Bool
    public var callback: ((Result<SKPaymentTransaction, SKError>) -> Void)?
    
    public init(product: SKProduct, applicationUsername: String? = nil, quantity: Int = 1, isSandbox: Bool = false, callback: ((Result<SKPaymentTransaction, SKError>) -> Void)?) {
        self.product = product
        self.applicationUsername = applicationUsername
        self.quantity = quantity
        self.isSandbox = isSandbox
        self.callback = callback
    }
}
