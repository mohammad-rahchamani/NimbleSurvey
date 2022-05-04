//
//  SurveyLoaderTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import XCTest
import Nimble_Survey

public struct SurveyRelationship: Equatable, Codable {
    let questions: SurveyQuestions
}

public struct SurveyQuestions: Equatable, Codable {
    let data: [SurveyQuestion]
}

public struct SurveyQuestion: Equatable, Codable {
    let id: String
    let type: String
}

public struct SurveyAttributes: Equatable, Codable {
    let title: String
    let description: String
    let thankEmailAboveThreshold: String
    let thankEmailBelowThreshold: String
    let isActive: Bool
    let coverImageUrl: String
    let createdAt: String
    let activeAt: String
    let inactiveAt: String?
    let surveyType: String
}

public struct Survey: Equatable, Codable {
    let id: String
    let type: String
    let attibutes: SurveyAttributes
    let relationships: SurveyRelationship
}

public class SurveyLoader {
    let baseURL = ""
    let loader: RequestLoader
    
    public init(loader: RequestLoader) {
        self.loader = loader
    }
    
    public func load(page: Int,
                     size: Int,
                     tokenType: String,
                     accessToken: String,
                     completion: @escaping (Result<[Survey], Error>) -> ()) {
        
        loader.load(request: surveyListRequest(page: page,
                                               size: size,
                                               tokenType: tokenType,
                                               accessToken: accessToken)) { result in
            
        }
        
    }
    
    private func surveyListRequest(page: Int,
                                   size: Int,
                                   tokenType: String,
                                   accessToken: String) -> URLRequest {
        var components = URLComponents(string: "\(baseURL)/api/v1/surveys")!
        components.queryItems = [
            URLQueryItem(name: "page[number]", value: "\(page)"),
            URLQueryItem(name: "page[size]", value: "\(size)")
        ]
        let url = components.url!
        var request = URLRequest(url: url)
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Authorization"] = "\(tokenType) \(accessToken)"
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        return request
    }
    
    struct ResponseMetadata: Codable {
        let page: Int
        let pages: Int
        let pageSize: Int
        let records: Int
    }
    
    private struct SurveyResponse: Codable {
        let data: [Survey]
        let meta: ResponseMetadata
    }
    
}

class SurveyLoaderTests: XCTestCase {

    func test_init_doesNotMessageLoader() {
        let (spy, _) = makeSUT()
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_load_requestsLoader() {
        let (spy, sut) = makeSUT()
        
        let tokenType = "Bearer"
        let accessToken = "token"
        
        sut.load(page: 1,
                 size: 10,
                 tokenType: tokenType,
                 accessToken: accessToken) { result in
            
        }
        
        let capturedRequest = spy.messages.keys.first!
        XCTAssertEqual(capturedRequest.httpMethod, "GET")
        XCTAssertEqual(capturedRequest.allHTTPHeaderFields!["Authorization"], "\(tokenType) \(accessToken)")
    }
    
    
    
    // MARK: - helpers
    
    func makeSUT(file: StaticString = #filePath,
                 line: UInt = #line) -> (RequestLoaderSpy, SurveyLoader) {
        let spy = RequestLoaderSpy()
        let sut = SurveyLoader(loader: spy)
        trackForMemoryLeak(spy, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (spy, sut)
    }
    
}
