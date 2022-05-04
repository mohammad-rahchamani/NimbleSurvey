//
//  NetworkHandlerTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/3/22.
//

import XCTest
import Nimble_Survey

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
    
    func test_load_doesNotCallCompletionAfterInstanceDeallocated() {
        URLProtocolStub.stopIntercepting()
        AsyncURLProtocolStub.startIntercepting()
        AsyncURLProtocolStub.stub(withData: someData(),
                                  response: httpResponse(for: anyURL(), withStatus: 200),
                                  error: nil)
        var sut: NetworkHandler? = NetworkHandler(session: .shared)
        let exp = XCTestExpectation(description: "waiting for network call")
        AsyncURLProtocolStub.observe { _ in exp.fulfill() }
        sut?.load(request: anyRequest()) { _ in
            XCTFail("should not be called")
        }
        sut = nil
        wait(for: [exp], timeout: 1)
        AsyncURLProtocolStub.complete()
        AsyncURLProtocolStub.stopIntercepting()
    }
    
    // MARK: - helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> NetworkHandler {
        let sut = NetworkHandler(session: .shared)
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
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

}
