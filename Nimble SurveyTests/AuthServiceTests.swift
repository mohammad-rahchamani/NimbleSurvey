//
//  AuthServiceTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/3/22.
//

import XCTest
import Nimble_Survey

public struct AuthToken: Equatable, Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Double
    let createdAt: Double
}

public class AuthService {
    
    private let loader: RequestLoader
    private let baseURL: String
    private let clientId: String
    private let clientSecret: String
    
    public init(loader: RequestLoader,
                baseURL: String,
                clientId: String,
                clientSecret: String) {
        self.loader = loader
        self.baseURL = baseURL
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    public func login(withEmail email: String,
                      andPassword password: String,
                      completion: @escaping (Result<AuthToken, Error>) -> ()) {
        
        let data = LoginRequestData(grantType: "password",
                                    email: email,
                                    password: password,
                                    clientId: clientId,
                                    clientSecret: clientSecret)
        loader.load(request: loginRequest(withData: data)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(AuthServiceError.loaderError(error)))
            case .success(let data):
                completion(self.parseLoginData(data))
            }
        }
        
    }
    
    public func register(withEmail email: String,
                         password: String,
                         passwordConfirmation: String,
                         completion: @escaping (Result<(), Error>) -> ()) {
        
        let user = RegisterUserData(email: email,
                                    password: password,
                                    passwordConfirmation: passwordConfirmation)
        let data = RegisterRequestData(user: user,
                                       clientId: clientId,
                                       clientSecret: clientSecret)
        loader.load(request: registerRequest(withData: data)) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(AuthServiceError.loaderError(error)))
            case .success:
                completion(.success(()))
            }
        }
    }
    
    public func logout(token: String,
                       completion: @escaping (Result<(), Error>) -> ()) {
        let data = LogoutRequestData(token: token,
                                     clientId: clientId,
                                     clientSecret: clientSecret)
        loader.load(request: logoutRequest(withData: data)) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(AuthServiceError.loaderError(error)))
            case .success:
                completion(.success(()))
            }
        }
    }
    
    public func forgotPassword(email: String,
                               completion: @escaping (Result<(String), Error>) -> ()) {
        let user = ForgotPasswordUserData(email: email)
        let data = ForgotPasswordRequestData(user: user,
                                             clientId: clientId,
                                             clientSecret: clientSecret)
        
        loader.load(request: forgotPasswordRequest(withData: data)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(AuthServiceError.loaderError(error)))
            case .success(let data):
                completion(self.parseForgotPassword(data))
            }
        }
        
    }
    
    private func loginRequest(withData data: LoginRequestData) -> URLRequest {
        return request(forEndPoint: "/api/v1/oauth/token", data: data)
    }
    
    private func registerRequest(withData data: RegisterRequestData) -> URLRequest {
        return request(forEndPoint: "/api/v1/registrations", data: data)
    }
    
    private func logoutRequest(withData data: LogoutRequestData) -> URLRequest {
        return request(forEndPoint: "/api/v1/oauth/revoke", data: data)
    }
    
    private func forgotPasswordRequest(withData data: ForgotPasswordRequestData) -> URLRequest {
        return request(forEndPoint: "/api/v1/passwords", data: data)
    }
    
    private func request<T: Encodable>(forEndPoint endPoint: String, data: T) -> URLRequest {
        let url = URL(string: "\(baseURL)\(endPoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(data)
        return request
    }
    
    private func parseLoginData(_ data: Data) -> Result<AuthToken, Error> {
        return parse(data).map { (response: LoginResponseData) in
            response.data.attributes
        }
    }
    
    private func parseForgotPassword(_ data: Data) -> Result<String, Error> {
        return parse(data).map { (response: ForgotPasswordResponseData) in
            response.meta.message
        }
    }
    
    private func parse<T: Decodable>(_ data: Data) -> Result<T, Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch {
            return .failure(AuthServiceError.invalidData)
        }
    }
    
    private struct LoginRequestData: Codable {
        let grantType: String
        let email: String
        let password: String
        let clientId: String
        let clientSecret: String
    }
    
    private struct RegisterUserData: Codable {
        let email: String
        let password: String
        let passwordConfirmation: String
    }
    
    private struct RegisterRequestData: Codable {
        let user: RegisterUserData
        let clientId: String
        let clientSecret: String
    }
    
    private struct LogoutRequestData: Codable {
        let token: String
        let clientId: String
        let clientSecret: String
    }
    
    private struct ForgotPasswordUserData: Codable {
        let email: String
    }
    
    private struct ForgotPasswordRequestData: Codable {
        let user: ForgotPasswordUserData
        let clientId: String
        let clientSecret: String
    }
    
    private struct AuthTokenData: Codable {
        let id: Int
        let type: String
        let attributes: AuthToken
    }
    
    private struct LoginResponseData: Codable {
        let data: AuthTokenData
    }
    
    private struct ForgotPasswordResponseData: Codable {
        let meta: ForgotPasswordResponseMessage
    }
    
    private struct ForgotPasswordResponseMessage: Codable {
        let message: String
    }
    
    private enum AuthServiceError: Error {
        case loaderError(Error)
        case invalidData
    }
    
}

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

class RequestLoaderSpy: RequestLoader {
    
    private(set) var messages: [URLRequest : (Result<Data, Error>) -> ()] = [:]
    
    func load(request: URLRequest,
              completion: @escaping (Result<Data, Error>) -> ()) {
        messages[request] = completion
    }
    
    func completeLoad(for request: URLRequest, with result: Result<Data, Error>) {
        messages[request]?(result)
    }
    
    func completeLoad(at index: Int = 0, with result: Result<Data, Error>) {
        Array(messages.values)[index](result)
    }
    
    
}
