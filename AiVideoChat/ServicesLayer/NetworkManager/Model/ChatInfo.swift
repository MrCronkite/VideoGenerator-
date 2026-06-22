//
//  ChatInfo.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 18.06.2026.
//

import UIKit

struct ChatInfo: Codable {
    let chatId: String
    let title: String?
    let personaId: String?
    let updatedAt: String
    let lastMessagePreview: String

    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case title
        case personaId = "persona_id"
        case updatedAt = "updated_at"
        case lastMessagePreview = "last_message_preview"
    }
}
