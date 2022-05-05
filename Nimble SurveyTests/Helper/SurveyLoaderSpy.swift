//
//  SurveyLoaderSpy.swift
//  Nimble SurveyTests
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import Foundation
import Nimble_Survey

class SurveyLoaderSpy: SurveyLoader {
    
    private(set) var messages: [Message] = []
    
    private var loadCompletions: [(Result<[Survey], Error>) -> ()] = []
    private var detailCompletions: [(Result<[SurveyDetail], Error>) -> ()] = []
    
    enum Message: Equatable {
        case load(page: Int, size: Int, tokenType: String, accessToken: String)
        case details(id: String, tokenType: String, accessToken: String)
    }
    
    func load(page: Int,
              size: Int,
              tokenType: String,
              accessToken: String,
              completion: @escaping (Result<[Survey], Error>) -> ()) {
        messages.append(.load(page: page,
                              size: size,
                              tokenType: tokenType,
                              accessToken: accessToken))
        loadCompletions.append(completion)
    }
    
    func getDetails(forSurvey id: String,
                    tokenType: String,
                    accessToken: String,
                    completion: @escaping (Result<[SurveyDetail], Error>) -> ()) {
        messages.append(.details(id: id,
                                 tokenType: tokenType,
                                 accessToken: accessToken))
        detailCompletions.append(completion)
    }
    
    func completeLoad(at index: Int = 0,
                      withResult result: Result<[Survey], Error>) {
        loadCompletions[index](result)
    }
    
    func completeGetDetails(at index: Int = 0,
                            withResult result: Result<[SurveyDetail], Error>) {
        detailCompletions[index](result)
    }
    
}
