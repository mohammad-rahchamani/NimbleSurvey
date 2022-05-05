//
//  AuthServiceWithStore.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import Foundation

public class AuthServiceWithStore: AuthService {
    
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
        service.refreshToken(token: token) { [weak self] result in
            guard let self = self else { return }
            if let token = try? result.get() {
                self.store.save(token: token)
            }
            completion(result)
        }
    }
    
    
}
