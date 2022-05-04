//
//  AuthServiceTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/3/22.
//

import XCTest
import Nimble_Survey

class AuthServiceTests: XCTestCase {

    func test_init_doesNotMessageLoader() {
        let (spy, _) = makeSUT()
        XCTAssertEqual(spy.messages.count, 0)
    }

    // MARK: - login
    
    func test_login_requestsLoader() {
        let url = "https:/any-url.com"
        let email = "email"
        let password = "password"
        let (spy, sut) = makeSUT(baseURL: url)
        
        sut.login(withEmail: email, andPassword: password) { _ in }
        
        let expectedURL = URL(string: "\(url)/api/v1/oauth/token")!
        
        XCTAssertEqual(spy.messages.count, 1)
        let capturedRequest = spy.messages.keys.first!
        XCTAssertEqual(capturedRequest.url, expectedURL)
        XCTAssertEqual(capturedRequest.httpMethod, "POST")
        XCTAssertNotNil(capturedRequest.httpBody)
    }
    
    func test_login_failsOnLoaderError() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toLoginWithEmail: "",
               andPassword: "",
               withResult: .failure(anyNSError())) {
            spy.completeLoad(with: .failure(anyNSError()))
        }
    }
    
    func test_login_failsOnInvalidData() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toLoginWithEmail: "",
               andPassword: "",
               withResult: .failure(anyNSError())) {
            spy.completeLoad(with: .success(Data()))
        }
    }
    
    func test_login_deliversTokenOnLoaderData() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toLoginWithEmail: "",
               andPassword: "",
               withResult: .success(sampleAuthToken())) {
            spy.completeLoad(with: .success(sampleAuthData()))
        }
    }
    
    func test_login_doesNotCallCompletionAfterObjectDeallocated() {
        let spy = RequestLoaderSpy()
        var sut: AuthService? = AuthService(loader: spy,
                                            baseURL: "https://any-url.com",
                                            clientId: "",
                                            clientSecret: "")
        sut?.login(withEmail: "", andPassword: "") { _ in
            XCTFail()
        }
        
        sut = nil
        spy.completeLoad(with: .success(sampleAuthData()))
    }
    
    // MARK: - register
    
    func test_register_requestsLoader() {
        let url = "https:/any-url.com"
        let email = "email"
        let password = "password"
        let confirm = "password"
        let (spy, sut) = makeSUT(baseURL: url)
        
        sut.register(withEmail: email,
                     password: password,
                     passwordConfirmation: confirm) { _ in }
        
        let expectedURL = URL(string: "\(url)/api/v1/registrations")!
        
        XCTAssertEqual(spy.messages.count, 1)
        let capturedRequest = spy.messages.keys.first!
        XCTAssertEqual(capturedRequest.url, expectedURL)
        XCTAssertEqual(capturedRequest.httpMethod, "POST")
        XCTAssertNotNil(capturedRequest.httpBody)
    }
    
    func test_register_failsOnLoaderError() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toRegisterWithEmail: "",
               password: "",
               andConfirmation: "",
               withResult: .failure(anyNSError())) {
            spy.completeLoad(with: .failure(anyNSError()))
        }
    }
    
    func test_register_deliversSuccessOnLoaderData() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toRegisterWithEmail: "",
               password: "",
               andConfirmation: "",
               withResult: .success(())) {
            spy.completeLoad(with: .success(Data()))
        }
    }
    
    func test_register_doesNotCallCompletionAfterObjectDeallocated() {
        let spy = RequestLoaderSpy()
        var sut: AuthService? = AuthService(loader: spy,
                                            baseURL: "https://any-url.com",
                                            clientId: "",
                                            clientSecret: "")
        sut?.register(withEmail: "", password: "", passwordConfirmation: "") { _ in
            XCTFail()
        }
        
        sut = nil
        spy.completeLoad(with: .success(Data()))
    }
    
    // MARK: - logout
    
    func test_logout_requestsLoader() {
        let url = "https:/any-url.com"
        let (spy, sut) = makeSUT(baseURL: url)
        
        sut.logout(token: "") { _ in }
        
        let expectedURL = URL(string: "\(url)/api/v1/oauth/revoke")!
        
        XCTAssertEqual(spy.messages.count, 1)
        let capturedRequest = spy.messages.keys.first!
        XCTAssertEqual(capturedRequest.url, expectedURL)
        XCTAssertEqual(capturedRequest.httpMethod, "POST")
        XCTAssertNotNil(capturedRequest.httpBody)
    }
    
    func test_logout_failsOnLoaderError() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toLogoutToken: "token",
               withResult: .failure(anyNSError())) {
            spy.completeLoad(with: .failure(anyNSError()))
        }
    }
    
    func test_logout_deliversSuccessOnLoaderData() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toLogoutToken: "token",
               withResult: .success(())) {
            spy.completeLoad(with: .success(Data()))
        }
    }
    
    func test_logout_doesNotCallCompletionAfterObjectDeallocated() {
        let spy = RequestLoaderSpy()
        var sut: AuthService? = AuthService(loader: spy,
                                            baseURL: "https://any-url.com",
                                            clientId: "",
                                            clientSecret: "")
        sut?.logout(token: "token") { _ in
            XCTFail()
        }
        
        sut = nil
        spy.completeLoad(with: .success(Data()))
    }
    
    // MARK: - forgot password
    
    func test_forgotPassword_requestsLoader() {
        let url = "https:/any-url.com"
        let (spy, sut) = makeSUT(baseURL: url)
        
        sut.forgotPassword(email: "") { _ in }
        
        let expectedURL = URL(string: "\(url)/api/v1/passwords")!
        
        XCTAssertEqual(spy.messages.count, 1)
        let capturedRequest = spy.messages.keys.first!
        XCTAssertEqual(capturedRequest.url, expectedURL)
        XCTAssertEqual(capturedRequest.httpMethod, "POST")
        XCTAssertNotNil(capturedRequest.httpBody)
    }
    
    func test_forgotPassword_failsOnLoaderError() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toForgotPasswordForEmail: "email",
               withResult: .failure(anyNSError())) {
            spy.completeLoad(with: .failure(anyNSError()))
        }
    }
    
    func test_forgotPassword_deliversSuccessOnLoaderData() {
        let (spy, sut) = makeSUT()
        
        expect(sut,
               toForgotPasswordForEmail: "email",
               withResult: .success(sampleForgotPasswordMessage())) {
            spy.completeLoad(with: .success(sampleForgotPasswordData()))
        }
    }
    
    func test_forgotPassword_doesNotCallCompletionAfterObjectDeallocated() {
        let spy = RequestLoaderSpy()
        var sut: AuthService? = AuthService(loader: spy,
                                            baseURL: "https://any-url.com",
                                            clientId: "",
                                            clientSecret: "")
        sut?.forgotPassword(email: "email") { _ in
            XCTFail()
        }
        
        sut = nil
        spy.completeLoad(with: .success(sampleForgotPasswordData()))
    }
    
    // MARK: - helpers
    
    func makeSUT(baseURL: String = "https://some-url.com",
                 clientId: String = "id",
                 clientSecret: String = "secret",
                 file: StaticString = #filePath,
                 line: UInt = #line) -> (RequestLoaderSpy, AuthService) {
        let spy = RequestLoaderSpy()
        let sut = AuthService(loader: spy,
                              baseURL: baseURL,
                              clientId: clientId,
                              clientSecret: clientSecret)
        trackForMemoryLeak(spy, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (spy, sut)
    }
    
    func expect(_ sut: AuthService,
                toLoginWithEmail email: String,
                andPassword password: String,
                withResult expectedResult: Result<AuthToken, Error>,
                executing action: () -> (),
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for login completion")
        sut.login(withEmail: email, andPassword: password) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success(let data), .success(let expectedData)):
                XCTAssertEqual(data, expectedData, file: file, line: line)
            default:
                XCTFail(file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    func expect(_ sut: AuthService,
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
    
    func expect(_ sut: AuthService,
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
    
    func expect(_ sut: AuthService,
                toForgotPasswordForEmail email: String,
                withResult expectedResult: Result<String, Error>,
                executing action: () -> (),
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for forgot password completion")
        sut.forgotPassword(email: email) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success(let data), .success(let expectedData)):
                XCTAssertEqual(data, expectedData, file: file, line: line)
            default:
                XCTFail(file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    func sampleAuthToken() -> AuthToken {
        AuthToken(accessToken: "lbxD2K2BjbYtNzz8xjvh2FvSKx838KBCf79q773kq2c",
                  refreshToken: "3zJz2oW0njxlj_I3ghyUBF7ZfdQKYXd2n0ODlMkAjHc",
                  tokenType: "Bearer",
                  expiresIn: 7200,
                  createdAt: 1597169495)
    }
    
    func sampleAuthData() -> Data {
        let data: String = """
            {
              "data": {
                "id": 10,
                "type": "token",
                "attributes": {
                  "access_token": "lbxD2K2BjbYtNzz8xjvh2FvSKx838KBCf79q773kq2c",
                  "token_type": "Bearer",
                  "expires_in": 7200,
                  "refresh_token": "3zJz2oW0njxlj_I3ghyUBF7ZfdQKYXd2n0ODlMkAjHc",
                  "created_at": 1597169495
                }
              }
            }
            """
        return data.data(using: .utf8)!
        
    }
    
    func sampleForgotPasswordMessage() -> String {
        "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."
    }
    
    func sampleForgotPasswordData() -> Data {
        
        let data: String = """
            {
              "meta": {
                "message": "\(sampleForgotPasswordMessage())"
              }
            }
            """
        return data.data(using: .utf8)!
    }
}
