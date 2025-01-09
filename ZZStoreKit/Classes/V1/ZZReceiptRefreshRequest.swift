//
//  ZZReceiptRefreshRequest.swift
//  ZZStoreKit
//
//  Created by 陈钟 on 2024/12/31.
//

import StoreKit

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
class ZZReceiptRefreshRequestControl: NSObject{
    var requests: [ZZReceiptRefreshRequest] = []
    
    func add(_ request: ZZReceiptRefreshRequest){
        requests.append(request)
        request.request.delegate = self
        request.start()
    }
}

@available(iOS, introduced: 12.2, deprecated: 15.0, message: "Use ZZStoreKit_V2")
class ZZReceiptRefreshRequest: NSObject{
    
    var callback:((Result<Data, SKError>) -> Void)?
    
    var request: SKReceiptRefreshRequest!
    
    init(block: ((Result<Data, SKError>) -> Void)?) {
        super.init()
        request = SKReceiptRefreshRequest(receiptProperties: [:])
        self.callback = block
    }
    
    func start(){
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
    func request(_ request: SKRequest, didFailWithError error: any Error) {
        let requests = self.requests.filter({ $0.request == request})
        let err = (error as? SKError) ?? SKError(_nsError: NSError(domain: "Unknow Receipt Refresh Request Error", code: -1))
        requests.forEach({ $0.callback?(.failure(err)) })
        self.requests.removeAll(where: { requests.contains($0) })
    }
    
    func requestDidFinish(_ request: SKRequest) {
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
