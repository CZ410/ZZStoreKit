//
//  SKPaymentTransaction+Ex.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2024/12/31.
//

import StoreKit

@available(iOS 12.2, *)
public extension SKPaymentTransaction{
    func finished(){
        SKPaymentQueue.default().finishTransaction(self)
    }
}
