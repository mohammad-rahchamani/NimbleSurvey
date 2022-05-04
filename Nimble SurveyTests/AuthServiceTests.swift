//
//  AuthServiceTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/3/22.
//

import XCTest
import Nimble_Survey

class AuthService {
    
    private let loader: RequestLoader
    private let baseURL: String
    private let clientId: String
    private let clientSecret: String
    
    init(loader: RequestLoader,
         baseURL: String,
         clientId: String,
         clientSecret: String) {
        self.loader = loader
        self.baseURL = baseURL
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    func login(withEmail email: String,
               andPassword password: String,
               completion: @escaping (Result<Bool, Error>) -> ()) {
        
        let data = LoginRequestData(grantType: "password",
                                    email: email,
                                    password: password,
                                    clientId: clientId,
                                    clientSecret: clientSecret)
        loader.load(request: loginRequest(withData: data)) { _ in }
        
    }
    
    private func loginRequest(withData data: LoginRequestData) -> URLRequest {
        let url = URL(string: "\(baseURL)/api/v1/oauth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(data)
        return request
    }
    
    private struct LoginRequestData: Codable {
        let grantType: String
        let email: String
        let password: String
        let clientId: String
        let clientSecret: String
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
        trackForMemoryLeak(spy)
        trackForMemoryLeak(sut)
        return (spy, sut)
    }

}
