//
//  VideoTranscoder.swift
//  AiVideoChat
//
//  Created by Влад Шимченко on 25.06.2026.
//

import Foundation
import AVFoundation
import CoreGraphics

/// Одноразовый даунскейл видео до маленького разрешения.
///
/// Идея: декодер платит CPU пропорционально количеству пикселей кадра,
/// а не размеру файла на диске. Если источник — честный 1920x1080,
/// проигрывание в ячейке шириной 100-150pt всё равно гоняет full-HD
/// декодер. Транскод выполняется один раз (после того как оригинал
/// полностью закэширован), а выигрыш получаем на каждом последующем
/// проигрывании этого видео.
enum VideoTranscoder {

    enum TranscodeError: Error {
        case noVideoTrack
        case exportSessionCreationFailed
        case exportFailed(Error?)
    }

    /// - Parameters:
    ///   - sourceURL: путь к уже скачанному оригиналу (полное разрешение).
    ///   - outputURL: куда сохранить уменьшенную версию.
    ///   - maxDimension: ограничение по большей стороне кадра в пикселях.
    ///     Считайте от РЕАЛЬНОГО размера ячейки на экране (с учётом
    ///     UIScreen.main.scale), а не наугад — нет смысла декодировать
    ///     больше пикселей, чем физически показывается.
    static func downscale(
        sourceURL: URL,
        outputURL: URL,
        maxDimension: CGFloat = 230,
        targetFPS: Int32 = 24
    ) async throws {

        try? FileManager.default.removeItem(at: outputURL)

        let asset = AVURLAsset(url: sourceURL)

        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            throw TranscodeError.noVideoTrack
        }

        let naturalSize = try await videoTrack.load(.naturalSize)
        let transform = try await videoTrack.load(.preferredTransform)
        let duration = try await asset.load(.duration)

        // naturalSize не учитывает поворот из preferredTransform (например,
        // видео, снятое вертикально, может иметь naturalSize в "горизонтальных"
        // координатах). Приводим к видимому размеру, как он реально показывается.
        let isRotated90or270 = abs(transform.b) == 1 && abs(transform.c) == 1
        let visualSize = isRotated90or270
            ? CGSize(width: naturalSize.height, height: naturalSize.width)
            : naturalSize

        guard visualSize.width > 0, visualSize.height > 0 else {
            throw TranscodeError.noVideoTrack
        }

        // Не увеличиваем, если источник уже меньше maxDimension.
        let scale = min(1, maxDimension / max(visualSize.width, visualSize.height))

        var targetSize = CGSize(
            width: visualSize.width * scale,
            height: visualSize.height * scale
        )
        // Кодеки не любят нечётные размеры кадра.
        targetSize.width = max(2, (targetSize.width / 2).rounded() * 2)
        targetSize.height = max(2, (targetSize.height / 2).rounded() * 2)

        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetMediumQuality
        ) else {
            throw TranscodeError.exportSessionCreationFailed
        }

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: duration)

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

        // Сначала применяем исходный transform (учитывает поворот трека),
        // затем масштабируем уже "выпрямленный" видимый прямоугольник
        // до целевого размера.
        let scaleX = targetSize.width / visualSize.width
        let scaleY = targetSize.height / visualSize.height
        let finalTransform = transform.concatenating(CGAffineTransform(scaleX: scaleX, y: scaleY))
        layerInstruction.setTransform(finalTransform, at: .zero)
        instruction.layerInstructions = [layerInstruction]

        let composition = AVMutableVideoComposition()
        composition.renderSize = targetSize
        // Капаем FPS — если источник 30/60fps, а превью и так muted/looped,
        // лишние кадры не нужны: меньше кадров декодировать на playback.
        composition.frameDuration = CMTime(value: 1, timescale: targetFPS)
        composition.instructions = [instruction]

        exportSession.videoComposition = composition
        exportSession.outputFileType = .mp4
        exportSession.outputURL = outputURL

        await exportSession.export()

        guard exportSession.status == .completed else {
            throw TranscodeError.exportFailed(exportSession.error)
        }
    }
}
