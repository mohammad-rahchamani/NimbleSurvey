//
//  AuthToken.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import Foundation
public struct AuthToken: Equatable, Codable {
    
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Double
    let createdAt: Double
    
    public init(accessToken: String, refreshToken: String, tokenType: String, expiresIn: Double, createdAt: Double) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.createdAt = createdAt
    }
}
