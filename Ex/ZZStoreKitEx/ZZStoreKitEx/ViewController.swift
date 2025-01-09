//
//  ViewController.swift
//  ZZStoreKitEx
//
//  Created by 陈钟 on 2025/1/9.
//

import UIKit
import ZZStoreKit

class ViewController: UIViewController {

    var products = [ZZProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //1 storekit complate transactions
        ZZStoreKit.complateTransaction { transactions in
//            // step:1 upload to your service
//            
//            // step:2 finished transactions
//            transactions.forEach({ ZZStoreKit.finishedTransaction($0) })
            
            transactions.forEach({ getReceiptDataString($0) })
        }
        
        // 2 get products details
        func getProducts(){
            ZZStoreKit.getProducts([]) { result in
                if let p = try? result.get(){
                    self.products = p
                    buy()
                }
            }
        }
        
        //3 buy a product
        func buy(){
            guard let product = products.first else {
                return
            }
            ZZStoreKit.buyProduct(product) { result in
                if let trans = try? result.get() {
                    // step:1 get receiptDataString or upload to your service
                    
                    
                    // step:2 finished transactions
                    //                    ZZStoreKit.finishedTransaction(trans)
                    
                    getReceiptDataString(trans)
                }
            }
        }
        
        // 4 get receipt to you service and finish transactions, or finish transactions
        func getReceiptDataString(_ transaction: ZZPaymentTransaction){
            transaction.receiptDataString { receiptDataString in
                // upload to your service
                
                // and then finished transactions
                ZZStoreKit.finishedTransaction(transaction)
            }
        }
        
        getProducts()
    }


}

