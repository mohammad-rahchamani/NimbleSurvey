//
//  AuthHandlerTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import XCTest
import Nimble_Survey

public class AuthHandler: AuthService {
    
    private let service: AuthService
    private let store: TokenStore
    
    public init(service: AuthService, store: TokenStore) {
        self.service = service
        self.store = store
    }
    public func login(withEmail email: String,
                      andPassword password: String,
                      completion: @escaping (Result<AuthToken, Error>) -> ()) {
        service.login(withEmail: email,
                      andPassword: password) { [weak self] result in
            guard let self = self else { return }
            if let token = try? result.get() {
                self.store.save(token: token)
            }
            completion(result)
        }
    }
    
    public func register(withEmail email: String,
                         password: String, passwordConfirmation: String,
                         completion: @escaping (Result<(), Error>) -> ()) {
        service.register(withEmail: email,
                         password: password,
                         passwordConfirmation: passwordConfirmation,
                         completion: completion)
    }
    
    public func logout(token: String, completion: @escaping (Result<(), Error>) -> ()) {
        store.delete()
        service.logout(token: token, completion: completion)
    }
    
    public func forgotPassword(email: String, completion: @escaping (Result<String, Error>) -> ()) {
        service.forgotPassword(email: email,
                               completion: completion)
    }
    
    public func refreshToken(token: String, completion: @escaping (Result<AuthToken, Error>) -> ()) {
        service.refreshToken(token: token) { result in
            if let token = try? result.get() {
                self.store.save(token: token)
            }
            completion(result)
        }
    }
    
    
}

class AuthHandlerTests: XCTestCase {
    
    func test_init_doesNotMessageServiceAndStore() {
        let (serviceSpy, storeSpy, _) = makeSUT()
        XCTAssertTrue(serviceSpy.messages.isEmpty)
        XCTAssertTrue(storeSpy.messages.isEmpty)
    }
    
    func test_login_requestsLoginFromService() {
        let (serviceSpy, storeSpy, sut) = makeSUT()
        
        let email = "email"
        let password = "password"
        sut.login(withEmail: email,
                  andPassword: password) { _ in }
        
        XCTAssertEqual(serviceSpy.messages.first, AuthServiceSpy.Message.login(email: email,
                                                                               password: password))
        XCTAssertTrue(storeSpy.messages.isEmpty)
    }
    
    func test_login_failsOnLoginError() {
        let (serviceSpy, _, sut) = makeSUT()
        
        let exp = XCTestExpectation(description: "waiting for login completion")
        sut.login(withEmail: "",
                  andPassword: "") { result in
            switch result {
            case .failure:
                ()
            case .success:
                XCTFail()
            }
            exp.fulfill()
        }
        
        serviceSpy.completeLogin(withResult: .failure(anyNSError()))
        wait(for: [exp], timeout: 1)
    }
    
    func test_login_requestsSaveToStoreOnSuccessfulLogin() {
        
        let (serviceSpy, storeSpy, sut) = makeSUT()
        
        let email = "email"
        let password = "password"
        sut.login(withEmail: email,
                  andPassword: password) { _ in }
        
        let expectedToken = AuthToken(accessToken: "access",
                                      refreshToken: "refresh",
                                      tokenType: "type",
                                      expiresIn: 100,
                                      createdAt: 0)
        serviceSpy.completeLogin(withResult: .success(expectedToken))
        
        XCTAssertEqual(serviceSpy.messages.first, AuthServiceSpy.Message.login(email: email,
                                                                               password: password))
        XCTAssertEqual(storeSpy.messages.first, TokenStoreSpy.Message.save(expectedToken))
    }
    
    // MARK: - helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (AuthServiceSpy, TokenStoreSpy, AuthHandler) {
        let serviceSpy = AuthServiceSpy()
        let storeSpy = TokenStoreSpy()
        let sut = AuthHandler(service: serviceSpy, store: storeSpy)
        trackForMemoryLeak(serviceSpy, file: file, line: line)
        trackForMemoryLeak(storeSpy, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (serviceSpy, storeSpy, sut)
    }
}






func test_login_deliversLoginResult() {
    
}
