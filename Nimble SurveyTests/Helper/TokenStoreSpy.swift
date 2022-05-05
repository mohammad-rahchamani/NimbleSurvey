//
//  TokenStoreSpy.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import Foundation
import Nimble_Survey

class TokenStoreSpy: TokenStore {
    
    private var stub: AuthToken?
    
    private(set) var messages: [Message] = []
    
    enum Message: Equatable {
        case load
        case save(AuthToken)
        case delete
    }
    
    func stub(with token: AuthToken?) {
        self.stub = token
    }
    
    func load() -> AuthToken? {
        messages.append(.load)
        return stub
    }
    
    func save(token: AuthToken) {
        messages.append(.save(token))
    }
    
    func delete() {
        messages.append(.delete)
    }
    
}
