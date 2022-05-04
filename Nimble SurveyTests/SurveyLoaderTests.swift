//
//  SurveyLoaderTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import XCTest
import Nimble_Survey

public class SurveyLoader {
    
    let loader: RequestLoader
    
    init(loader: RequestLoader) {
        self.loader = loader
    }
    
    
    
}

class SurveyLoaderTests: XCTestCase {

    func test_init_doesNotMessageLoader() {
        let spy = RequestLoaderSpy()
        _ = SurveyLoader(loader: spy)
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
}
