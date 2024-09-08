//
//  AVAudioPlayerContentView.swift
//  AVFoundationMaster
//
//  Created by 遠藤拓弥 on 2024/09/08.
//

import Foundation
import SwiftUI
import AVFoundation

struct AVAudioPlayerContentView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0.0
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Text("AVAudioPlayer Example")
                .font(.largeTitle)
                .padding()

            Slider(value: $currentTime, in: 0...(audioPlayer?.duration ?? 1), onEditingChanged: { editing in
                if !editing {
                    audioPlayer?.currentTime = currentTime
                }
            })
            .padding()

            HStack {
                Button(action: playAudio) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .padding()
                }

                Button(action: stopAudio) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .padding()
                }
            }

            Text("Current Time: \(currentTime, specifier: "%.2f")s")
        }
        .onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            stopAudio()
        }
    }

    // 音声プレーヤーのセットアップ
    func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "audiofile", withExtension: "mp3") else {
            print("ファイルが見つかりません")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()

            // 再生中の時間を監視するタイマー
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let player = audioPlayer, player.isPlaying {
                    currentTime = player.currentTime
                }
            }
        } catch {
            print("オーディオプレーヤーの初期化に失敗しました: \(error)")
        }
    }

    // 再生ボタンが押されたときの処理
    func playAudio() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
    }

    // 停止ボタンが押されたときの処理
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
    }
}
