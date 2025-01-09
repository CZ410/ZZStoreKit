//
//  ZZProductsRequest.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2024/12/31.
//

import StoreKit

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
class ZZProductsRequestControl: NSObject{
    var requests: [ZZProductsRequest] = []
    
    func add(_ request: ZZProductsRequest){
        requests.append(request)
        request.request.delegate = self
        request.start()
    }
}

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
class ZZProductsRequest:NSObject{
    
    var ids: [String] = []
    
    var callback: ((Result<SKProductsResponse, SKError>) -> Void)?
    
    private(set) var request: SKProductsRequest!
    
    init(ids: [String], callback: ((Result<SKProductsResponse, SKError>) -> Void)? = nil) {
        super.init()
        self.ids = ids
        self.request = SKProductsRequest(productIdentifiers: Set(ids))
        self.callback = callback
    }
    
    func start(){
        request.start()
    }
}

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
extension ZZProductsRequestControl: SKProductsRequestDelegate{
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let requests = self.requests.filter({ $0.request == request})
        requests.forEach({ $0.callback?(.success(response)) })
        self.requests.removeAll(where: { requests.contains($0) })
    }
    
    func request(_ request: SKRequest, didFailWithError error: any Error) {
        let requests = self.requests.filter({ $0.request == request})
        let err = (error as? SKError) ?? SKError(_nsError: NSError(domain: "Unknow Products Request Error", code: -1))
        requests.forEach({ $0.callback?(.failure(err)) })
        self.requests.removeAll(where: { requests.contains($0) })
    }
}
