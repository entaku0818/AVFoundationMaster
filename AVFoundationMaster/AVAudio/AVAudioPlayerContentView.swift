//
//  AVAudioPlayerContentView.swift
//  AVFoundationMaster
//
//  Created by 遠藤拓弥 on 2024/09/08.
//

import SwiftUI

struct AVAudioPlayerContentView: View {
    @StateObject private var audioManager = AudioPlayerManager()

    var body: some View {
        VStack {
            Text("AVAudioPlayer Example")
                .font(.largeTitle)
                .padding()

            Slider(value: $audioManager.currentTime, in: 0...audioManager.duration, onEditingChanged: { editing in
                if !editing {
                    audioManager.seek(to: audioManager.currentTime)
                }
            })
            .padding()

            HStack {
                Button(action: audioManager.playPause) {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .padding()
                }

                Button(action: audioManager.stop) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .padding()
                }
            }

            Text("Current Time: \(audioManager.currentTime, specifier: "%.2f")s")
        }
    }
}
