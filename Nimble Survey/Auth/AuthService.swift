//
//  AuthService.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import Foundation

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
    
    public func refreshToken(token: String,
                             completion: @escaping (Result<AuthToken, Error>) -> ()) {
        let data = RefreshTokenRequestData(grantType: "refresh_token",
                                           refreshToken: token,
                                           clientId: clientId,
                                           clientSecret: clientSecret)
        loader.load(request: refreshTokenRequest(withData: data)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(AuthServiceError.loaderError(error)))
            case .success(let data):
                completion(self.parseRefreshToken(data))
            }
        }
    }
}

// MARK: - data types
extension AuthService {
    
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
    
    private struct RefreshTokenRequestData: Codable {
        let grantType: String
        let refreshToken: String
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

// MARK: - requests
extension AuthService {
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
    
    private func refreshTokenRequest(withData data: RefreshTokenRequestData) -> URLRequest {
        return request(forEndPoint: "/api/v1/oauth/token", data: data)
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
}

// MARK: - parsers
extension AuthService {
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
    
    private func parseRefreshToken(_ data: Data) -> Result<AuthToken, Error> {
        return parse(data).map { (response: LoginResponseData) in
            response.data.attributes
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
}
