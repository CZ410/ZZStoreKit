//
//  ViewController.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2024/12/31.
//

import UIKit
import SwiftyStoreKit
import StoreKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        getProducts()
//        
//        SwiftyStoreKit.retrieveProductsInfo(["com.parabola.solution.ai.weekly"]) { result in
//            if let product = result.retrievedProducts.first {
//                let priceString = product.localizedPrice!
//                print("Product: \(product.localizedDescription), price: \(priceString)")
//            }
//            else if let invalidProductId = result.invalidProductIDs.first {
//                print("Invalid product identifier: \(invalidProductId)")
//            }
//            else {
//                print("Error: \(result.error)")
//            }
//        }
        
//        SwiftyStoreKit.completeTransactions { purches in
//            purches.forEach { p in
//                SwiftyStoreKit.finishTransaction(p.transaction)
//            }
//        }
        
//        ZZStoreKit_V1.share.complateTransaction { transactions in
//            debugPrint("complateTransaction \(transactions)")
//        }
        ZZStoreKit.complateTransaction { transactions in
            debugPrint("complateTransaction \(transactions)")
        }
        
        button.frame = CGRect(x: 0, y: 80, width: 100, height: 100)
        view.addSubview(button)
        
        button1.frame = CGRect(x: 110, y: 80, width: 100, height: 100)
        view.addSubview(button1)
        
        button2.frame = CGRect(x: 220, y: 80, width: 100, height: 100)
        view.addSubview(button2)
        
        
        button3.frame = CGRect(x: 0, y: 200, width: 100, height: 100)
        view.addSubview(button3)
        
        
        button4.frame = CGRect(x: 110, y: 200, width: 100, height: 100)
        view.addSubview(button4)
    }

    @objc func getProducts(){
        let ids = ["com.parabola.solution.ai.weekly",
                   "com.parabola.solution.ai.yearly",
                   "com.parabola.solution.ai.balance.100"]
//        let ids = ["com.parabola.solution.ai.balance.100"]
        
        print("CCC ---- CCC")
        ZZStoreKit.getProducts(ids) { result in
            let data = try? result.get()
            self.products = data ?? []
            print("result \(String(describing: data?.map({ $0.localizedTitle })))")
        }
//        if #available(iOS 15.0, *) {
//            Task {
//                do{
//                    let products = try await ZZStoreKit_V2.share.getProducts(ids)
//                    
//                } catch let err{
//                    
//                }
//            }
//        } else {
//            ZZStoreKit_V1.share.getProducts(ids) { result in
//                let data = try? result.get()
//                print("result \(String(describing: data?.products.map({ $0.localizedTitle })))")
//                self.products = (try? result.get().products) ?? []
//            }
//        }
        
    }
    
    var products: [ZZProduct] = []
    
    @objc func action1(){
        guard let p = self.products.first else { return }
//        ZZStoreKit_V1.share.buyProduct(p) { result in
//            let data = try? result.get()
////            data?.finished()
//
//            print("result \(String(describing: data))")
//            
//            self.receipt = data
//        }
        ZZStoreKit.buyProduct(p) { result in
            let data = try? result.get()
            print("result \(String(describing: data))")
            self.receipt = data
        }
    }
    
    var receipt : ZZPaymentTransaction?
    
    @objc func action2(){
        ZZStoreKit_V1.share.receiptRefresh { result in
            let data = try? result.get()
            print("data = \(String(describing: data))")
            let encryptedReceipt = data?.base64EncodedString(options: [.endLineWithLineFeed])
            print("data Receipt = \(String(describing: encryptedReceipt))")
        }
    }
    
    @objc func action3(){
//        ZZStoreKit_V1.share.restore() { result in
//            let data = try? result.get()
// x           print("data restore = \(String(describing: data))")
//        }
        ZZStoreKit.restore { result in
            switch result{
                case .success(_):
                    debugPrint("Restore Success")
                case .failure(let err):
                    debugPrint("Restore Failed \(err)")
            }
        }
    }
    
    @objc func action4(){
        guard let transcation = receipt else {
            return
        }
        
//        ZZStoreKit_V1.share.finishedTransaction(transcation)
        ZZStoreKit.finishedTransaction(transcation)
        print("data Finished = \(String(describing: transcation))   id = \(transcation.transactionIdentifier)")
    }
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(getProducts), for: .touchUpInside)
        button.setTitle("Refresh", for: .normal)
        return button
    }()
    
    lazy var button1: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(action1), for: .touchUpInside)
        button.setTitle("Buy", for: .normal)
        return button
    }()
    
    lazy var button2: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(action2), for: .touchUpInside)
        button.setTitle("receiptRefresh", for: .normal)
        return button
    }()
    
    lazy var button3: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(action3), for: .touchUpInside)
        button.setTitle("Restore", for: .normal)
        return button
    }()

    lazy var button4: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(action4), for: .touchUpInside)
        button.setTitle("Finished", for: .normal)
        return button
    }()


}

