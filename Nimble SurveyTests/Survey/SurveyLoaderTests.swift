//
//  SurveyLoaderTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import XCTest
import Nimble_Survey

public class SurveyLoaderTests: XCTestCase {
    
    func expect(_ sut: SurveyLoader,
                toLoadPage page: Int,
                withSize size: Int,
                tokenType: String,
                accessToken: String,
                withResult expectedResult: Result<[Survey], Error>,
                executing action: () -> (),
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for load completion")
        sut.load(page: page,
                 size: size,
                 tokenType: tokenType,
                 accessToken: accessToken) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success(let surveys), .success(let expectedSurveys)):
                XCTAssertEqual(surveys, expectedSurveys, file: file, line: line)
            default:
                XCTFail(file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    func expect(_ sut: SurveyLoader,
                toGetDetailsFor surveyId: String,
                tokenType: String,
                accessToken: String,
                withResult expectedResult: Result<[SurveyDetail], Error>,
                executing action: () -> (),
                file: StaticString = #filePath,
                line: UInt = #line) {
        let exp = XCTestExpectation(description: "waiting for get details completion")
        sut.getDetails(forSurvey: surveyId,
                       tokenType: tokenType,
                       accessToken: accessToken) { result in
            switch (result, expectedResult) {
            case (.failure, .failure):
                ()
            case (.success(let surveys), .success(let expectedSurveys)):
                XCTAssertEqual(surveys, expectedSurveys, file: file, line: line)
            default:
                XCTFail(file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
