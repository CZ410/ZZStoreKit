//
//  ZZPaymentTransaction.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2025/1/9.
//

import Foundation
import StoreKit


struct ZZPaymentTransaction {
    
    var _transaction_v1: Any?
    @available(iOS, introduced: 12.0, deprecated: 15.0, message: "Use init(transaction: Transaction)")
    var transaction_v1: SKPaymentTransaction?{
        return _transaction_v1 as? SKPaymentTransaction
    }
    
    var _transaction_v2: Any?
    
    @available(iOS 15.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    var transaction_v2: Transaction?{
        return _transaction_v2 as? Transaction
    }
    
    
    @available(iOS 15.0, *)
    init(transaction: Transaction) {
        self._transaction_v2 = transaction
    }

    @available(iOS, introduced: 12.0, deprecated: 15.0, message: "Use init(transaction: Transaction)")
    init(transaction: SKPaymentTransaction) {
        self._transaction_v1 = transaction
    }
    
    /// 票据信息 已经转成 Base64 字符串
    /// - Parameter complate: 回调
    func receiptDataString(complate: ((_ receiptDataString: String?) -> Void)? = nil){
        if #available(iOS 15.0, *) {
            let dataStr = transaction_v2?.jsonRepresentation.base64EncodedString(options: [.endLineWithLineFeed])
            complate?(dataStr)
        } else {
            ZZStoreKit_V1.share.receiptRefresh { result in
                switch result {
                    case .success(let data):
                        let dataStr = data.base64EncodedString(options: [.endLineWithLineFeed])
                        complate?(dataStr)
                    case .failure(let err):
                        complate?(nil)
                }
            }
        }
    }
    
    /// 唯一订单号 提交服务器验证即可
    var transactionIdentifier: String{
        if #available(iOS 15.0, *) {
            return "\(transaction_v2?.id ?? 0)"
        } else {
            return transaction_v1?.transactionIdentifier ?? ""
        }
    }
    
    /// 结束订单
    func finished(){
        if #available(iOS 15.0, *) {
            Task {
                await self.transaction_v2?.finish()
            }
        } else {
            self.transaction_v1?.finished()
        }
    }
}
