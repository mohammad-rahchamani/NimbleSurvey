//
//  SurveyLoader.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/5/22.
//

import Foundation

public protocol SurveyLoader {
    
    func load(page: Int,
              size: Int,
              tokenType: String,
              accessToken: String,
              completion: @escaping (Result<[Survey], Error>) -> ())
    
    func getDetails(forSurvey id: String,
                    tokenType: String,
                    accessToken: String,
                    completion: @escaping (Result<[SurveyDetail], Error>) -> ())
    
}
