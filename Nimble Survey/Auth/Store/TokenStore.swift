//
//  TokenStore.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import Foundation

public protocol TokenStore {
    
    func load() -> AuthToken?
    func save(token: AuthToken)
    func delete()
    
}
