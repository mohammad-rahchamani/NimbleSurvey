//
//  NetworkHandlerTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/3/22.
//

import XCTest

class URLProtocolStub: URLProtocol {
    
    struct Stub {
        var data: Data?
        var response: URLResponse?
        var error: Error?
    }
    
    static var observer: ((URLRequest) -> ())?
    static var stub: Stub?
    
    static func observe(_ closure: @escaping (URLRequest) -> ()) {
        observer = closure
    }
    
    static func stub(withData data: Data?,
                     response: URLResponse?,
                     error: Error?) {
        stub = Stub(data: data,
                    response: response,
                    error: error)
    }
    
    static func startIntercepting() {
        URLProtocol.registerClass(self)
    }
    
    static func stopIntercepting() {
        URLProtocol.unregisterClass(self)
        observer = nil
        stub = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        URLProtocolStub.observer?(request)
        guard let stub = URLProtocolStub.stub else { return }
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        if let response = stub.response {
            client?.urlProtocol(self,
                                didReceive: response,
                                cacheStoragePolicy: .notAllowed)
        }
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
    
}

class NetworkHandler {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func load(request: URLRequest,
              completion: @escaping (Result<Data, Error>) -> ()) {
        session.dataTask(with: request) {_,_,_ in
            
        }.resume()
    }
    
}


class NetworkHandlerTests: XCTestCase {

    override func setUpWithError() throws {
        URLProtocolStub.startIntercepting()
    }

    override func tearDownWithError() throws {
        URLProtocolStub.stopIntercepting()
    }

    func test_init_doesNotSendRequest() {
        var requestCallCount = 0
        URLProtocolStub.observe { _ in
            requestCallCount += 1
        }
        _ = makeSUT()
        XCTAssertEqual(requestCallCount, 0)
    }
    
    func test_load_sendsRequest() {
        let sut = makeSUT()
        let exp = XCTestExpectation(description: "waiting for network call")
        let expectedRequest = anyRequest()
        var capturedRequest: URLRequest?
        URLProtocolStub.observe { request in
            capturedRequest = request
            // by using expectation, we make sure there is just one request
            exp.fulfill()
        }
        sut.load(request: expectedRequest) { _ in }
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(capturedRequest, expectedRequest)
    }
    
    // MARK: - helpers
    
    func makeSUT() -> NetworkHandler {
        NetworkHandler(session: .shared)
    }
    
    func anyRequest() -> URLRequest {
        URLRequest(url: URL(string: "https://any-url.com")!)
    }

}
