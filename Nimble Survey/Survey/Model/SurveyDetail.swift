//
//  SurveyDetail.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import Foundation

public struct SurveyDetail: Equatable, Codable {
    
    public init(id: String, type: String, attributes: SurveyDetailAttributes, relationships: SurveyDetailRelationship) {
        self.id = id
        self.type = type
        self.attributes = attributes
        self.relationships = relationships
    }
    
    let id: String
    let type: String
    let attributes: SurveyDetailAttributes
    let relationships: SurveyDetailRelationship
}
