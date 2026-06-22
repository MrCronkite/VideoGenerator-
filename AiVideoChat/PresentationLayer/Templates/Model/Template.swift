//
//  Template.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import UIKit

struct TemplatesResponse: Decodable {
    let id: Int
    let applicationId: String
    let applicationNumber: Int
    let subscriptionEnabled: Bool
    let templates: [Template]

    enum CodingKeys: String, CodingKey {
        case id
        case applicationId = "application_id"
        case applicationNumber = "application_number"
        case subscriptionEnabled = "subscription_enabled"
        case templates
    }
}

struct Template: Decodable {
    let id: Int
    let templateId: Int64
    let prompt: String
    let name: String
    let category: String
    let templateModel: String
    let qualities: [String]
    let duration: Int
    let isCustom: Bool
    let previewSmall: String
    let previewLarge: String
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case templateId = "template_id"
        case prompt
        case name
        case category
        case templateModel = "template_model"
        case qualities
        case duration
        case isCustom = "is_custom"
        case previewSmall = "preview_small"
        case previewLarge = "preview_large"
        case isActive = "is_active"
    }
}
