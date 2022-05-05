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
    
    func test_handler_doesNotMessageServiceAndStore() {
        
        let serviceSpy = AuthServiceSpy()
        let storeSpy = TokenStoreSpy()
        let _ = AuthHandler(service: serviceSpy, store: storeSpy)
        
        XCTAssertTrue(serviceSpy.messages.isEmpty)
        XCTAssertTrue(storeSpy.messages.isEmpty)
        
    }

}
