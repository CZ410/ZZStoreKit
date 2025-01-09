//
//  ZZProduct.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2025/1/8.
//

import StoreKit

@available(iOS 12.0, *)
extension SKProduct.PeriodUnit{
    var toZZUnit: ZZProduct.Unit{
        switch self {
            case .day:
                return .day
            case .week:
                return .week
            case .month:
                return .month
            case .year:
                return .year
            @unknown default:
                return .unowned
        }
    }
}

@available(iOS 15.0, *)
extension Product.SubscriptionPeriod.Unit{
    var toZZUnit: ZZProduct.Unit{
        switch self {
            case .day:
                return .day
            case .week:
                return .week
            case .month:
                return .month
            case .year:
                return .year
            @unknown default:
                return .unowned
        }
    }
}

@available(iOS 12.0, *)
struct ZZProduct{
    enum Unit : Equatable, Hashable {
        case day
        
        case week
        
        case month
        
        case year
        
        case unowned
    }
    
    private static func priceFormatter(locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }
    
    var _product_v1: Any?
    @available(iOS, introduced: 12.0, deprecated: 15.0, message: "Use init(transaction: Transaction)")
    var product_v1: SKProduct?{
        return _product_v1 as? SKProduct
    }
    
    var _product_v2: Any?
    
    @available(iOS 15.0, *)
    var product_v2: Product?{
        return _product_v2 as? Product
    }
    
    
    init(product: SKProduct) {
        self._product_v1 = product
        self.localizedDescription = product.localizedDescription
        self.localizedTitle = product.localizedTitle
        self.price = product.price.stringValue
        self.priceLocale = product.priceLocale
        self.productIdentifier = product.productIdentifier
        self.isDownloadable = product.isDownloadable
        if #available(iOS 14.0, *) {
            self.isFamilyShareable =  product.isFamilyShareable
        } else {
            self.isFamilyShareable = false
        }
        self.downloadContentLengths = product.downloadContentLengths
        self.contentVersion = product.contentVersion
        self.downloadContentVersion = product.downloadContentVersion
        
        if product.subscriptionPeriod != nil {
            self.subscriptionPeriod = ZZProductSubscriptionPeriod(
                numberOfUnits: product.subscriptionPeriod!.numberOfUnits,
                unit: product.subscriptionPeriod!.unit.toZZUnit
            )
        }
        
        if product.introductoryPrice != nil {
            let localizedPrice = ZZProduct.priceFormatter(locale: priceLocale).string(from: product.introductoryPrice!.price) ?? ""
            self.introductoryPrice = ZZProductDiscount(
                price: product.introductoryPrice!.price as Decimal,
                localizedPrice: localizedPrice,
                priceLocale: product.introductoryPrice!.priceLocale,
                identifier: product.introductoryPrice!.identifier,
                subscriptionPeriod: ZZProductSubscriptionPeriod(numberOfUnits: product.introductoryPrice!.subscriptionPeriod.numberOfUnits, unit: product.introductoryPrice!.subscriptionPeriod.unit.toZZUnit),
                numberOfPeriods: product.introductoryPrice!.numberOfPeriods,
                paymentMode: product.introductoryPrice!.paymentMode.toZZPaymentModel,
                type: product.introductoryPrice!.type.toZZOfferType
            )
        }
        
        self.subscriptionGroupIdentifier = product.subscriptionGroupIdentifier
        
        self.discounts = product.discounts.map({
            ZZProductDiscount(price: $0.price as Decimal,
                              localizedPrice: ZZProduct.priceFormatter(locale: $0.priceLocale).string(from: $0.price) ?? "",
                              priceLocale: $0.priceLocale,
                              identifier: $0.identifier,
                              subscriptionPeriod: ZZProductSubscriptionPeriod(numberOfUnits: $0.subscriptionPeriod.numberOfUnits, unit: $0.subscriptionPeriod.unit.toZZUnit),
                              numberOfPeriods: $0.numberOfPeriods,
                              paymentMode: $0.paymentMode.toZZPaymentModel,
                              type: $0.type.toZZOfferType
            )
        })
    }
    
    @available(iOS 15.0, *)
    init(product: Product) {
        self._product_v2 = product
        self.localizedDescription = product.description
        self.localizedTitle = product.displayName
        self.price = product.displayPrice
        self.priceLocale = Locale.current
        self.productIdentifier = product.id
        
        self.isDownloadable = false
        
        self.isFamilyShareable =  product.isFamilyShareable
        
        self.downloadContentLengths = []
        self.contentVersion = ""
        self.downloadContentVersion = ""
        
        if product.subscription?.subscriptionPeriod != nil {
            self.subscriptionPeriod = ZZProductSubscriptionPeriod(
                numberOfUnits: product.subscription!.subscriptionPeriod.value,
                unit: product.subscription!.subscriptionPeriod.unit.toZZUnit
            )
        }
        
        let introductoryOffer = product.subscription?.introductoryOffer
        if introductoryOffer != nil {
            self.introductoryPrice = ZZProductDiscount(
                price: introductoryOffer!.price,
                localizedPrice: introductoryOffer!.displayPrice,
                priceLocale: Locale.current,
                identifier: introductoryOffer!.id,
                subscriptionPeriod: ZZProductSubscriptionPeriod(numberOfUnits: introductoryOffer!.period.value, unit: introductoryOffer!.period.unit.toZZUnit),
                numberOfPeriods: introductoryOffer!.periodCount,
                paymentMode: introductoryOffer!.paymentMode.toZZPaymentModel,
                type: introductoryOffer!.type.toZZOfferType
            )
        }
        
        self.subscriptionGroupIdentifier = product.subscription?.subscriptionGroupID
        
        self.discounts = product.subscription?.promotionalOffers.map({
            ZZProductDiscount(
                price: $0.price,
                localizedPrice: $0.displayPrice,
                priceLocale: Locale.current,
                identifier: $0.id,
                subscriptionPeriod: ZZProductSubscriptionPeriod(numberOfUnits: $0.period.value, unit: $0.period.unit.toZZUnit),
                numberOfPeriods: $0.periodCount,
                paymentMode: $0.paymentMode.toZZPaymentModel,
                type: $0.type.toZZOfferType
            )
        }) ?? []
    }
    
    var localizedDescription: String
    
    var localizedTitle: String
    
    var price: String
    
    var priceLocale: Locale
    
    var productIdentifier: String
    
    /// ios15 以上弃用  固定值 false
    var isDownloadable: Bool
    
    var isFamilyShareable: Bool
    
    /// ios15 以上弃用  固定值 空
    var downloadContentLengths: [NSNumber]
    
    /// ios15 以上弃用  固定值 空
    var contentVersion: String
    
    /// ios15 以上弃用  固定值 空
    var downloadContentVersion: String
    
    var subscriptionPeriod: ZZProductSubscriptionPeriod?
    
    var introductoryPrice: ZZProductDiscount?
    
    var subscriptionGroupIdentifier: String?
    
    var discounts: [ZZProductDiscount]
}
