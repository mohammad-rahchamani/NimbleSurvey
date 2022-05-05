//
//  SurveyLoaderWithAuth.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import Foundation

public class SurveyLoaderWithAuth {
    
    private let loader: SurveyLoader
    private let authHandler: AuthHandler
    
    public init(loader: SurveyLoader, authHandler: AuthHandler) {
        self.loader = loader
        self.authHandler = authHandler
    }
    
    public func load(page: Int,
                     size: Int,
                     completion: @escaping (Result<[Survey], Error>) -> ()) {
        validateToken(invalidTokenClosure: { token in
            refreshTokenAndLoad(token.refreshToken,
                                page: page,
                                size: size,
                                completion: completion)
        }, validTokenClosure: { token in
            self.loader.load(page: page,
                             size: size,
                             tokenType: token.tokenType,
                             accessToken: token.accessToken,
                             completion: completion)
        }, completion: completion)
    }
    
    private func refreshTokenAndLoad(_ token: String,
                                     page: Int,
                                     size: Int,
                                     completion: @escaping (Result<[Survey], Error>) -> ()) {
        refreshToken(token, andExecute: { [weak self] in
            guard let self = self else { return }
            self.load(page: page, size: size, completion: completion)
        }, completion: completion)
    }
    
    private func isValid(token: AuthToken) -> Bool {
        let expirationDate = Date(timeIntervalSinceReferenceDate: token.createdAt).addingTimeInterval(token.expiresIn)
        return expirationDate > Date()
    }
    
    public func getDetails(forSurvey id: String,
                           completion: @escaping (Result<[SurveyDetail], Error>) -> ()) {
        
        validateToken(invalidTokenClosure: { token in
            refreshTokenAndGetDetails(token.refreshToken,
                                      surveyId: id,
                                      completion: completion)
        }, validTokenClosure: { token in
            self.loader.getDetails(forSurvey: id,
                                   tokenType: token.tokenType,
                                   accessToken: token.accessToken,
                                   completion: completion)
        }, completion: completion)
        
    }
    
    private func refreshTokenAndGetDetails(_ token: String,
                                           surveyId id: String ,
                                           completion: @escaping (Result<[SurveyDetail], Error>) -> ()) {
        refreshToken(token, andExecute: { [weak self] in
            guard let self = self else { return }
            self.getDetails(forSurvey: id, completion: completion)
        }, completion: completion)
    }
    
    private func refreshToken<T>(_ refreshToken: String,
                                 andExecute action: @escaping () -> (),
                                 completion: @escaping (Result<T, Error>) -> ()) {
        authHandler.refreshToken(token: refreshToken) { [weak self] result in
            guard let self = self else { return }
            guard (self.authHandler.token()) != nil else {
                completion(.failure(LoaderWithAuthError.refreshTokenError))
                return
            }
            action()
        }
    }
    
    private func validateToken<T>(invalidTokenClosure: (AuthToken) -> (),
                                  validTokenClosure: (AuthToken) -> (),
                                  completion: @escaping (Result<[T], Error>) -> ()) {
        guard let currentToken = authHandler.token() else {
            completion(.failure(LoaderWithAuthError.noToken))
            return
        }
        guard isValid(token: currentToken) else {
            invalidTokenClosure(currentToken)
            return
        }
        validTokenClosure(currentToken)
    }
    
    private enum LoaderWithAuthError: Error {
        case noToken
        case refreshTokenError
    }
}
