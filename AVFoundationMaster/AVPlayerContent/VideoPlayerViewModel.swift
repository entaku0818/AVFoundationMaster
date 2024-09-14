//
//  VideoPlayerViewModel.swift
//  AVFoundationMaster
//
//  Created by 遠藤拓弥 on 2024/09/15.
//
import AVKit
import Foundation
import Combine
import os.log

class VideoPlayerViewModel: ObservableObject {
    @Published var showErrorOverlay = false
    @Published var showErrorAlert = false
    @Published var errorMessage = ""

    let playerManager: AVPlayerManager
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.example.CustomVideoPlayer", category: "ViewModel")


    init(playerManager: AVPlayerManager) {
        self.playerManager = playerManager
        setupBindings()
    }

    func play() {
        logger.info("Playing video")
        playerManager.play()
    }

    func pause() {
        logger.info("Pausing video")
        playerManager.pause()
    }

    func retry() {
        logger.info("Retrying video playback")
        showErrorOverlay = false
        showErrorAlert = false
        errorMessage = ""
        playerManager.retry()
    }

    private func setupBindings() {
        playerManager.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
    }

    private func handleError(_ error: Error) {
        logger.error("Handling error: \(error.localizedDescription)")
        errorMessage = error.localizedDescription
        showErrorOverlay = true

        if let avError = error as? AVError {
            switch avError.code {
            case .noLongerPlayable:
                errorMessage = "コンテンツを再生できなくなりました。"
            case .failedToParse:
                errorMessage = "コンテンツの解析に失敗しました。ファイルが破損している可能性があります。"
            case .contentNotUpdated:
                errorMessage = "ライブプレイリストの更新に失敗しました。"
            default:
                errorMessage = "再生中にエラーが発生しました。"
            }
        }

        if (error as NSError).domain == NSURLErrorDomain {
            errorMessage = "ネットワークエラーが発生しました。接続を確認してください。"
        }
    }
}
