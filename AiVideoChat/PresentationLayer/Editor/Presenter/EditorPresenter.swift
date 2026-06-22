//
//  EditorPresenter.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import UIKit

protocol EditorPresenter: AnyObject {
    var templates: [Template] { get }

    func createVideo(index: Int, image: UIImage)
    func didTapBack()
}


final class EditorPresenterImpl: EditorPresenter {

    weak var view: EditorViewProtocol?
    private var router: AppRouterProtocol

    private(set) var templates: [Template]

    init(
        view: EditorViewProtocol?,
        router: AppRouterProtocol,
        templates: [Template]
    ) {
        self.view = view
        self.router = router
        self.templates = templates
    }

    func createVideo(index: Int, image: UIImage) {
        let params = VideoParams(
            templateID: Int(templates[index].templateId),
            image: image,
            quality: "720p",
            format: "16:9"
        )
        router.showVideoResult(params)
    }

    func didTapBack() {
        router.pop()
    }
}
