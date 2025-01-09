//
//  ZZRestore.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2025/1/8.
//

import StoreKit

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
public class ZZRestoreControl{
    public var restores = [ZZRestore]()
    
    private var willCallBackRestores = [SKPaymentTransaction]()
    
    public func add(_ restore: ZZRestore, queue: SKPaymentQueue){
        restores.append(restore)
        queue.restoreCompletedTransactions(withApplicationUsername: restore.applicationUsername)
    }
    
    public func updatedTransactions(_ transactions: [SKPaymentTransaction]) -> [SKPaymentTransaction]{
        guard !restores.isEmpty else {
            return transactions
        }
        let transactions = transactions.filter({ $0.transactionState == .restored })
        willCallBackRestores.append(contentsOf: transactions)
        print("updatedTransactions Restore")
        return transactions.filter({ $0.transactionState != .restored })
    }
    
    
    public func restoreCompletedTransactionsFailed(withError error: Error) {
        guard !restores.isEmpty else {
            return
        }
        let err = (error as? SKError) ?? SKError(_nsError: NSError(domain: "Unknow Restore Error", code: -1))
        restores.forEach { restore in
            restore.callback?(.failure(err))
        }
        // Reset state after error received
        restores.removeAll()
        willCallBackRestores.removeAll()
    }
    
    public func restoreCompletedTransactionsFinished() {
        guard !restores.isEmpty else {
            return
        }
        restores.forEach { restore in
            restore.callback?(.success(willCallBackRestores))
        }
        // Reset state
        restores.removeAll()
        willCallBackRestores.removeAll()
    }
}

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
public class ZZRestore{
    public var applicationUsername: String?
    public var callback: ((Result<[SKPaymentTransaction], SKError>) -> Void)?
    
    public init(applicationUsername: String? = nil, callback: ((Result<[SKPaymentTransaction], SKError>) -> Void)?) {
        self.applicationUsername = applicationUsername
        self.callback = callback
    }
}
