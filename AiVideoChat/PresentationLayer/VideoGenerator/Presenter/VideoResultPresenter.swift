//
//  VideoResultPresenter.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 19.06.2026.
//

import UIKit
import Photos

protocol VideoResultPresenter: AnyObject {

    var currentVideoURL: URL? { get set }

    func generateVideo()
    func goToBack()
    func downloadVideo()
}


final class VideoResultPresenterImpl: VideoResultPresenter {

    weak var view: VideoResultViewProtocol?
    private var router: AppRouterProtocol
    private var params: VideoParams
    private var networkService: NetworkServiceProtocol

    var currentVideoURL: URL?


    init(
        view: VideoResultViewProtocol?,
        router: AppRouterProtocol,
        params: VideoParams,
        networkService: NetworkServiceProtocol
    ) {
        self.view = view
        self.router = router
        self.params = params
        self.networkService = networkService
    }
//    "https://media.nebulaapps.site/e661fd66feb543998a07ebab0303dfb9:descript/protected/pixverse/catalog/templates/742/ebbf92f8d6d646c1850e39385453c1ab.mp4"
    func generateVideo() {
        Task { @MainActor in
            do {
                let result = try await networkService.createVideo(params: params)
                let status = try await networkService.getVideoStatus(id: result.id)
                
                guard let url = URL(string: status.videoURL) else {
                    view?.showError("Incorrect link to video.")
                    return
                }
                
                guard isValidVideoHost(url) else {
                    view?.showError("Video temporarily unavailable (test environment).")
                    return
                }

                currentVideoURL = url

                view?.loadVideo(url: url)
                
            } catch {
                view?.showError(error.localizedDescription)
            }
        }
    }

    func downloadVideo() {
        guard let url = currentVideoURL else { return }

        view?.setDownloadButtonLoading(true)

        requestPhotoLibraryAccess { [weak self] granted in
            guard let self else { return }

            guard granted else {
                self.view?.setDownloadButtonLoading(false)
                self.view?.showError("No access to the gallery. Allow access in device settings.")
                return
            }

            self.downloadAndSaveVideo(from: url)
        }
    }

    func goToBack() {
        router.pop()
    }
}

extension VideoResultPresenterImpl {
    private func isValidVideoHost(_ url: URL) -> Bool {
        let blockedHosts = ["example.com", "example.org", "example.net"]
        guard let host = url.host else { return false }
        return !blockedHosts.contains(host)
    }

    private func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
        }
    }

    private func downloadAndSaveVideo(from url: URL) {
        URLSession.shared.downloadTask(with: url) { [weak self] tempURL, _, error in
            guard let self else { return }

            guard let tempURL, error == nil else {
                DispatchQueue.main.async {
                    self.view?.setDownloadButtonLoading(false)
                    self.view?.showError("Failed to download video. Try it later.")
                }
                return
            }

            let localURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")

            do {
                try FileManager.default.moveItem(at: tempURL, to: localURL)
            } catch {
                DispatchQueue.main.async {
                    self.view?.setDownloadButtonLoading(false)
                    self.view?.showError("Failed to save video.")
                }
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: localURL)
            }) { success, error in
                DispatchQueue.main.async {
                    self.view?.setDownloadButtonLoading(false)
                    try? FileManager.default.removeItem(at: localURL)

                    if success {
                        self.view?.showSavedConfirmation()
                    } else {
                        self.view?.showError("Failed to save video.")
                    }
                }
            }
        }.resume()
    }

}


