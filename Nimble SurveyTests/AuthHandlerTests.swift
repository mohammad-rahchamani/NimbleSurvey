//
//  AuthHandlerTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import XCTest
import Nimble_Survey

public class AuthHandler {
    
    private let service: AuthService
    private let store: TokenStore
    
    public init(service: AuthService, store: TokenStore) {
        self.service = service
        self.store = store
    }
    
}

class AuthHandlerTests: XCTestCase {

}
