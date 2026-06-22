//
//  NetworkError.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 18.06.2026.
//

import Foundation



struct SendMessageResponse: Decodable {
    let chatId: String
    let assistantMessage: String

    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case assistantMessage = "assistant_message"
    }
}

struct SendMessageRequestBody: Encodable {
    let message: String
}

@propertyWrapper
struct NonEmpty {
    private var value: String

    var wrappedValue: String {
        get { value }
        set { value = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    init(wrappedValue: String) {
        self.value = wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

@propertyWrapper
struct BearerToken {
    private var rawToken: String

    var wrappedValue: String {
        get { "Bearer \(rawToken)" }
        set { rawToken = newValue }
    }

    init(wrappedValue: String) {
        self.rawToken = wrappedValue
    }
}
