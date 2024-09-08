//
//  AudioRecorderManager.swift
//  AVFoundationMaster
//
//  Created by 遠藤拓弥 on 2024/09/08.
//

import Foundation
import AVFoundation
import Combine
import os.log

class AudioRecorderManager: ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.example.AudioRecorderManager", category: "AudioRecorder")

    init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            logger.info("Audio session set up successfully")
        } catch {
            logger.error("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    func startRecording() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true

            startTimer()

            logger.info("Started recording to \(audioFilename.path)")
        } catch {
            logger.error("Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopTimer()
        logger.info("Stopped recording. Total duration: \(self.recordingTime) seconds")
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingTime += 0.1
            self.logger.debug("Recording time: \(self.recordingTime, privacy: .public) seconds")
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        recordingTime = 0
    }

    func getRecordingURL() -> URL? {
        return audioRecorder?.url
    }

    func getRecordings() -> [URL] {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            return fileURLs.filter { $0.pathExtension == "m4a" }
        } catch {
            logger.error("Failed to get recordings: \(error.localizedDescription)")
            return []
        }
    }

    func deleteRecording(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            logger.info("Deleted recording at \(url.path)")
        } catch {
            logger.error("Failed to delete recording: \(error.localizedDescription)")
        }
    }

    deinit {
        stopTimer()
        logger.info("AudioRecorderManager deinitialized")
    }
}
