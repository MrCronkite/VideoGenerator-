//
//  Messages.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 18.06.2026.
//

import UIKit

struct Messages: Decodable {
    let role: String
    let content: String
    let messageSource: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case messageSource = "message_source"
        case createdAt = "created_at"
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
}
