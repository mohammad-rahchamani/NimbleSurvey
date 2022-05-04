//
//  Relationship.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import Foundation

public struct SurveyRelationship: Equatable, Codable {
    
    public init(questions: SurveyQuestionsOrAnswers) {
        self.questions = questions
    }
    
    let questions: SurveyQuestionsOrAnswers
}

public struct SurveyDetailRelationship: Equatable, Codable {
    
    public init(answers: SurveyQuestionsOrAnswers) {
        self.answers = answers
    }
    
    let answers: SurveyQuestionsOrAnswers
}

public struct SurveyQuestionsOrAnswers: Equatable, Codable {
    
    public init(data: [SurveyRelationData]) {
        self.data = data
    }
    
    let data: [SurveyRelationData]
}

public struct SurveyRelationData: Equatable, Codable {
    
    public init(id: String, type: String) {
        self.id = id
        self.type = type
    }
    
    let id: String
    let type: String
}
