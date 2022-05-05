//
//  AuthToken.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import Foundation
public struct AuthToken: Equatable, Codable {
    
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    public let expiresIn: Double
    public let createdAt: Double
    
    public init(accessToken: String, refreshToken: String, tokenType: String, expiresIn: Double, createdAt: Double) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.createdAt = createdAt
    }
}
