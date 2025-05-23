//
//  ZZProductDiscount.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2025/1/8.
//

import Foundation
import StoreKit

@available(iOS 12.2, *)
public struct ZZProductDiscount{
    
    public  enum PaymentMode : UInt, @unchecked Sendable {
        
        case payAsYouGo = 0
        
        case payUpFront = 1
        
        case freeTrial = 2
        
        case unowned = 999
    }
    
    public enum OfferType : UInt, @unchecked Sendable {
        
        case introductory = 0
        
        case subscription = 1
        
        case promotional = 2
        
        case winBack = 3
        
        case unowned = 999
    }
    
    public var price: Decimal
    
    public var localizedPrice: String
    
    public var priceLocale: Locale
    
    public var identifier: String?
    
    public var subscriptionPeriod: ZZProductSubscriptionPeriod
    
    public var numberOfPeriods: Int
    
    public var paymentMode: PaymentMode
    
    public var type: OfferType
    
}

@available(iOS 12.2, *)
public extension SKProductDiscount.PaymentMode{
    var toZZPaymentModel: ZZProductDiscount.PaymentMode{
        switch self {
            case .payAsYouGo:
                return .payAsYouGo
            case .payUpFront:
                return .payUpFront
            case .freeTrial:
                return .freeTrial
            @unknown default:
                return .unowned
        }
    }
}

@available(iOS 15.0, *)
public extension Product.SubscriptionOffer.PaymentMode{
    var toZZPaymentModel: ZZProductDiscount.PaymentMode{
        switch self {
            case .payAsYouGo:
                return .payAsYouGo
            case .payUpFront:
                return .payUpFront
            case .freeTrial:
                return .freeTrial
            default:
                return .unowned
        }
    }
}

@available(iOS 12.2, *)
public extension SKProductDiscount.`Type`{
    var toZZOfferType: ZZProductDiscount.OfferType{
        switch self {
            case .introductory:
                return .introductory
            case .subscription:
                return .subscription
            @unknown default:
                return .unowned
        }
    }
}

@available(iOS 15.0, *)
public extension Product.SubscriptionOffer.OfferType{
    var toZZOfferType: ZZProductDiscount.OfferType{
        if #available(iOS 18.0, *) {
            if case .winBack = self{
                return .winBack
            }
        }
        switch self {
            case .introductory:
                return .introductory
            case .promotional:
                return .promotional
            default:
                return .unowned
        }
    }
}
