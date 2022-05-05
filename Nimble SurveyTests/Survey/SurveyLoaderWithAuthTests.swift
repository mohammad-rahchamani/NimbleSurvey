//
//  SurveyLoaderWithAuthTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import XCTest
import Nimble_Survey

public class SurveyLoaderWithAuth: SurveyLoader {
    
    private let loader: SurveyLoader
    private let authHandler: AuthHandler
    
    public init(loader: SurveyLoader, authHandler: AuthHandler) {
        self.loader = loader
        self.authHandler = authHandler
    }
    
    public func load(page: Int,
                     size: Int,
                     tokenType: String,
                     accessToken: String,
                     completion: @escaping (Result<[Survey], Error>) -> ()) {
        
    }
    
    public func getDetails(forSurvey id: String,
                           tokenType: String,
                           accessToken: String,
                           completion: @escaping (Result<[SurveyDetail], Error>) -> ()) {
        
    }
}

class SurveyLoaderSpy: SurveyLoader {
    
    private(set) var messages: [Message] = []
    
    private var loadCompletions: [(Result<[Survey], Error>) -> ()] = []
    private var detailCompletions: [(Result<[SurveyDetail], Error>) -> ()] = []
    
    enum Message: Equatable {
        case load(page: Int, size: Int, tokenType: String, accessToken: String)
        case details(id: String, tokenType: String, accessToken: String)
    }
    
    func load(page: Int,
              size: Int,
              tokenType: String,
              accessToken: String,
              completion: @escaping (Result<[Survey], Error>) -> ()) {
        messages.append(.load(page: page,
                              size: size,
                              tokenType: tokenType,
                              accessToken: accessToken))
        loadCompletions.append(completion)
    }
    
    func getDetails(forSurvey id: String,
                    tokenType: String,
                    accessToken: String,
                    completion: @escaping (Result<[SurveyDetail], Error>) -> ()) {
        messages.append(.details(id: id,
                                 tokenType: tokenType,
                                 accessToken: accessToken))
        detailCompletions.append(completion)
    }
    
    func completeLoad(at index: Int = 0,
                      withResult result: Result<[Survey], Error>) {
        loadCompletions[index](result)
    }
    
    func completeGetDetails(at index: Int = 0,
                            withResult result: Result<[SurveyDetail], Error>) {
        detailCompletions[index](result)
    }
    
}

class SurveyLoaderWithAuthTests: XCTestCase {

    func test_init_doesNotMessageLoaderAndService() {
        let (loaderSpy, serviceSpy, _) = makeSUT()
        XCTAssertEqual(loaderSpy.messages, [])
        XCTAssertEqual(serviceSpy.messages, [])
    }
    
    func test_load_doesNotMessageLoaderAndService() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        XCTAssertEqual(loaderSpy.messages, [])
        XCTAssertEqual(serviceSpy.messages, [])
    }
    
    
    // MARK: - helpers
    func makeSUT(file: StaticString = #filePath,
                 line: UInt = #line) -> (SurveyLoaderSpy, AuthServiceSpy, SurveyLoaderWithAuth) {
        let loaderSpy = SurveyLoaderSpy()
        let serviceSpy = AuthServiceSpy()
        let sut = SurveyLoaderWithAuth(loader: loaderSpy, authHandler: serviceSpy)
        trackForMemoryLeak(loaderSpy, file: file, line: line)
        trackForMemoryLeak(serviceSpy, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return(loaderSpy, serviceSpy, sut)
    }

}
