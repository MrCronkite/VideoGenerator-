//
//  VideoId.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import UIKit

struct VideoId: Decodable {
    let id: Int
    let detail: String

    enum CodingKeys: String, CodingKey {
        case id = "video_id"
        case detail
    }
}

struct VideoStatusResponse: Decodable {
    let status: String
    let videoURL: String

    enum CodingKeys: String, CodingKey {
        case status
        case videoURL = "video_url"
    }
}
