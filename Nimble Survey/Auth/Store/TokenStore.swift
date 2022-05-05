//
//  TokenStore.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import Foundation

public typealias AuthHandler = TokenProvider & AuthService

public protocol TokenProvider {
    
    func token() -> AuthToken?
    
}

public protocol TokenStore {
    
    func load() -> AuthToken?
    func save(token: AuthToken)
    func delete()
    
}
