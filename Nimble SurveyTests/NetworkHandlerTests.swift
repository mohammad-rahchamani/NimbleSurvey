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
    
    private static let VALID_STATUS_CODES = 200...299
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func load(request: URLRequest,
              completion: @escaping (Result<Data, Error>) -> ()) {
        session.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  NetworkHandler.isResponseValid(response),
                  !data.isEmpty else {
                      completion(.failure(NetworkHandlerError.invalidData))
                      return
            }
            
            completion(.success(data))
            
        }.resume()
    }
    
    private static func isResponseValid(_ response: URLResponse?) -> Bool {
        guard let response = response as? HTTPURLResponse else {
            return false
        }
        return VALID_STATUS_CODES.contains(response.statusCode)
    }
    
    private enum NetworkHandlerError: Error {
        case invalidData
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
    
    func test_load_failsOnNetworkError() {
        let sut = makeSUT()
        assert(sut,
               loads: anyRequest(),
               receives: .failure(anyNSError()),
               stubbing: (nil, nil, anyNSError()))
    }
    
    func test_load_failsOnErrorAndResponse() {
        let sut = makeSUT()
        assert(sut,
               loads: anyRequest(),
               receives: .failure(anyNSError()),
               stubbing: (nil, httpResponse(for: anyURL(), withStatus: 200), anyNSError()))
    }
    
    func test_load_failsOnErrorAndData() {
        let sut = makeSUT()
        assert(sut,
               loads: anyRequest(),
               receives: .failure(anyNSError()),
               stubbing: (Data(), nil, anyNSError()))
    }
    
    func test_load_failsOnErrorReponseAndData() {
        let sut = makeSUT()
        assert(sut,
               loads: anyRequest(),
               receives: .failure(anyNSError()),
               stubbing: (Data(), httpResponse(for: anyURL(), withStatus: 200), anyNSError()))
    }
    
    func test_load_failsOnResponseWithoutData() {
        let sut = makeSUT()
        assert(sut,
               loads: anyRequest(),
               receives: .failure(anyNSError()),
               stubbing: (nil, httpResponse(for: anyURL(), withStatus: 200), nil))
    }
    
    func test_load_failsOnDataWithoutResponse() {
        let sut = makeSUT()
        assert(sut,
               loads: anyRequest(),
               receives: .failure(anyNSError()),
               stubbing: (Data(), nil, nil))
    }
    
    func test_load_failsOnNoDataNoResponseNoError() {
        let sut = makeSUT()
        assert(sut,
               loads: anyRequest(),
               receives: .failure(anyNSError()),
               stubbing: (nil, nil, nil))
    }
    
    func test_load_failsNonSuccessfulResponseAndData() {
        let sut = makeSUT()
        let notSuccessfulCodes: [Int] = [-1, 0, 199, 300, 400, 500]
        for code in notSuccessfulCodes {
            assert(sut,
                   loads: anyRequest(),
                   receives: .failure(anyNSError()),
                   stubbing: (Data(), httpResponse(for: anyURL(), withStatus: code), nil))
        }
    }

    func test_load_deliversDataOnDataAndSuccessfulStatus() {
        let sut = makeSUT()
        let expectedData = someData()
        let successfulCodes = 200...299
        for code in successfulCodes {
            assert(sut,
                   loads: anyRequest(),
                   receives: .success(expectedData),
                   stubbing: (expectedData, httpResponse(for: anyURL(), withStatus: code), nil))
        }
    }
    
    // MARK: - helpers
    
    func makeSUT() -> NetworkHandler {
        NetworkHandler(session: .shared)
    }
    
    func assert(_ sut: NetworkHandler,
                loads request: URLRequest,
                receives expectedResult: Result<Data, Error>,
                stubbing stub: (Data?, URLResponse?, Error?),
                file: StaticString = #filePath,
                line: UInt = #line) {
        URLProtocolStub.stub(withData: stub.0,
                             response: stub.1,
                             error: stub.2)
        expect(sut,
               toLoad: request,
               withResult: expectedResult,
               file: file,
               line: line)
    }
    
    func expect(_ sut: NetworkHandler,
                toLoad request: URLRequest,
                withResult expectedResult: Result<Data, Error>,
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for load completion")
        sut.load(request: request) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success(let data), .success(let expectedData)):
                XCTAssertEqual(data, expectedData, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult) got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    func anyRequest() -> URLRequest {
        URLRequest(url: anyURL())
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "test domain", code: 0, userInfo: nil)
    }
    
    func someData() -> Data {
        "some value".data(using: .utf8)!
    }
    
    func httpResponse(for url: URL, withStatus status: Int) -> HTTPURLResponse? {
        HTTPURLResponse(url: url,
                        statusCode: status,
                        httpVersion: nil,
                        headerFields: nil)
    }

}
