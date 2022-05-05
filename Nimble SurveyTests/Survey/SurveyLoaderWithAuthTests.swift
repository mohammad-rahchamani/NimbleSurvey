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
        guard let currentToken = authHandler.token() else {
            completion(.failure(LoaderWithAuthError.noToken))
            return
        }
        guard isValid(token: currentToken) else {
            authHandler.refreshToken(token: currentToken.refreshToken) { result in
                
            }
            return
        }
    }
    
    private func isValid(token: AuthToken) -> Bool {
        let expirationDate = Date(timeIntervalSinceReferenceDate: token.createdAt).addingTimeInterval(token.expiresIn)
        return expirationDate > Date()
    }
    
    public func getDetails(forSurvey id: String,
                           tokenType: String,
                           accessToken: String,
                           completion: @escaping (Result<[SurveyDetail], Error>) -> ()) {
        
    }
    
    private enum LoaderWithAuthError: Error {
        case noToken
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

class SurveyLoaderWithAuthTests: SurveyLoaderTests {

    func test_init_doesNotMessageLoaderAndService() {
        let (loaderSpy, serviceSpy, _) = makeSUT()
        XCTAssertEqual(loaderSpy.messages, [])
        XCTAssertEqual(serviceSpy.messages, [])
    }
    
    func test_load_checksCurrentTokenBeforeMakingRequest() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        sut.load(page: 1, size: 1, tokenType: "token", accessToken: "token") { _ in }
        XCTAssertEqual(loaderSpy.messages, [])
        XCTAssertEqual(serviceSpy.messages, [.token])
    }
    
    func test_load_failsWithoutToken() {
        let (_, serviceSpy, sut) = makeSUT()
        serviceSpy.stub(nil)
        expect(sut,
               toLoadPage: 1,
               withSize: 5,
               tokenType: "bearer",
               accessToken: "token",
               withResult: .failure(anyNSError())) {
        }
    }
    
    func test_load_refreshesTokenOnExpiredToken() {
        let (_, serviceSpy, sut) = makeSUT()
        let expectedToken = expiredToken()
        serviceSpy.stub(expectedToken)
        sut.load(page: 1, size: 1, tokenType: "", accessToken: "") { _ in }
        XCTAssertEqual(serviceSpy.messages, [.token, .refreshToken(token: expectedToken.refreshToken)])
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
    
    func expiredToken() -> AuthToken {
        AuthToken(accessToken: "access",
                  refreshToken: "refresh",
                  tokenType: "bearer",
                  expiresIn: 1,
                  createdAt: 0)
    }

}
