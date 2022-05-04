//
//  SurveyLoaderTests.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import XCTest
import Nimble_Survey

class SurveyLoaderTests: XCTestCase {

    func test_init_doesNotMessageLoader() {
        let (spy, _) = makeSUT()
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    // MARK: - load
    
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
    
    func test_load_failsOnLoaderError() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toLoadPage: 1,
               withSize: 10,
               tokenType: "token",
               accessToken: "token",
               withResult: .failure(anyNSError())) {
            spy.completeLoad(with: .failure(anyNSError()))
        }
    }
    
    func test_load_failsOnInvalidData() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toLoadPage: 1,
               withSize: 10,
               tokenType: "token",
               accessToken: "token",
               withResult: .failure(anyNSError())) {
            spy.completeLoad(with: .success(Data()))
        }
    }
    
    func test_load_deliversLoaderData() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toLoadPage: 1,
               withSize: 10,
               tokenType: "token",
               accessToken: "token",
               withResult: .success(sampleSurveyList())) {
            spy.completeLoad(with: .success(sampleSurveyListData()))
        }
    }
    
    func test_load_doesNotCallCompletionAfterObjectDeallocated() {
        let spy = RequestLoaderSpy()
        var sut: SurveyLoader? = SurveyLoader(loader: spy, baseURL: "")
        sut?.load(page: 1, size: 10, tokenType: "", accessToken: "") { _ in
            XCTFail()
        }
        
        sut = nil
        spy.completeLoad(with: .success(sampleSurveyListData()))
    }
    
    // MARK: - get details
    
    func test_getDetails_requestsLoader() {
        let baseURL = "https://some-url.com"
        let (spy, sut) = makeSUT(baseURL: baseURL)
        
        let surveyId = "survey"
        let tokenType = "Bearer"
        let accessToken = "token"
        
        sut.getDetails(forSurvey: surveyId,
                       tokenType: tokenType,
                       accessToken: accessToken) { result in
            
        }
        
        let capturedRequest = spy.messages.keys.first!
        XCTAssertEqual(capturedRequest.url, URL(string: "\(baseURL)/api/v1/surveys/\(surveyId)"))
        XCTAssertEqual(capturedRequest.httpMethod, "GET")
        XCTAssertEqual(capturedRequest.allHTTPHeaderFields!["Authorization"], "\(tokenType) \(accessToken)")
    }
    
    func test_getDetails_failsOnLoaderError() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toGetDetailsFor: "id",
               tokenType: "token",
               accessToken: "token",
               withResult: .failure(anyNSError())) {
            spy.completeLoad(with: .failure(anyNSError()))
        }
    }
    
    func test_getDetails_failsOnInvalidData() {
        let (spy, sut) = makeSUT()
        expect(sut,
               toGetDetailsFor: "id",
               tokenType: "token",
               accessToken: "token",
               withResult: .failure(anyNSError())) {
            spy.completeLoad(with: .success(Data()))
        }
    }
    
    func test_getDetails_deliversLoaderData() {
        let (spy, sut) = makeSUT()
        
        expect(sut,
               toGetDetailsFor: "id",
               tokenType: "token",
               accessToken: "token",
               withResult: .success(sampleSurveyDetails())) {
            spy.completeLoad(with: .success(sampleSurveyDetailsData()))
        }
    }
    
    func test_getDetails_doesNotCallCompletionAfterObjectDeallocated() {
        let spy = RequestLoaderSpy()
        var sut: SurveyLoader? = SurveyLoader(loader: spy, baseURL: "https://any-url.com")
        sut?.getDetails(forSurvey: "", tokenType: "", accessToken: "") { _ in
            XCTFail()
        }
        
        sut = nil
        spy.completeLoad(with: .success(sampleSurveyDetailsData()))
    }
    
    // MARK: - helpers
    
    func makeSUT(baseURL: String = "https://any-url.com",
                 file: StaticString = #filePath,
                 line: UInt = #line) -> (RequestLoaderSpy, SurveyLoader) {
        let spy = RequestLoaderSpy()
        let sut = SurveyLoader(loader: spy, baseURL: baseURL)
        trackForMemoryLeak(spy, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (spy, sut)
    }
    
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
 
    func sampleSurveyListData() -> Data {
        let data = """
            {
              "data": [
                {
                  "id": "d5de6a8f8f5f1cfe51bc",
                  "type": "survey",
                  "attributes": {
                    "title": "Scarlett Bangkok",
                    "description": "We'd love ot hear from you!",
                    "thank_email_above_threshold": "sample email above",
                    "thank_email_below_threshold": "sample email below",
                    "is_active": true,
                    "cover_image_url": "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_",
                    "created_at": "2017-01-23T07:48:12.991Z",
                    "active_at": "2015-10-08T07:04:00.000Z",
                    "inactive_at": null,
                    "survey_type": "Restaurant"
                  },
                  "relationships": {
                    "questions": {
                      "data": [
                        {
                          "id": "d3afbcf2b1d60af845dc",
                          "type": "question"
                        }
                      ]
                    }
                  }
                }
              ],
              "meta": {
                "page": 1,
                "pages": 10,
                "page_size": 2,
                "records": 20
              }
            }

            """
        
        return data.data(using: .utf8)!
    }
    
    func sampleSurveyList() -> [Survey] {
        [
            Survey(id: "d5de6a8f8f5f1cfe51bc",
                   type: "survey",
                   attributes: SurveyAttributes(title: "Scarlett Bangkok",
                                               description: "We'd love ot hear from you!",
                                               thankEmailAboveThreshold: "sample email above",
                                               thankEmailBelowThreshold: "sample email below",
                                               isActive: true,
                                               coverImageUrl: "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_",
                                               createdAt: "2017-01-23T07:48:12.991Z",
                                               activeAt: "2015-10-08T07:04:00.000Z",
                                               inactiveAt: nil,
                                               surveyType: "Restaurant"),
                   relationships: SurveyRelationship(questions: SurveyQuestionsOrAnswers(data: [
                    SurveyRelationData(id: "d3afbcf2b1d60af845dc", type: "question")
                   ])))
        ]
    }
    
    func sampleSurveyDetailsData() -> Data {
        let data = """
{
  "data": {
    "id": "d5de6a8f8f5f1cfe51bc",
    "type": "survey",
    "attributes": {
      "title": "Scarlett Bangkok",
      "description": "We'd love ot hear from you!",
      "thank_email_above_threshold": "above",
      "thank_email_below_threshold": "below",
      "is_active": true,
      "cover_image_url": "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_",
      "created_at": "2017-01-23T07:48:12.991Z",
      "active_at": "2015-10-08T07:04:00.000Z",
      "inactive_at": null,
      "survey_type": "Restaurant"
    },
    "relationships": {
      "questions": {
        "data": [
        ]
      }
    }
  },
  "included": [
    {
      "id": "d3afbcf2b1d60af845dc",
      "type": "question",
      "attributes": {
        "text": "text",
        "help_text": null,
        "display_order": 0,
        "short_text": "introduction",
        "pick": "none",
        "display_type": "intro",
        "is_mandatory": false,
        "correct_answer_id": null,
        "facebook_profile": null,
        "twitter_profile": null,
        "image_url": "https://dhdbhh0jsld0o.cloudfront.net/m/2001ebbfdcbf6c00c757_",
        "cover_image_url": "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_",
        "cover_image_opacity": 0.6,
        "cover_background_color": null,
        "is_shareable_on_facebook": false,
        "is_shareable_on_twitter": false,
        "font_face": null,
        "font_size": null,
        "tag_list": ""
      },
      "relationships": {
        "answers": {
          "data": []
        }
      }
    }
  ]
}
"""
        return data.data(using: .utf8)!
    }
    
    func sampleSurveyDetails() -> [SurveyDetail] {
        [
            SurveyDetail(id: "d3afbcf2b1d60af845dc",
                         type: "question",
                         attributes: SurveyDetailAttributes(text: "text",
                                                            helpText: nil,
                                                            displayOrder: 0,
                                                            shortText: "introduction",
                                                            pick: "none",
                                                            displayType: "intro",
                                                            isMandatory: false,
                                                            correctAnswerId: nil,
                                                            facebookProfile: nil,
                                                            twitterProfile: nil,
                                                            imageUrl: "https://dhdbhh0jsld0o.cloudfront.net/m/2001ebbfdcbf6c00c757_",
                                                            coverImageUrl: "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_",
                                                            coverImageOpacity: 0.6,
                                                            coverBackgroundColor: nil,
                                                            isShareableOnFacebook: false,
                                                            isShareableOnTwitter: false,
                                                            fontFace: nil,
                                                            fontSize: nil,
                                                            tagList: ""),
                         relationships: SurveyDetailRelationship(answers: SurveyQuestionsOrAnswers(data: [])))
        ]
    }
    
}
