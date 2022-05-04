//
//  AuthServiceTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/3/22.
//

import XCTest
import Nimble_Survey

class AuthService {
    
    let loader: RequestLoader
    
    init(loader: RequestLoader) {
        self.loader = loader
    }
    
    func login(withEmail email: String,
               andPassword password: String,
               completion: @escaping (Result<Bool, Error>) -> ()) {
        
    }
    
}

class RequestLoaderSpy: RequestLoader {
    
    private(set) var messages: [URLRequest : (Result<Data, Error>) -> ()] = [:]
    
    func load(request: URLRequest,
              completion: @escaping (Result<Data, Error>) -> ()) {
        messages[request] = completion
    }
    
    func completeLoad(for request: URLRequest, with result: Result<Data, Error>) {
        messages[request]?(result)
    }
    
    
}

class AuthServiceTests: XCTestCase {

    func test_init_doesNotMessageLoader() {
        let (spy, _) = makeSUT()
        XCTAssertEqual(spy.messages.count, 0)
    }
    
    // MARK: - helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RequestLoaderSpy, AuthService) {
        let spy = RequestLoaderSpy()
        let sut = AuthService(loader: spy)
        trackForMemoryLeak(spy)
        trackForMemoryLeak(sut)
        return (spy, sut)
    }

}
