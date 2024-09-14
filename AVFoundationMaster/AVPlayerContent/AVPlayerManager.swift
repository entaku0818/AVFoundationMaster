//
//  AVPlayerManager.swift
//  AVFoundationMaster
//
//  Created by 遠藤拓弥 on 2024/09/15.
//
import AVKit
import Foundation
import os.log
import Combine

class AVPlayerManager: ObservableObject {
    @Published var player: AVPlayer
    @Published var error: Error?

    private var playerItem: AVPlayerItem?
    private var statusObserver: NSKeyValueObservation?
    private var errorLogObserver: NSObjectProtocol?
    private var cancellables = Set<AnyCancellable>()
    private let url: URL
    private let logger = Logger(subsystem: "com.example.CustomVideoPlayer", category: "AVPlayerManager")

    init(url: URL) {
        self.url = url
        self.player = AVPlayer(url: url)
        self.playerItem = AVPlayerItem(url: url)
        self.player.replaceCurrentItem(with: playerItem)
        setupObservers()
    }

    func play() {
        logger.info("AVPlayer: Playing")
        player.play()
    }

    func pause() {
        logger.info("AVPlayer: Pausing")
        player.pause()
    }

    func retry() {
        logger.info("AVPlayer: Retrying")
        error = nil
        playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        setupObservers()
        play()
    }

    private func setupObservers() {
        logger.info("AVPlayer: Setting up observers")
        statusObserver = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            self?.handlePlayerItemStatusChange(item)
        }

        errorLogObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemNewErrorLogEntry,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.handleNewErrorLogEntry()
        }

        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
            .sink { [weak self] notification in
                self?.handleFailedToPlayToEndTime(notification)
            }
            .store(in: &cancellables)
    }

    private func handlePlayerItemStatusChange(_ item: AVPlayerItem) {
        switch item.status {
        case .readyToPlay:
            logger.info("AVPlayer: Ready to play")
        case .failed:
            logger.error("AVPlayer: Playback failed")
            error = item.error
        case .unknown:
            logger.info("AVPlayer: Unknown status")
        @unknown default:
            logger.warning("AVPlayer: Unknown default status")
        }
    }

    private func handleNewErrorLogEntry() {
        guard let errorLog = playerItem?.errorLog()?.events.last else { return }
        logger.error("AVPlayer: New error log entry: \(errorLog.errorComment ?? "Unknown error")")
        error = NSError(domain: errorLog.errorDomain, code: errorLog.errorStatusCode, userInfo: [NSLocalizedDescriptionKey: errorLog.errorComment ?? "Unknown error"])
    }

    private func handleFailedToPlayToEndTime(_ notification: Notification) {
        if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
            logger.error("AVPlayer: Failed to play to end time: \(error.localizedDescription)")
            self.error = error
        }
    }

    deinit {
        logger.info("AVPlayer: Deinitializing")
        statusObserver?.invalidate()
        if let observer = errorLogObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
