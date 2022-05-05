//
//  AuthServiceWithStoreTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import XCTest
import Nimble_Survey


class AuthServiceWithStoreTests: XCTestCase {
    
    func test_init_doesNotMessageServiceAndStore() {
        let (serviceSpy, storeSpy, _) = makeSUT()
        XCTAssertTrue(serviceSpy.messages.isEmpty)
        XCTAssertTrue(storeSpy.messages.isEmpty)
    }
    
    // MARK: - login
    
    func test_login_requestsLoginFromService() {
        let (serviceSpy, storeSpy, sut) = makeSUT()
        
        let email = "email"
        let password = "password"
        sut.login(withEmail: email,
                  andPassword: password) { _ in }
        
        XCTAssertEqual(serviceSpy.messages, [AuthServiceSpy.Message.login(email: email,
                                                                          password: password)])
        XCTAssertTrue(storeSpy.messages.isEmpty)
    }
    
    func test_login_failsOnLoginError() {
        let (serviceSpy, _, sut) = makeSUT()
        expect(sut,
               toLoginWithEmail: "email",
               andPassword: "password",
               withResult: .failure(anyNSError())) {
            serviceSpy.completeLogin(withResult: .failure(anyNSError()))
        }
    }
    
    func test_login_requestsSaveToStoreOnSuccessfulLogin() {
        
        let (serviceSpy, storeSpy, sut) = makeSUT()
        
        let email = "email"
        let password = "password"
        sut.login(withEmail: email,
                  andPassword: password) { _ in }
        
        let expectedToken = anyAuthToken()
        serviceSpy.completeLogin(withResult: .success(expectedToken))
        
        XCTAssertEqual(serviceSpy.messages, [AuthServiceSpy.Message.login(email: email,
                                                                          password: password)])
        XCTAssertEqual(storeSpy.messages, [TokenStoreSpy.Message.save(expectedToken)])
    }
    
    func test_login_deliversLoginResult() {
        let (serviceSpy, _, sut) = makeSUT()
        let expectedToken = anyAuthToken()
        expect(sut,
               toLoginWithEmail: "email",
               andPassword: "password",
               withResult: .success(expectedToken)) {
            serviceSpy.completeLogin(withResult: .success(expectedToken))
        }
    }
    
    // MARK: - register
    
    func test_register_requestsRegisterFromService() {
        let (serviceSpy, storeSpy, sut) = makeSUT()
        
        let email = "email"
        let password = "password"
        sut.register(withEmail: email,
                     password: password,
                     passwordConfirmation: password) { _ in }
        
        XCTAssertEqual(serviceSpy.messages, [AuthServiceSpy.Message.register(email: email,
                                                                             password: password,
                                                                             confirmation: password)])
        XCTAssertTrue(storeSpy.messages.isEmpty)
    }
    
    func test_register_failsOnRegisterError() {
        let (serviceSpy, _, sut) = makeSUT()
        expect(sut,
               toRegisterWithEmail: "email",
               password: "password",
               andConfirmation: "password",
               withResult: .failure(anyNSError())) {
            serviceSpy.completeRegister(withResult: .failure(anyNSError()))
        }
    }
    
    func test_register_deliversRegisterResult() {
        let (serviceSpy, _, sut) = makeSUT()
        expect(sut,
               toRegisterWithEmail: "email",
               password: "password",
               andConfirmation: "password",
               withResult: .success(())) {
            serviceSpy.completeRegister(withResult: .success(()))
        }
    }
    
    // MARK: - logout
    
    func test_logout_requestsDeleteFromStoreAndLogoutFromService() {
        let (serviceSpy, storeSpy, sut) = makeSUT()
        
        let token = "token"
        sut.logout(token: token) { _ in }
        
        XCTAssertEqual(serviceSpy.messages, [AuthServiceSpy.Message.logout(token: token)])
        XCTAssertEqual(storeSpy.messages, [TokenStoreSpy.Message.delete])
    }
    
    func test_logout_failsOnLogoutError() {
        let (serviceSpy, _, sut) = makeSUT()
        expect(sut,
               toLogoutToken: "token",
               withResult: .failure(anyNSError())) {
            serviceSpy.completeLogout(withResult: .failure(anyNSError()))
        }
    }
    
    func test_logout_deliversLogoutResult() {
        let (serviceSpy, _, sut) = makeSUT()
        expect(sut,
               toLogoutToken: "token",
               withResult: .success(())) {
            serviceSpy.completeLogout(withResult: .success(()))
        }
    }
    
    // MARK: - forgot password
    
    func test_forgotPassword_requestsFromService() {
        let (serviceSpy, storeSpy, sut) = makeSUT()
        
        let email = "email"
        sut.forgotPassword(email: email) { _ in }
        
        XCTAssertEqual(serviceSpy.messages, [AuthServiceSpy.Message.forgotPassword(email: email)])
        XCTAssertEqual(storeSpy.messages, [])
    }
    
    func test_forgotPassword_failsOnLogoutError() {
        let (serviceSpy, _, sut) = makeSUT()
        expect(sut,
               toForgotPasswordFor: "email",
               withResult: .failure(anyNSError())) {
            serviceSpy.completeForgotPassword(withResult: .failure(anyNSError()))
        }
    }
    
    func test_forgotPassword_deliversLogoutResult() {
        let (serviceSpy, _, sut) = makeSUT()
        let expectedText = "some text"
        expect(sut,
               toForgotPasswordFor: "email",
               withResult: .success(expectedText)) {
            serviceSpy.completeForgotPassword(withResult: .success(expectedText))
        }
    }
    
    // MARK: - refresh token
    
    func test_refreshToken_requestsFromService() {
        let (serviceSpy, storeSpy, sut) = makeSUT()
        
        let token = "token"
        sut.refreshToken(token: token) { _ in }
        
        XCTAssertEqual(serviceSpy.messages, [AuthServiceSpy.Message.refreshToken(token: token)])
        XCTAssertTrue(storeSpy.messages.isEmpty)
    }
    
    func test_refreshToken_failsOnServiceFailure() {
        let (serviceSpy, _, sut) = makeSUT()
        expect(sut,
               toRefreshToken: "token",
               withResult: .failure(anyNSError())) {
            serviceSpy.completeRefreshToken(withResult: .failure(anyNSError()))
        }
    }
    
    func test_refreshToken_requestsSaveToStoreOnSuccessfulRefresh() {
        
        let (serviceSpy, storeSpy, sut) = makeSUT()
        
        let token = "token"
        sut.refreshToken(token: token) { _ in }
        
        let expectedToken = anyAuthToken()
        serviceSpy.completeRefreshToken(withResult: .success(expectedToken))
        
        XCTAssertEqual(serviceSpy.messages, [AuthServiceSpy.Message.refreshToken(token: token)])
        XCTAssertEqual(storeSpy.messages, [TokenStoreSpy.Message.save(expectedToken)])
    }
    
    func test_refreshToken_deliversRefreshTokenResult() {
        let (serviceSpy, _, sut) = makeSUT()
        let expectedToken = anyAuthToken()
        expect(sut,
               toRefreshToken: "token",
               withResult: .success(expectedToken)) {
            serviceSpy.completeRefreshToken(withResult: .success(expectedToken))
        }
    }
    
    // MARK: - helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (AuthServiceSpy, TokenStoreSpy, AuthServiceWithStore) {
        let serviceSpy = AuthServiceSpy()
        let storeSpy = TokenStoreSpy()
        let sut = AuthServiceWithStore(service: serviceSpy, store: storeSpy)
        trackForMemoryLeak(serviceSpy, file: file, line: line)
        trackForMemoryLeak(storeSpy, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (serviceSpy, storeSpy, sut)
    }
    
    func expect(_ sut: AuthServiceWithStore,
                toLoginWithEmail email: String,
                andPassword password: String,
                withResult expectedResult: Result<AuthToken, Error>,
                executing action: () -> (),
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for login completion")
        sut.login(withEmail: email,
                  andPassword: password) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success(let token), .success(let expectedToken)):
                XCTAssertEqual(token, expectedToken, file: file, line: line)
            default:
                XCTFail(file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    func expect(_ sut: AuthServiceWithStore,
                toRegisterWithEmail email: String,
                password: String,
                andConfirmation confirmation: String,
                withResult expectedResult: Result<(), Error>,
                executing action: () -> (),
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for register completion")
        sut.register(withEmail: email,
                     password: password,
                     passwordConfirmation: confirmation) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success, .success):
                ()
            default:
                XCTFail(file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    func expect(_ sut: AuthServiceWithStore,
                toLogoutToken token: String,
                withResult expectedResult: Result<(), Error>,
                executing action: () -> (),
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for logout completion")
        sut.logout(token: token) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success, .success):
                ()
            default:
                XCTFail(file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    func expect(_ sut: AuthServiceWithStore,
                toForgotPasswordFor email: String,
                withResult expectedResult: Result<String, Error>,
                executing action: () -> (),
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for forgot password completion")
        sut.forgotPassword(email: email) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success(let text), .success(let expectedText)):
                XCTAssertEqual(text, expectedText, file: file, line: line)
            default:
                XCTFail(file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    func expect(_ sut: AuthServiceWithStore,
                toRefreshToken token: String,
                withResult expectedResult: Result<AuthToken, Error>,
                executing action: () -> (),
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for refresh token completion")
        sut.refreshToken(token: token) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success(let token), .success(let expectedToken)):
                XCTAssertEqual(token, expectedToken, file: file, line: line)
            default:
                XCTFail(file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    func anyAuthToken() -> AuthToken {
        AuthToken(accessToken: "access",
                  refreshToken: "refresh",
                  tokenType: "type",
                  expiresIn: 100,
                  createdAt: 0)
    }
}
