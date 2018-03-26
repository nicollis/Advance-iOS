//
//  FakeScheduleURLProtocol.swift
//  RanchForecast
//
//  Created by Michael Ward on 9/17/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import Foundation

class FakeScheduleURLProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        print("Vending fake URL response.")
        
        client?.urlProtocol(self,
                            didReceive: Constants.okResponse,
                            cacheStoragePolicy: .notAllowed)
        
        client?.urlProtocol(self,
                            didLoad: Constants.jsonData)
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        print("Done vending fake URL response.")
    }
    
}
