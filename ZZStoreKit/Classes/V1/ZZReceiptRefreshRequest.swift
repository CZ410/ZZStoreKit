//
//  ZZReceiptRefreshRequest.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2024/12/31.
//

import StoreKit

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
public class ZZReceiptRefreshRequestControl: NSObject{
    public var requests: [ZZReceiptRefreshRequest] = []
    
    public func add(_ request: ZZReceiptRefreshRequest){
        requests.append(request)
        request.request.delegate = self
        request.start()
    }
}

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
public class ZZReceiptRefreshRequest: NSObject{
    
    public var callback:((Result<Data, SKError>) -> Void)?
    
    public var request: SKReceiptRefreshRequest!
    
    public init(block: ((Result<Data, SKError>) -> Void)?) {
        super.init()
        request = SKReceiptRefreshRequest(receiptProperties: [:])
        self.callback = block
    }
    
    public func start(){
        request.start()
    }
    
    fileprivate  var appStoreReceiptData: Data? {
        guard let url = Bundle.main.appStoreReceiptURL,
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return data
    }

}

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
extension ZZReceiptRefreshRequestControl: SKRequestDelegate{
    public func request(_ request: SKRequest, didFailWithError error: any Error) {
        let requests = self.requests.filter({ $0.request == request})
        let err = (error as? SKError) ?? SKError(_nsError: NSError(domain: "Unknow Receipt Refresh Request Error", code: -1))
        requests.forEach({ $0.callback?(.failure(err)) })
        self.requests.removeAll(where: { requests.contains($0) })
    }
    
    public func requestDidFinish(_ request: SKRequest) {
        let requests = self.requests.filter({ $0.request == request})
        requests.forEach { req in
            if let data = req.appStoreReceiptData {
                req.callback?(.success(data))
                return
            }else {
                req.callback?(.failure(SKError(_nsError: NSError(domain: "Unknow Receipt Refresh Request Error", code: -1))))
            }
        }
        self.requests.removeAll(where: { requests.contains($0) })
    }
}
