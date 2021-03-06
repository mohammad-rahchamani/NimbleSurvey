//
//  SurveyLoaderWithAuthTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import XCTest
import Nimble_Survey

class SurveyLoaderWithAuthTests: SurveyLoaderTests {

    func test_init_doesNotMessageLoaderAndService() {
        let (loaderSpy, serviceSpy, _) = makeSUT()
        XCTAssertEqual(loaderSpy.messages, [])
        XCTAssertEqual(serviceSpy.messages, [])
    }
    
    // MARK: - load
    
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
    
    func test_load_failsOnLoadFailureAndValidToken() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        serviceSpy.stub(freshToken())
        expect(sut,
               toLoadPage: 1,
               withSize: 1,
               withResult: .failure(anyNSError())) {
            loaderSpy.completeLoad(withResult: .failure(anyNSError()))
        }
    }
    
    func test_load_deliversDataOnSuccessfulLoadAndValidToken() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        serviceSpy.stub(freshToken())
        let expectedResult = sampleSurveyList()
        expect(sut,
               toLoadPage: 1,
               withSize: 1,
               withResult: .success(expectedResult)) {
            loaderSpy.completeLoad(withResult: .success(expectedResult))
        }
    }
    
    // MARK: - get details
    
    func test_getDetails_checksCurrentTokenBeforeMakingRequest() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        sut.getDetails(forSurvey: "") { _ in }
        XCTAssertEqual(loaderSpy.messages, [])
        XCTAssertEqual(serviceSpy.messages, [.token])
    }
    
    func test_getDetails_failsWithoutToken() {
        let (_, serviceSpy, sut) = makeSUT()
        serviceSpy.stub(nil)
        expect(sut,
               toGetDetailsFor: "",
               withResult: .failure(anyNSError())) { }
    }
    
    func test_getDetails_refreshesTokenOnExpiredToken() {
        let (_, serviceSpy, sut) = makeSUT()
        let expectedToken = expiredToken()
        serviceSpy.stub(expectedToken)
        sut.getDetails(forSurvey: "") { _ in }
        XCTAssertEqual(serviceSpy.messages, [.token, .refreshToken(token: expectedToken.refreshToken)])
    }
    
    func test_getDetails_failsOnRefreshTokenFailure() {
        let (_, serviceSpy, sut) = makeSUT()
        let oldToken = expiredToken()
        serviceSpy.stub(oldToken)
        expect(sut,
               toGetDetailsFor: "id",
               withResult: .failure(anyNSError())) {
            serviceSpy.completeRefreshToken(withResult: .failure(anyNSError()))
        }
    }
    
    func test_getDetails_loadsFromLoaderAfterRefreshingTokenOnExpiredToken() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        let expectedToken = freshToken()
        serviceSpy.stub(expiredToken())
        let id = "survey id"
        sut.getDetails(forSurvey: id) { _ in }
        serviceSpy.completeRefreshToken(withResult: .success(expectedToken))
        XCTAssertEqual(loaderSpy.messages, [.details(id: id,
                                                     tokenType: expectedToken.tokenType,
                                                     accessToken: expectedToken.accessToken)])
        
    }
    
    func test_getDetails_failsOnRefreshedTokenAndGetDetailsFailure() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        let oldToken = expiredToken()
        serviceSpy.stub(oldToken)
        expect(sut,
               toGetDetailsFor: "id",
               withResult: .failure(anyNSError())) {
            serviceSpy.completeRefreshToken(withResult: .success(freshToken()))
            loaderSpy.completeGetDetails(withResult: .failure(anyNSError()))
        }
    }
    
    func test_getDetails_deliversDataOnRefreshedTokenAndLoaderResult() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        let oldToken = expiredToken()
        serviceSpy.stub(oldToken)
        let expectedResult: [SurveyDetail] = sampleSurveyDetails()
        expect(sut,
               toGetDetailsFor: "id",
               withResult: .success(expectedResult)) {
            serviceSpy.completeRefreshToken(withResult: .success(freshToken()))
            loaderSpy.completeGetDetails(withResult: .success(expectedResult))
        }
    }
    
    func test_getDetails_doesNotRefreshTokenOnValidToken() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        let token = freshToken()
        let survey = "survey"
        serviceSpy.stub(token)
        sut.getDetails(forSurvey: survey) { _ in }
        XCTAssertEqual(serviceSpy.messages, [.token])
        XCTAssertEqual(loaderSpy.messages, [.details(id: survey,
                                                     tokenType: token.tokenType,
                                                     accessToken: token.accessToken)])
    }
    
    func test_getDetails_failsOnGetDetailsFailureAndValidToken() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        serviceSpy.stub(freshToken())
        expect(sut,
               toGetDetailsFor: "survey",
               withResult: .failure(anyNSError())) {
            loaderSpy.completeGetDetails(withResult: .failure(anyNSError()))
        }
    }
    
    func test_getDetails_deliversDataOnSuccessfulGetDetailsAndValidToken() {
        let (loaderSpy, serviceSpy, sut) = makeSUT()
        serviceSpy.stub(freshToken())
        let expectedResult = sampleSurveyDetails()
        expect(sut,
               toGetDetailsFor: "survey",
               withResult: .success(expectedResult)) {
            loaderSpy.completeGetDetails(withResult: .success(expectedResult))
        }
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
    
    func sampleSurveyDetails() -> [SurveyDetail] {
        [
            SurveyDetail(id: "d3afbcf2b1d60af845dc",
                         type: "question",
                         attributes: SurveyDetailAttributes(text: "text",
                                                            helpText: nil,
                                                            displayOrder: 0,
                                                            shortText: "introduction",
                                                            pick: "none",
                                                            displayType: "intro",
                                                            isMandatory: false,
                                                            correctAnswerId: nil,
                                                            facebookProfile: nil,
                                                            twitterProfile: nil,
                                                            imageUrl: "https://dhdbhh0jsld0o.cloudfront.net/m/2001ebbfdcbf6c00c757_",
                                                            coverImageUrl: "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_",
                                                            coverImageOpacity: 0.6,
                                                            coverBackgroundColor: nil,
                                                            isShareableOnFacebook: false,
                                                            isShareableOnTwitter: false,
                                                            fontFace: nil,
                                                            fontSize: nil,
                                                            tagList: ""),
                         relationships: SurveyDetailRelationship(answers: SurveyQuestionsOrAnswers(data: [])))
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
