//
//  Attribute.swift
//  Nimble Survey
//
//  Created by Mohammad Rahchamani on 5/4/22.
//

import Foundation


public struct SurveyAttributes: Equatable, Codable {
    
    public init(title: String, description: String, thankEmailAboveThreshold: String, thankEmailBelowThreshold: String, isActive: Bool, coverImageUrl: String, createdAt: String, activeAt: String, inactiveAt: String?, surveyType: String) {
        self.title = title
        self.description = description
        self.thankEmailAboveThreshold = thankEmailAboveThreshold
        self.thankEmailBelowThreshold = thankEmailBelowThreshold
        self.isActive = isActive
        self.coverImageUrl = coverImageUrl
        self.createdAt = createdAt
        self.activeAt = activeAt
        self.inactiveAt = inactiveAt
        self.surveyType = surveyType
    }
    
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

public struct SurveyDetailAttributes: Equatable, Codable {
    
    public init(text: String, helpText: String?, displayOrder: Int, shortText: String, pick: String, displayType: String, isMandatory: Bool, correctAnswerId: String?, facebookProfile: String?, twitterProfile: String?, imageUrl: String, coverImageUrl: String, coverImageOpacity: Double, coverBackgroundColor: String?, isShareableOnFacebook: Bool, isShareableOnTwitter: Bool, fontFace: String?, fontSize: String?, tagList: String) {
        self.text = text
        self.helpText = helpText
        self.displayOrder = displayOrder
        self.shortText = shortText
        self.pick = pick
        self.displayType = displayType
        self.isMandatory = isMandatory
        self.correctAnswerId = correctAnswerId
        self.facebookProfile = facebookProfile
        self.twitterProfile = twitterProfile
        self.imageUrl = imageUrl
        self.coverImageUrl = coverImageUrl
        self.coverImageOpacity = coverImageOpacity
        self.coverBackgroundColor = coverBackgroundColor
        self.isShareableOnFacebook = isShareableOnFacebook
        self.isShareableOnTwitter = isShareableOnTwitter
        self.fontFace = fontFace
        self.fontSize = fontSize
        self.tagList = tagList
    }
    
    let text: String
    let helpText: String?
    let displayOrder: Int
    let shortText: String
    let pick: String
    let displayType: String
    let isMandatory: Bool
    let correctAnswerId: String?
    let facebookProfile: String?
    let twitterProfile: String?
    let imageUrl: String
    let coverImageUrl: String
    let coverImageOpacity: Double
    let coverBackgroundColor: String?
    let isShareableOnFacebook: Bool
    let isShareableOnTwitter: Bool
    let fontFace: String?
    let fontSize: String?
    let tagList: String
}
