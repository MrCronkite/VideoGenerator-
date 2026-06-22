//
//  UICollectionView+Ext.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 16.06.2026.
//

import UIKit

protocol ConfigurableCell {
    func configure(with message: ChatMessage)
}

extension UICollectionView {

    func dequeue<T: UICollectionViewCell>(
        _ type: T.Type,
        for indexPath: IndexPath
    ) -> T {
        dequeueReusableCell(
            withReuseIdentifier: String(describing: type),
            for: indexPath
        ) as! T
    }
}

extension UICollectionViewCell {
    static var reuseId: String {
        String(describing: Self.self)
    }
}
