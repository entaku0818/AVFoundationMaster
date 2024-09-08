//
//  AudioPlayerManager.swift
//  AVFoundationMaster
//
//  Created by 遠藤拓弥 on 2024/09/08.
//

import Foundation
import AVFoundation
import os.log

class AudioPlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0.0

    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "AudioPlayer")

    var duration: TimeInterval {
        audioPlayer?.duration ?? 0.0
    }

    init() {
        setupAudioPlayer()
    }

    private func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "audiofile", withExtension: "mp3") else {
            logger.error("Audio file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            logger.info("Audio player initialized successfully")

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let player = self.audioPlayer, player.isPlaying else { return }
                self.currentTime = player.currentTime
                self.logger.debug("Current time updated: \(self.currentTime, privacy: .public)")
            }
        } catch {
            logger.error("Failed to initialize audio player: \(error.localizedDescription)")
        }
    }

    func playPause() {
        if isPlaying {
            audioPlayer?.pause()
            logger.info("Audio paused at \(self.currentTime, privacy: .public) seconds")
        } else {
            audioPlayer?.play()
            logger.info("Audio started playing from \(self.currentTime, privacy: .public) seconds")
        }
        isPlaying.toggle()
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        currentTime = 0
        logger.info("Audio stopped and reset")
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
        logger.info("Seeked to \(time, privacy: .public) seconds")
    }

    deinit {
        timer?.invalidate()
        logger.info("AudioPlayerManager deinitialized")
    }
}
