//
//  ChatMessage.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

struct ChatMessage: Sendable {
    let id: UUID
    let text: String
    let type: MessageType
    let timestamp: Date
    let actions: [ActionItem]?
    let isFirst: Bool
    let list: [String]
    let image: UIImage?

    init(
        text: String,
        type: MessageType,
        actions: [ActionItem]? = nil,
        isFirst: Bool = false,
        list: [String] = [],
        image: UIImage? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.type = type
        self.timestamp = Date()
        self.actions = actions
        self.isFirst = isFirst
        self.list = list
        self.image = image
    }
}

enum MessageType: Hashable, Sendable {
    case incoming
    case outgoing
    case typing
    case actionGrid
    case list
    case media
}

extension ChatMessage: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}



