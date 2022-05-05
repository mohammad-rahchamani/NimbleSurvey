//
//  AuthServiceSpy.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import Foundation
import Nimble_Survey

class AuthServiceSpy: AuthHandler {
    
    private(set) var messages: [Message] = []
    private var stub: AuthToken?
    
    private var loginCompletions: [(Result<AuthToken, Error>) -> ()] = []
    private var registerCompletions: [(Result<(), Error>) -> ()] = []
    private var logoutCompletions: [(Result<(), Error>) -> ()] = []
    private var forgotPasswordCompletions: [(Result<String, Error>) -> ()] = []
    private var refreshTokenCompletions: [(Result<AuthToken, Error>) -> ()] = []
    
    enum Message: Equatable, Hashable {
        case login(email: String, password: String)
        case register(email: String, password: String, confirmation: String)
        case logout(token: String)
        case forgotPassword(email: String)
        case refreshToken(token: String)
        case token
    }
    
    func stub(_ token: AuthToken?) {
        self.stub = token
    }
    
    func token() -> AuthToken? {
        messages.append(.token)
        return stub
    }
    
    func login(withEmail email: String,
               andPassword password: String,
               completion: @escaping (Result<AuthToken, Error>) -> ()) {
        messages.append(.login(email: email,
                               password: password))
        loginCompletions.append(completion)
    }
    
    func register(withEmail email: String,
                  password: String,
                  passwordConfirmation: String,
                  completion: @escaping (Result<(), Error>) -> ()) {
        messages.append(.register(email: email,
                                  password: password,
                                  confirmation: passwordConfirmation))
        registerCompletions.append(completion)
    }
    
    func logout(token: String,
                completion: @escaping (Result<(), Error>) -> ()) {
        messages.append(.logout(token: token))
        logoutCompletions.append(completion)
    }
    
    func forgotPassword(email: String,
                        completion: @escaping (Result<String, Error>) -> ()) {
        messages.append(.forgotPassword(email: email))
        forgotPasswordCompletions.append(completion)
    }
    
    func refreshToken(token: String,
                      completion: @escaping (Result<AuthToken, Error>) -> ()) {
        messages.append(.refreshToken(token: token))
        refreshTokenCompletions.append(completion)
    }
    
    public func completeLogin(at index: Int = 0, withResult result: Result<AuthToken, Error>) {
        self.stub = try? result.get()
        loginCompletions[index](result)
    }
    
    public func completeRegister(at index: Int = 0, withResult result: Result<(), Error>) {
        registerCompletions[index](result)
    }
    
    public func completeLogout(at index: Int = 0, withResult result: Result<(), Error>) {
        self.stub = nil
        logoutCompletions[index](result)
    }
    
    public func completeForgotPassword(at index: Int = 0, withResult result: Result<String, Error>) {
        forgotPasswordCompletions[index](result)
    }
    
    public func completeRefreshToken(at index: Int = 0, withResult result: Result<AuthToken, Error>) {
        self.stub = try? result.get()
        refreshTokenCompletions[index](result)
    }
    
}
