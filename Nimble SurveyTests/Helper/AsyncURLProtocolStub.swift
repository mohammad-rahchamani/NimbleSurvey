//
//  AsyncURLProtocolStub.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/3/22.
//

import Foundation

class AsyncURLProtocolStub: URLProtocolStub {
    
    private static var requestClient: URLProtocolClient?
    private static var protocolInstance: AsyncURLProtocolStub?
    
    private static func loadFromStub() {
        guard let stub = URLProtocolStub.stub,
        let protocolInstance = protocolInstance else { return }
        if let data = stub.data {
            requestClient?.urlProtocol(protocolInstance, didLoad: data)
        }
        if let response = stub.response {
            requestClient?.urlProtocol(protocolInstance,
                                didReceive: response,
                                cacheStoragePolicy: .notAllowed)
        }
        if let error = stub.error {
            requestClient?.urlProtocol(protocolInstance, didFailWithError: error)
        }
        requestClient?.urlProtocolDidFinishLoading(protocolInstance)
    }
    
    override func startLoading() {
        URLProtocolStub.observer?(request)
        AsyncURLProtocolStub.requestClient = client
        AsyncURLProtocolStub.protocolInstance = self
    }
    
    static func complete() {
        loadFromStub()
    }
}
