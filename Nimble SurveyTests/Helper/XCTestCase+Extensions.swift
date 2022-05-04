//
//  XCTestCase+Extensions.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import XCTest

public extension XCTestCase {
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should be nil", file: file, line: line)
        }
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
