//
//  ActionItem.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

enum ActionType: CaseIterable {
    case talkAI
    case createVideo
    case write
    case understand
}

struct ActionItem: Hashable {
    let type: ActionType
    let icon: UIImage?
    let title: String
    let subtitle: String
}
