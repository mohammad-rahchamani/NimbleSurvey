//
//  SurveyLoaderWithAuthTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import XCTest
import Nimble_Survey

public class SurveyLoaderWithAuth {
    
    private let loader: SurveyLoader
    private let authHandler: AuthHandler
    
    public init(loader: SurveyLoader, authHandler: AuthHandler) {
        self.loader = loader
        self.authHandler = authHandler
    }
    
    public func load(page: Int,
                     size: Int,
                     completion: @escaping (Result<[Survey], Error>) -> ()) {
        guard let currentToken = authHandler.token() else {
            completion(.failure(LoaderWithAuthError.noToken))
            return
        }
        guard isValid(token: currentToken) else {
            authHandler.refreshToken(token: currentToken.refreshToken) { [unowned self] result in
                guard (self.authHandler.token()) != nil else {
                    completion(.failure(LoaderWithAuthError.refreshTokenError))
                    return
                }
                self.load(page: page,
                          size: size,
                          completion: completion)
            }
            return
        }
        self.loader.load(page: page,
                         size: size,
                         tokenType: currentToken.tokenType,
                         accessToken: currentToken.accessToken,
                         completion: completion)
    }
    
    private func isValid(token: AuthToken) -> Bool {
        let expirationDate = Date(timeIntervalSinceReferenceDate: token.createdAt).addingTimeInterval(token.expiresIn)
        return expirationDate > Date()
    }
    
    public func getDetails(forSurvey id: String,
                           completion: @escaping (Result<[SurveyDetail], Error>) -> ()) {
        
    }
    
    private enum LoaderWithAuthError: Error {
        case noToken
        case refreshTokenError
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
        sut.load(page: 1, size: 1) { _ in }
        XCTAssertEqual(loaderSpy.messages, [])
        XCTAssertEqual(serviceSpy.messages, [.token])
    }
    
    func test_load_failsWithoutToken() {
        let (_, serviceSpy, sut) = makeSUT()
        serviceSpy.stub(nil)
        expect(sut,
               toLoadPage: 1,
               withSize: 5,
               withResult: .failure(anyNSError())) {
        }
    }
    
    func test_load_refreshesTokenOnExpiredToken() {
        let (_, serviceSpy, sut) = makeSUT()
        let expectedToken = expiredToken()
        serviceSpy.stub(expectedToken)
        sut.load(page: 1, size: 1) { _ in }
        XCTAssertEqual(serviceSpy.messages, [.token, .refreshToken(token: expectedToken.refreshToken)])
    }
    
    func test_load_failsOnRefreshTokenFailure() {
        let (_, serviceSpy, sut) = makeSUT()
        let oldToken = expiredToken()
        serviceSpy.stub(oldToken)
        expect(sut,
               toLoadPage: 1,
               withSize: 1,
               withResult: .failure(anyNSError())) {
            serviceSpy.completeRefreshToken(withResult: .failure(anyNSError()))
        }
    }
    
    func test_load_loadsFromLoaderAfterRefreshingTokenOnExpiredToken() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        let expectedToken = freshToken()
        serviceSpy.stub(expiredToken())
        let page = 1
        let size = 5
        sut.load(page: page,
                 size: size) { _ in }
        serviceSpy.completeRefreshToken(withResult: .success(expectedToken))
        XCTAssertEqual(loaderSpy.messages, [.load(page: page,
                                                  size: size,
                                                  tokenType: expectedToken.tokenType,
                                                  accessToken: expectedToken.accessToken)])
        
    }
    
    func test_load_failsOnRefreshedTokenAndLoaderFailure() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        let oldToken = expiredToken()
        serviceSpy.stub(oldToken)
        expect(sut,
               toLoadPage: 1,
               withSize: 1,
               withResult: .failure(anyNSError())) {
            serviceSpy.completeRefreshToken(withResult: .success(freshToken()))
            loaderSpy.completeLoad(withResult: .failure(anyNSError()))
        }
    }
    
    func test_load_deliversDataOnRefreshedTokenAndLoaderResult() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        let oldToken = expiredToken()
        serviceSpy.stub(oldToken)
        let expectedResult: [Survey] = sampleSurveyList()
        expect(sut,
               toLoadPage: 1,
               withSize: 1,
               withResult: .success(expectedResult)) {
            serviceSpy.completeRefreshToken(withResult: .success(freshToken()))
            loaderSpy.completeLoad(withResult: .success(expectedResult))
        }
    }
    
    func test_load_doesNotRefreshTokenOnValidToken() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        let token = freshToken()
        let page = 2
        let size = 3
        serviceSpy.stub(token)
        sut.load(page: page, size: size) { _ in }
        XCTAssertEqual(serviceSpy.messages, [.token])
        XCTAssertEqual(loaderSpy.messages, [.load(page: page,
                                                  size: size,
                                                  tokenType: token.tokenType,
                                                  accessToken: token.accessToken)])
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
    
    func expect(_ sut: SurveyLoaderWithAuth,
                toLoadPage page: Int,
                withSize size: Int,
                withResult expectedResult: Result<[Survey], Error>,
                executing action: () -> (),
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for load completion")
        sut.load(page: page,
                 size: size) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success(let surveys), .success(let expectedSurveys)):
                XCTAssertEqual(surveys, expectedSurveys, file: file, line: line)
            default:
                XCTFail(file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    func expect(_ sut: SurveyLoaderWithAuth,
                toGetDetailsFor surveyId: String,
                withResult expectedResult: Result<[SurveyDetail], Error>,
                executing action: () -> (),
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for get details completion")
        sut.getDetails(forSurvey: surveyId) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success(let surveys), .success(let expectedSurveys)):
                XCTAssertEqual(surveys, expectedSurveys, file: file, line: line)
            default:
                XCTFail(file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    func sampleSurveyList() -> [Survey] {
        [
            Survey(id: "d5de6a8f8f5f1cfe51bc",
                   type: "survey",
                   attributes: SurveyAttributes(title: "Scarlett Bangkok",
                                               description: "We'd love ot hear from you!",
                                               thankEmailAboveThreshold: "sample email above",
                                               thankEmailBelowThreshold: "sample email below",
                                               isActive: true,
                                               coverImageUrl: "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_",
                                               createdAt: "2017-01-23T07:48:12.991Z",
                                               activeAt: "2015-10-08T07:04:00.000Z",
                                               inactiveAt: nil,
                                               surveyType: "Restaurant"),
                   relationships: SurveyRelationship(questions: SurveyQuestionsOrAnswers(data: [
                    SurveyRelationData(id: "d3afbcf2b1d60af845dc", type: "question")
                   ])))
        ]
    }
    
    func expiredToken() -> AuthToken {
        AuthToken(accessToken: "access",
                  refreshToken: "refresh",
                  tokenType: "bearer",
                  expiresIn: 1,
                  createdAt: 0)
    }
    
    func freshToken() -> AuthToken {
        AuthToken(accessToken: "access",
                  refreshToken: "refresh",
                  tokenType: "bearer",
                  expiresIn: 24*60*60,
                  createdAt: Date().timeIntervalSince1970)
    }

}
