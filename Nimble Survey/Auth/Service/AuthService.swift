//
//  AuthService.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import Foundation

public protocol AuthService {
    
    func login(withEmail email: String,
               andPassword password: String,
               completion: @escaping (Result<AuthToken, Error>) -> ())
    
    func register(withEmail email: String,
                  password: String,
                  passwordConfirmation: String,
                  completion: @escaping (Result<(), Error>) -> ())
    
    func logout(token: String,
                completion: @escaping (Result<(), Error>) -> ())
    
    func forgotPassword(email: String,
                        completion: @escaping (Result<String, Error>) -> ())
    
    func refreshToken(token: String,
                      completion: @escaping (Result<AuthToken, Error>) -> ())
}
