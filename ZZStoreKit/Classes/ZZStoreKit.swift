//
//  ZZStoreKit.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2024/12/31.
//

import StoreKit


@available(iOS 12.2, *)
public class ZZStoreKit {
    public enum ZZStoreError : Error {
        
        /// Failure due to an unknown, unrecoverable error.
        ///
        /// Usually, trying again at a later time will work.
        case unknown
        
        /// The action failed because the user did not complete some necessary interaction.
        case userCancelled
        
        /// A network error occurred when communicating with the App Store.
        case networkError(URLError)
        
        case systemError(any Error)
        
        /// The product is not available in the current storefront.
        case notAvailableInStorefront
        
        /// The application is not entitled to perform the action.
        @available(iOS 15.4, macOS 12.3, tvOS 15.4, watchOS 8.5, visionOS 1.0, *)
        case notEntitled
    }
    
    /// 处理未完成订单
    /// - Parameter block: 回调
    public static func complateTransaction(complate block: ((_ transactions: [ZZPaymentTransaction]) -> Void)? = nil){
        if #available(iOS 15, *) {
            ZZStoreKit_V2.share.complateTransaction { verificationResults in
                var transactions: [Transaction] = []
                verificationResults.forEach { result in
                    switch result{
                        case .unverified(_, _):
                            break
                        case .verified(let transaction):
                            transactions.append(transaction)
                    }
                }
                block?(transactions.map({ ZZPaymentTransaction(transaction: $0) }))
            }
        } else {
            ZZStoreKit_V1.share.complateTransaction { transactions in
                block?(transactions.map({ ZZPaymentTransaction(transaction: $0) }))
            }
        }
    }
    
    /// 获取商品信息
    /// - Parameters:
    ///   - ids: 商品ProductIdentifier
    ///   - block:  回调
    public static func getProducts(
        _ ids: [String],
        complate block:((Result<[ZZProduct], ZZStoreError>) -> Void)? = nil
    ){
        if #available(iOS 15, *) {
            Task{
                do{
                    let products = try await ZZStoreKit_V2.share.getProducts(ids)
                    let productResults = products.map({ ZZProduct(product: $0) })
                    block?(.success(productResults))
                } catch let err{
                    block?(.failure(enterError(err)))
                }
            }
        } else {
            ZZStoreKit_V1.share.getProducts(ids) { result in
                switch result{
                    case .success(let suc):
                        let products = suc.products.map({ ZZProduct(product: $0) })
                        block?(.success(products))
                    case .failure(let err):
                        block?(.failure(enterError(err)))
                }
            }
        }
    }
    
    /// 购买一个商品
    /// - Parameters:
    ///   - product: 商品 product
    ///   - quantity: 数量
    ///   - applicationUsername: applicationUsername description
    ///   - isSandbox: 是否沙盒
    ///   - block: 回调 并携带票据信息
    public static func buyProduct(
        _ product: ZZProduct,
        quantity: Int = 1,
        appAccountToken: UUID? = nil,
        applicationUsername: String? = nil,
        isSandbox: Bool = false,
        complate block: ((Result<ZZPaymentTransaction, ZZStoreError>) -> Void)? = nil
    ){
        if #available(iOS 15, *) {
            guard let product_v2 = product.product_v2 else {
                block?(.failure(.notAvailableInStorefront))
                return
            }
            Task{
                do{
                    let result = try await ZZStoreKit_V2.share.buyProduct(
                        product_v2,
                        quantity: quantity,
                        applicationUsername: applicationUsername,
                        appAccountToken: appAccountToken,
                        isSandbox: isSandbox
                    )
                    switch result.1 {
                        case .success:
                            let data = result.0
                            switch data{
                                case .unverified(_, let err):
                                    block?(.failure(enterError(err)))
                                    break
                                case .verified(let transaction):
                                    let transaction = ZZPaymentTransaction(transaction: transaction)
                                    block?(.success(transaction))
                                    break
                                case .none:
                                    block?(.failure(.unknown))
                            }
                        case .canceled:
                            block?(.failure(.userCancelled))
                        case .pending:
                            block?(.failure(.systemError(NSError(domain: "Waiting", code: -1))))
                        default:
                            block?(.failure(.unknown))
                    }
                } catch let err{
                    block?(.failure(enterError(err)))
                }
            }
        } else {
            guard let product_v1 = product.product_v1 else {
                block?(.failure(.notAvailableInStorefront))
                return
            }
            ZZStoreKit_V1.share.buyProduct( product_v1,
                                            quantity: quantity,
                                            applicationUsername: applicationUsername,
                                            isSandbox: isSandbox) { result in
                switch result {
                    case .success(let transaction):
                        let transaction = ZZPaymentTransaction(transaction: transaction)
                        block?(.success(transaction))
                    case .failure(let err):
                        block?(.failure(enterError(err)))
                        
                }
            }
        }
    }
    
    /// 结束订单
    /// - Parameter transaction: 订单信息 buyProduct 回调中获取
    public static func finishedTransaction(_ transaction: ZZPaymentTransaction){
        transaction.finished()
    }
    
    /// 恢复购买
    /// - Parameters:
    ///   - applicationUsername: applicationUsername description
    ///   - block: 回调
    public static func restore(
        applicationUsername: String? = nil,
        complate block: ((Result<Void, ZZStoreError>) -> Void)? = nil
    ){
        if #available(iOS 15, *) {
            Task {
                do{
                    try await ZZStoreKit_V2.share.restore()
                    block?(.success(()))
                } catch let err {
                    block?(.failure(enterError(err)))
                }
            }
        } else {
            ZZStoreKit_V1.share.restore(applicationUsername: applicationUsername) { result in
                switch result {
                    case .success(_):
//                        let transactions = transactions.map({ ZZPaymentTransaction(transaction: $0) })
                        block?(.success(()))
                    case .failure(let err):
                        block?(.failure(enterError(err)))
                        
                }
            }
        }
    }
}

@available(iOS 12.2, *)
public extension ZZStoreKit{
    fileprivate static func enterError(_ err: Error) -> ZZStoreError{
        if #available(iOS 15.0, *) {
            if let error = err as? StoreKitError{
                switch error {
                    case .unknown:
                        return .unknown
                    case .userCancelled:
                        return .userCancelled
                    case .networkError(let uRLError):
                        return .networkError(uRLError)
                    case .systemError(let error):
                        return .systemError(error)
                    case .notAvailableInStorefront:
                        return .notAvailableInStorefront
                    case .notEntitled:
                        if #available(iOS 15.4, *) {
                            return .notEntitled
                        }else {
                            return .systemError(err)
                        }
                    case .unsupported:
                        return .systemError(err)
                    @unknown default:
                        return .systemError(err)
                }
            } else {
                return .systemError(err)
            }
        } else {
            if let error = (err as? SKError){
                switch error.code {
                    case .unknown:
                        return .unknown
                        
                    case .clientInvalid:
                        return .networkError(URLError(.badURL))
                        
                    case .paymentCancelled:
                        return .userCancelled
                        
                    case .paymentInvalid:
                        return .notAvailableInStorefront
                        
                    case .paymentNotAllowed:
                        return .networkError(URLError(.dataNotAllowed))
                        
                    case .storeProductNotAvailable:
                        return .networkError(URLError(.dataNotAllowed))
                        
                    case .cloudServicePermissionDenied:
                        return .networkError(URLError(.backgroundSessionWasDisconnected))
                        
                    case .cloudServiceNetworkConnectionFailed:
                        return .networkError(URLError(.networkConnectionLost))
                        
                    case .cloudServiceRevoked:
                        return .networkError(URLError(.cancelled))
                        
                    case .privacyAcknowledgementRequired:
                        return .networkError(URLError(.userAuthenticationRequired))
                        
                    case .unauthorizedRequestData:
                        return .networkError(URLError(.userAuthenticationRequired))
                        
                    case .invalidOfferIdentifier:
                        return .systemError(err)
                        
                    case .invalidSignature:
                        return .systemError(err)
                        
                    case .missingOfferParams:
                        return .systemError(err)
                        
                    case .invalidOfferPrice:
                        return .systemError(err)
                        
                    case .overlayCancelled:
                        return .userCancelled
                        
                    case .overlayInvalidConfiguration:
                        return .networkError(URLError(.userAuthenticationRequired))
                        
                    case .overlayTimeout:
                        return .networkError(URLError(.timedOut))
                        
                    case .ineligibleForOffer:
                        return .systemError(err)
                        
                    case .unsupportedPlatform:
                        return .systemError(err)
                        
                    case .overlayPresentedInBackgroundScene:
                        return .systemError(err)
                        
                    @unknown default:
                        return .unknown
                }
            } else {
                return .systemError(err)
            }
        }
    }
}
