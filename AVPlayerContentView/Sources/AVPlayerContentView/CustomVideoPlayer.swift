//
//  CustomVideoPlayer.swift
//  
//
//  Created by 遠藤拓弥 on 2024/05/11.
//

import SwiftUI
import AVKit

public struct CustomVideoPlayer: View {
    private var customPlayer: CustomAVPlayer

    public init(urls: [URL]) {
        self.customPlayer = CustomAVPlayer(urls: urls)
    }

    public var body: some View {
        VStack {
            VideoPlayer(player: customPlayer.avPlayer)
                .onAppear {
                    customPlayer.play()
                }
                .onDisappear {
                    customPlayer.pause()
                }
                .frame(height: 300)

            HStack {
                Button(action: {
                    customPlayer.play()
                }) {
                    Text("Play")
                }
                Button(action: {
                    customPlayer.pause()
                }) {
                    Text("Pause")
                }
                Button(action: {
                    customPlayer.stop()
                }) {
                    Text("Stop")
                }
            }

            HStack {
                Button(action: {
                    customPlayer.skipForward(by: 10)
                }) {
                    Text("Skip Forward 10s")
                }
                Button(action: {
                    customPlayer.skipBackward(by: 10)
                }) {
                    Text("Skip Backward 10s")
                }
            }

            HStack {
                Button(action: {
                    let url = URL(string: "https://example.com/video.mp4")!  // 適当なURLを追加
                    customPlayer.add(url: url)
                }) {
                    Text("Add Video")
                }
                Button(action: {
                    customPlayer.shufflePlaylist()
                }) {
                    Text("Shuffle Playlist")
                }
                Button(action: {
                    if let currentItem = customPlayer.currentItemInfo() {
                        print("Current Item: \(currentItem)")
                    }
                }) {
                    Text("Current Item Info")
                }
            }

            HStack {
                Button(action: {
                    customPlayer.seek(to: CMTime(seconds: 30, preferredTimescale: 600))
                }) {
                    Text("Seek to 30s")
                }
                Button(action: {
                    customPlayer.skipToItem(at: 0)  // 最初のアイテムにスキップ
                }) {
                    Text("Skip to First Item")
                }
            }

            Text("Current Time: \(customPlayer.currentPlaybackTime()) seconds")
                .padding()
        }
    }
}
