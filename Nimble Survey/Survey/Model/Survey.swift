//
//  Survey.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import Foundation

public struct Survey: Equatable, Codable {
    
    public init(id: String, type: String, attributes: SurveyAttributes, relationships: SurveyRelationship) {
        self.id = id
        self.type = type
        self.attributes = attributes
        self.relationships = relationships
    }
    
    let id: String
    let type: String
    let attributes: SurveyAttributes
    let relationships: SurveyRelationship
}
