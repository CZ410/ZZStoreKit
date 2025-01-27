//
//  ZZComplate.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2025/1/8.
//

import StoreKit

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
public class ZZComplateControl{
    public var complates = [ZZComplate]()
    
    public func add(_ complate: ZZComplate, queue: SKPaymentQueue){
        complates.append(complate)
    }
    
    public func updatedTransactions(_ transactions: [SKPaymentTransaction]) -> [SKPaymentTransaction]{
        guard !complates.isEmpty else {
            return transactions
        }
        let transactions = transactions.filter({ $0.transactionState != .purchasing })
        complates.forEach({ $0.callback?(transactions) })
        print("updatedTransactions Complate")
        return transactions.filter({ $0.transactionState == .restored })
    }
    
}

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
public class ZZComplate{
    public var callback: ((_ transactions: [SKPaymentTransaction]) -> Void)?
    
    public init(callback: ((_ transactions: [SKPaymentTransaction]) -> Void)?) {
        self.callback = callback
    }
}
